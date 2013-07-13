class Brokerage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :office, type: String
  field :marketer, type: String
  field :producer, type: String
end