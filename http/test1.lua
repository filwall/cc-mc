-- Starta en HTTP-server
print("Startar HTTP-server...")

local port = 8080 -- Välj portnummer
local server = http.websocket("ws://localhost:" .. port)

if not server then
    print("Kunde inte starta servern.")
    return
end

print("Server körs på port " .. port)

while true do
    local event, url, message = os.pullEvent("websocket_message")
    print("Meddelande från Python: " .. message)
end

