class UserPermission
  include Mongoid::Document
  include Mongoid::Paranoia

  belongs_to :user
  belongs_to :client
end
