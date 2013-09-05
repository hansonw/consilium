require 'consilium_fields'
require 'consilium_field_references'

class Brokerage
  include Mongoid::Document
  include Mongoid::Timestamps
  include ConsiliumFields
  include ConsiliumFieldReferences

  has_many :clients
  has_many :users

  field :name, type: String
  field :address, type: String
  field :website, type: String
  field :phone, type: String
  field :fax, type: String
  field :num_clients, type: Integer
  field :employees, type: Integer

  field :contacts, type: Array
end
