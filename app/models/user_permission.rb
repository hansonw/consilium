class UserPermission
  include Mongoid::Document

  belongs_to :user
  belongs_to :client

  field :can_manage, :type => Boolean, :default => true
end
