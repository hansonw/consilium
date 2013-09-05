class DocumentTemplateSection
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  belongs_to :user
  belongs_to :client
  belongs_to :document_template

  field :name, type: String
  field :data, type: Moped::BSON::Binary
end
