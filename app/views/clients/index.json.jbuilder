json.array!(@clients) do |client|
  json.id client._id.to_s
  json.name client.name
end
