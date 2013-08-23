class DocumentTemplate
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :client
  belongs_to :user

  field :template, type: String
  field :section, type: String
  field :data, type: Moped::BSON::Binary
end
