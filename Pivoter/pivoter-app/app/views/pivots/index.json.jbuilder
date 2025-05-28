json.array!(@pivots) do |pivot|
  json.extract! pivot, :id, :startup_id, :start_date, :finish_date
  json.url pivot_url(pivot, format: :json)
end
