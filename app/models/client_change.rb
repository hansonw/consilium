class ClientChange
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :client # for indexing purposes
  has_many :documents
  field :client_data, type: Hash
  field :description, type: String
end