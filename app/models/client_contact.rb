require 'consilium_fields'
require 'consilium_field_references'

class ClientContact
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Mongoid::Attributes::Dynamic
  include ConsiliumFields
  include ConsiliumFieldReferences
  include ConsiliumFieldReferences::UpdateOwners

  belongs_to :client
  has_one :user

  syncable

  autosync_references :user
end
