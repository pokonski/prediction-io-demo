json.array!(@people) do |girl|
  json.extract! girl, :id
  json.url person_url(girl, format: :json)
end
