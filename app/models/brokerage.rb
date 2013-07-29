class Brokerage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :address, type: String
  field :website, type: String
  field :phone, type: String
  field :fax, type: String
  field :clients, type: Integer
  field :employees, type: Integer

  field :contacts, type: Array
end
