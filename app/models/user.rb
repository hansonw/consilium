require 'proxy_current_user'

class User
  include Mongoid::Document
  include Mongoid::Paranoia

  CLIENT = 1
  BROKER = 2
  ADMIN  = 3

  belongs_to :brokerage

  has_many :client_changes
  has_many :documents, dependent: :delete
  has_many :user_permissions, dependent: :delete
  has_one :recent_clients, class_name: 'RecentClients', dependent: :delete

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  field :name, :type => String, :default => ""

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  field :authentication_token, :type => String

  field :permissions, :type => Integer, :default => BROKER

  FIELDS = [
    {
      :id => 'name',
      :name => 'Name',
      :placeholder => 'Name',
      :required => true,
      :type => 'text',
      :primary => true,
    },
    {
      :id => 'email',
      :name => 'Email',
      :placeholder => 'e.g. john@consilium.ca',
      :required => true,
      :type => 'email',
      :primary => true,
    },
    {
      :id => 'password',
      :name => 'Password',
      :type => 'password',
      :if => '$!readonly',
      #:required => true,
    },
    #{
    #  :id => 'password_confirm',
    #  :name => 'Confirm Password',
    #  :type => 'password',
    #  :required => true,
    #},
  ]

  def password_required?
    return true if current_user == nil
    current_user.cannot? :manage, self
  end

  def ability
    @ability ||= Ability.new(self)
  end

  protected

  set_callback(:save, :before) do |document|
    reset_password if valid? && (encrypted_password.blank? || password.blank?)
  end

  set_callback(:create, :after) do |document|
    Mailer.user_welcome({
      :to => document[:email],
      :token => reset_password_token,
      :variables => {
        :name => document[:name],
        :brokerage => document.brokerage[:name],
      },
    }).deliver
  end

  private

  def reset_password
    generate_reset_password_token

    Mailer.reset_password({
      :to => self[:email],
      :token => reset_password_token,
      :variables => {
        :name => self[:name],
        :brokerage => self.brokerage[:name],
      }
    }).deliver
  end

  delegate :can?, :cannot?, :to => :ability
  delegate :current_user, :subclasses, :to => ProxyCurrentUser
end
