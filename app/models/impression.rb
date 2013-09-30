class Impression
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :impressionable_type, :type => String
  field :impressionable_id, :type => String
  field :user_id, :type => String
  field :controller_name, :type => String
  field :action_name, :type => String
  field :view_name, :type => String
  field :request_hash, :type => String
  field :ip_address, :type => String
  field :session_hash, :type => String
  field :message, :type => String
  field :referrer, :type => String
end
