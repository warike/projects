json.array!(@startups) do |startup|
  json.extract! startup, :id, :name, :webpage, :pitch, :videopitch, :achievements, :logo
  json.url startup_url(startup, format: :json)
end
