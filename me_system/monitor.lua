local formatnr = require("format")

local me = peripheral.wrap("top")
local mon = peripheral.wrap("monitor_6")
local mini = peripheral.wrap("monitor_7")

local inv_detect = peripheral.wrap("left")

rednet.open("back")
local me_prev_procent = nil


mini.clear()
mini.setCursorPos(1,1)
mini.setTextScale(4)
mini.write(" ME SYSTEM STATUS")

while true do
    local uis = me.getUsedItemStorage()
    local nu_uis = tonumber(uis)
    local short_uis formatnr.format(nu_uis)
    
    local procent = tonumber(uis) / tonumber(me.getTotalItemStorage()) * 100
    
    local eu = me.getEnergyUsage()
    local str_eu = string.format("%.2f",eu)
    
    local es = me.getEnergyStorage()
    local str_es = string.format("%.2f",es)
    
    local teu = me.getMaxEnergyStorage()
    local str_teu = string.format("%.2f",teu)
    
    local is_crafting = me.getCraftingCPUs()[1]
    
    --local inv = inv_detect.getItemInHand()
    --local hand = inv.displayName
    
    --local inv_user = inv_detect.getOwner()
    --local armor_user = inv_detect.getArmor()
    
    mon.setTextScale(2.5)
    mon.clear()
    mon.setCursorPos(1,1)
    mon.write("Things: " .. uis)
    mon.setCursorPos(1,2)
    mon.write(string.format("%.2f",procent) .. "% Used")
    mon.setCursorPos(1,4)
    mon.write("Energy Usage: " .. str_eu)
    mon.setCursorPos(1,5)
    mon.write("Energy Stored: " .. str_es)
    mon.setCursorPos(1,6)
    mon.write("Total Energy: " .. str_teu)
    mon.setCursorPos(1,8)
    mon.write("Is crafting: " .. tostring(is_crafting.isBusy))
   
    local nu_procent = procent
    if procent ~= me_prev_procent then
        rednet.broadcast(string.format("%.2f",procent), "me_lagring")
        me_prev_procent = procent
    end    
   -- mon.setCursorPos(1,10)
   -- mon.write(inv_user)
   -- mon.setCursorPos(1,11)
   -- mon.write(hand)
   -- mon.setCursorPos(1,11)
   -- mon.write(armor_user[4].displayName)
   -- mon.setCursorPos(1,12)
   -- mon.write(armor_user[3].displayName)
   -- mon.setCursorPos(1,13)
   -- mon.write(armor_user[2].displayName)
   -- mon.setCursorPos(1,14)
   -- mon.write(armor_user[1].displayName)
end
