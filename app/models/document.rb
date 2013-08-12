class Document
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :client # for indexing
  belongs_to :client_change
  field :description, type: String
  field :template, type: String

  FIELDS = [
    
  ]
end
