json.array!(@entries) do |entry|
  json.extract! entry, :id, :title, :type, :url, :description
  json.url entry_url(entry, format: :json)
end
