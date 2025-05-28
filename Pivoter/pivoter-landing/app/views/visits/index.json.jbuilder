json.array!(@visits) do |visit|
  json.extract! visit, :id, :email, :ip, :startup_id
  json.url visit_url(visit, format: :json)
end
