class RecentClients
  include Mongoid::Document

  belongs_to :user

  field :clients, :type => Array
end