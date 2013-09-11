require 'consilium_fields'

class ClientContact
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Mongoid::Attributes::Dynamic
  include ConsiliumFields

  belongs_to :client
  has_one :user
end
