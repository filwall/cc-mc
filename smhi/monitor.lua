local stationId = 14
local apiURL = "https://opendata-download-metobs.smhi.se/api/version/1.0/parameter/1/station/"
               .. tostring(stationId) .. "/period/latest-hour/data.json"
local interval = 60
local monitorSide = "top"

local monitor = peripheral.wrap(monitorSide)
if not monitor then
  error("Ingen monitor på sidan " .. monitorSide)
end

monitor.setTextScale(0.5)
local function showInfo(temp)
  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.write("Alingsas")
  monitor.setCursorPos(1, 2)
  monitor.write("Temp:")
  monitor.setCursorPos(1, 3)
  monitor.write(tostring(temp) .. " C")
end

-- Loop
while true do
  local response = http.get(apiURL)
  if response then
    local body = response.readAll()
    response.close()

    local ok, data = pcall(textutils.unserializeJSON, body)
    if ok and data and data.value then
      local n = #data.value
      if n > 0 and data.value[n].value then
        local temp = tonumber(data.value[n].value)
        if temp then
          showInfo(temp)
        end
      end
    end
  end

  sleep(interval)
end

