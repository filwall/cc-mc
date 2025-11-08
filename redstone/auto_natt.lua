local input = "top"
local dispenser = "back"
local ritual = "right"

local ljus = 4

local function hitta_spelare()
    local detector = peripheral.wrap("left")
    local alla_spelare = detector.getOnlinePlayers()
    local spelare = "Epicexodia1337"
    for i, namn in ipairs(alla_spelare) do
        if namn == spelare then
            return true
        end
    end
   -- print(spelare .. " �r inte inne")
   -- return false
end


while true do
    os.sleep(10)
    if hitta_spelare() then
        print(redstone.getAnalogInput(input))
        if redstone.getAnalogInput(input) > ljus then
            redstone.setOutput(dispenser, true)
            os.sleep(3)
            redstone.setOutput(dispenser, false)
            redstone.setOutput(ritual, true)
            os.sleep(3)
            redstone.setOutput(ritual, false)
        end
    end
end

