require 'proxy_current_user'
require 'andand'

class User
  include Mongoid::Document
  include Mongoid::Paranoia
  include ActionView::Helpers::HostHelper
  include ConsiliumFields

  CLIENT = 1
  BROKER = 2
  ADMIN  = 3

  belongs_to :brokerage

  has_many :client_changes
  has_many :document_template_sections
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

    # HACK! Temporarily tie the user to the first brokerage until we block out
    # this registration path or create a new brokerage for a first user.
    document.brokerage = Brokerage.all.first
  end

  set_callback(:create, :after) do |document|
    Mailer.user_welcome({
      :to => document[:email],
      :variables => {
        :activation_url => "#{site_host}/app#/auth/reset_password?id=#{document[:id]}&token=#{reset_password_token.to_s}&activate",
        :site_url => "#{site_host}/app#",
        :email => document[:email],
        :token => reset_password_token,
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
      :variables => {
        :token => reset_password_token,
        :name => self[:name],
        :brokerage => self.brokerage[:name],
      }
    }).deliver
  end

  delegate :can?, :cannot?, :to => :ability
  delegate :current_user, :subclasses, :to => ProxyCurrentUser
end
