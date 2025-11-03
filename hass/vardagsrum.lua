local webhookURL = "https://domän.se/api/webhook/mitt_id"

local http = http
local headers = {
  ["Content-Type"] = "application/json"
}

local body = "{}"

local response, err = http.post(webhookURL, body, headers)
if not response then
  print("")
else
  print()
  response.close()
end

