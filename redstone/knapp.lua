local input = "top"
local delay = 0.1

local prev = redstone.getInput(input)

while true do
    os.pullEvent("redstone")
    os.sleep(delay)
    
    local cur = redstone.getInput(input)
    
    if cur and not prev then
        shell.run("light")
    end
    
    prev = cur
end
