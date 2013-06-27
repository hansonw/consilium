class Document
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  embeds_one :client
  field :description, type: String
end