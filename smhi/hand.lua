local stationId = 14
local apiURL = "https://opendata-download-metobs.smhi.se/api/version/1.0/parameter/1/station/"
               .. tostring(stationId) .. "/period/latest-hour/data.json"

local function fetchAndPrint()
  local response = http.get(apiURL)
  if not response then
    print("Fel: kunde inte hämta data")
    return
  end

  local body = response.readAll()
  response.close()

  local ok, data = pcall(textutils.unserializeJSON, body)
  if not ok or not data then
    print("Fel vid JSON-tolkning:")
    print(body)
    return
  end

  if data.value then
    local n = #data.value
    if n > 0 and data.value[n].value then
      local temp = tonumber(data.value[n].value)
      if temp then
        print("Alingsas: " .. tostring(temp) .. " grader")
        return
      end
    end
  end

  print("Kunde inte hitta temperatur i JSON:")
  print(body)
end

fetchAndPrint()
