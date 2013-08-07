json.array!(@brokerages) do |brokerage|
  json.extract! brokerage, :name, :address, :website, :phone, :fax, :clients, :employees, :contacts
  json.url brokerage_url(brokerage, format: :json)
end
