local monitor = peripheral.wrap("right")
monitor.setTextScale(5)

local function visa_tid(tid)
    monitor.clear()
    monitor.setCursorPos(1,1)
    monitor.write(tostring(tid))
end

while true do
    local nutid = os.date("%H:%M")
    visa_tid(nutid)
    os.sleep(5)
end
