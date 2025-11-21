local modem = peripheral.find("modem")

local bridgeName = "me_bridge_0"     -- byt om CC visar ett annat namn
local chestName  = "ironchest:iron_chest_0"  -- byt till exakt kistanamn

local filter = { name = "ars_nouveau:sourceberry_bush", count = 3000 }

while true do
        local antal, err = modem.callRemote(bridgeName, "importItem", filter, chestName)
        if not antal then
          print("Import misslyckades:", err)
        end
        sleep(900)
end
