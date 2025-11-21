local modem = peripheral.find("modem")

local bridge = "me_bridge_0"

local kamare1 = "ars_nouveau:imbuement_chamber_1"
local kamare2 = "ars_nouveau:imbuement_chamber_2"
local kamare3 = "ars_nouveau:imbuement_chamber_3"

local filter = {name = "minecraft:lapis_lazuli", count = 1}

 while true do
     modem.callRemote(bridge, "exportItem", filter, kamare1)
     modem.callRemote(bridge, "exportItem", filter, kamare2)
     modem.callRemote(bridge, "exportItem", filter, kamare3)
     sleep(53)
end
