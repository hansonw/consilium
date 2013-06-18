class Client
  include Mongoid::Document
  field :name, type: String
  field :updated_at, type: Integer
end
