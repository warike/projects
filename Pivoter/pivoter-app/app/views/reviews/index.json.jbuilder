json.array!(@reviews) do |review|
  json.extract! review, :id, :pivot_id, :user_id, :comment,  :ratelogo, :ratepitch, :ratevideo, :rateidea
  json.url review_url(review, format: :json)
end
