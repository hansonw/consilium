require 'consilium_fields'

class ClientContact
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include ConsiliumFields

  belongs_to :clients

  field :name, type: String
end
