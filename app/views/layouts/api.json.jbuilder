json.meta do
  json.status response.status
  json.message response.message
end

json.errors @errors

json.data JSON.parse(yield)
