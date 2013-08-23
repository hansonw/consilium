class DocumentTemplateSection
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :client
  belongs_to :document_template

  field :name, type: String
  field :data, type: Moped::BSON::Binary
end
