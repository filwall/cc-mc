local volume = 1
local pitch  = -5


local input = "top"

local prev = redstone.getInput(input)

while true do
    os.pullEvent("redstone")
    os.sleep(0.1)
    
    local cur = redstone.getInput(input)
    
    if cur and not prev then

        local s = peripheral.find("speaker")

        s.playSound("item.totem.use",volume,pitch)
    end
    prev = cur
end
