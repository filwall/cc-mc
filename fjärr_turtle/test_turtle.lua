local socket = require("socket")

local server = socket.bind("*", 12345) -- Lyssnar på port 12345
server:settimeout(0) -- Icke-blockerande läge
print("Turtle server listening on port 12345")

local function handleCommand(command)
    if command == "w" then
        turtle.forward()
    elseif command == "s" then
        turtle.back()
    elseif command == "e" then
        turtle.up()
    elseif command == "c" then
        turtle.down()
    elseif command == "a" then
        turtle.turnLeft()
    elseif command == "d" then
        turtle.turnRight()
    elseif command == "f" then
        turtle.dig()
    elseif command == "r" then
        turtle.refuel()
    elseif command == "x" then
        print("Stopping server.")
        return false
    else
        print("Unknown command: " .. command)
    end
    return true
end

local running = true

while running do
    local client = server:accept() -- Accepterar inkommande anslutningar
    if client then
        client:settimeout(1)
        local message, err = client:receive()
        if not err then
            print("Received command: " .. message)
            running = handleCommand(message)
        else
            print("Client error: " .. err)
        end
        client:close()
    end
    os.sleep(0.1) -- Minskar CPU-belastning
end

server:close()
print("Server stopped.")

