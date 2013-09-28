class FileAttachment
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  FIELDS = []

  belongs_to :user
  belongs_to :client

  field :name, type: String
  field :data, type: Moped::BSON::Binary
end
