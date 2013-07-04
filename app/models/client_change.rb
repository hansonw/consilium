class ClientChange
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :client # for indexing purposes
  has_many :documents
  embeds_one :client_data, class_name: 'Client'
  field :description, type: String
end