-- SMHI temperatursensor för CC:Tweaked
-- Byt stationId vid behov:
--   71420 = Göteborg A      (~45 km, SMHI CORE, pålitlig)
-- Lista alla stationer: opendata-download-metobs.smhi.se/api/version/latest/parameter/1.json
local stationId = 71420

local apiURL = "https://opendata-download-metobs.smhi.se/api/version/latest/parameter/1/station/"
               .. tostring(stationId) .. "/period/latest-hour/data.json"

local function fetchAndPrint()
  local response = http.get(apiURL)
  if not response then
    print("Fel: kunde inte ansluta till SMHI")
    return
  end

  local body = response.readAll()
  response.close()

  local ok, data = pcall(textutils.unserializeJSON, body)
  if not ok or type(data) ~= "table" then
    print("Fel vid JSON-tolkning:")
    print(body)
    return
  end

  if type(data.value) == "table" and #data.value > 0 then
    local latest = data.value[#data.value]
    local temp = latest and tonumber(latest.value)
    if temp then
      local stationName = (data.station and data.station.name) or ("Station " .. stationId)
      print(stationName .. ": " .. tostring(temp) .. " grader")
      return
    end
  end

  print("Ingen temperaturdata hittades:")
  print(body)
end

fetchAndPrint()
