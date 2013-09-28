require 'consilium_fields'
require 'consilium_field_references'
require 'proxy_current_user'
require 'andand'

class User
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps
  include ActionView::Helpers::HostHelper
  include ConsiliumFields
  include ConsiliumFieldReferences::UpdateOwners

  CLIENT = 1
  BROKER = 2
  ADMIN  = 3

  before_validation :check_references
  before_save :check_password
  before_create :maybe_give_brokerage
  after_create :send_welcome_email

  belongs_to :client_contact
  belongs_to :brokerage

  has_many :client_changes
  has_many :document_template_sections
  has_many :documents, dependent: :delete
  has_many :file_attachments, dependent: :delete
  has_one :recent_clients, class_name: 'RecentClients', dependent: :delete

  validates :name, :uniqueness => {:scope => [:deleted_at, :brokerage_id]}, :if => :name_required?
  validates :email, :uniqueness => {:scope => :deleted_at}, :if => :email_required?
  validates :password, :presence => true, :if => :password_required?
  validates :password, :length => {in: 8..20}, :allow_blank => true
  validates :password_confirmation, :confirmation => true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  # :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :token_authenticatable

  blacklist_fields [:password, :encrypted_password,
                   :reset_password_token, :reset_password_sent_at,
                   :sign_in_count, :current_sign_in_at,
                   :last_sign_in_at, :current_sign_in_ip,
                   :last_sign_in_ip, :authentication_token]

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

  def name_required?
    true
  end

  def email_required?
    true
  end

  def password_required?
    return true if current_user == nil
    current_user.cannot? :manage, self
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def reset_password
    generate_password_token

    Mailer.reset_password({
      :to => self[:email],
      :variables => {
        :token => reset_password_token,
        :name => self[:name],
        :brokerage => self.brokerage[:name],
      }
    }).deliver
  end

  protected

  def check_references
    # Resolve references up the hierarchy in case this user was created for
    # a client contact.
    if self.brokerage.nil? && !self.client_contact.nil?
      self.brokerage = self.client_contact.client.brokerage
      self[:permissions] = CLIENT
    end
  end

  def generate_password_token
    # Fuck Devise. Seriously. Fuck it to hell. They have a method to generate a
    # token and send instructions on how to reset your password, but there's no
    # method to just generate a token.
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token = enc
    self.reset_password_sent_at = Time.now.utc

    # XXX: This seems to cause double-insertion issues. Disabled for now.
    #self.save(:validate => false)
  end

  def check_password
    generate_password_token if valid? && (encrypted_password.blank? || password.blank?) && reset_password_token.nil?
  end

  def maybe_give_brokerage
    # If the user doesn't have a brokerage when they're saved, they should be
    # given their own new one.
    if self.brokerage.nil? && self.client_contact.nil?
      brokerage = Brokerage.new
      self.brokerage = brokerage if brokerage.save
      self[:permissions] = ADMIN
    end
  end

  def send_welcome_email
    Mailer.user_welcome({
      :to => self[:email],
      :variables => {
        :activation_url => "#{site_host}/app#/auth/reset_password?id=#{self[:id]}&token=#{reset_password_token}&email=#{self[:email]}&activate",
        :site_url => "#{site_host}/app#/auth/login?email=#{self[:email]}",
        :email => self[:email],
        :token => reset_password_token,
        :name => self[:name],
        :brokerage => self.brokerage[:name],
      },
      :permissions => self[:permissions]
    }).deliver
  end

  delegate :can?, :cannot?, :to => :ability
  delegate :current_user, :subclasses, :to => ProxyCurrentUser
end
