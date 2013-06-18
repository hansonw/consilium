json.array!(@clients) do |client|
  json.id client._id.to_s
  json.name client.name
  json.updated_at client.updated_at
end
