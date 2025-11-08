local function initial_check_and_reboot()
    -- Denna funktion körs ENDAST en gång när programmet startar.
    if not (peripheral and peripheral.isPresent and peripheral.isPresent("back")) then
        print("Reactor 'back' not found at startup. Rebooting to retry in 3s...")
        os.sleep(3)
        os.reboot()
    else
        -- Om den hittas, körs programmet vidare till huvudloopen.
        return
    end
end

-- Kör den initiala checken
initial_check_and_reboot()

term.clear()
print("Latest Reboot "..os.date())

while true do
    -- Linda in enheter I loopen för att uppdatera anslutningarna
    local enhet = peripheral.wrap("back")
    local env = peripheral.wrap("top")
    local monitor = peripheral.wrap("monitor_3")

    -- Använd pcall för att fånga ALLA fel som kan uppstå vid interaktion
    local success, result = pcall(function()
        -- Kontrollera att *alla* enheter är tillgängliga just nu
        if not enhet or not env or not monitor then
            error("A critical peripheral is currently unavailable (chunk unloaded?)")
        end

        monitor.setTextScale(1.5)
            
        -- Din ursprungliga logik för datainsamling:
        local temp_full = enhet.getTemperature() - 273.15 or "unknown"
        local temp = string.format("%.2f", temp_full) or "unknown"
        local status = enhet.getStatus() or "unknown"
        local burnrate = enhet.getActualBurnRate() or "unknown"
        local maxburnrate = enhet.getMaxBurnRate() or "unknown"
        local fuel_needed = enhet.getFuelNeeded() or "unknown"
        
        -- Byt namn på variabler för tydlighet så vi inte har 'fuel' två gånger:
        local coolant_full = enhet.getCoolantFilledPercentage() * 100 or "unknown"
        local coolant = string.format("%.0f", coolant_full) or "unknown"
        local skada = enhet.getDamagePercent() or "unknown"
        local fuel_full = enhet.getFuelFilledPercentage() * 100 or "unknown"
        local formatted_fuel_percent = string.format("%.0f", fuel_full) or "unknown"
        
        local radia_full = env.getRadiation()
        local radia = string.format("%.2f", radia_full.radiation)
        local radia_unit = string.format(radia_full.unit)

        if skada > 4 then
            enhet.scram()
            os.sleep(10)
        end

        monitor.clear()
        
        -- Rad 1-4 (standard grönt/rött)
        monitor.setTextColor(colors.green)
        monitor.setCursorPos(1,1)
        monitor.write("Powered On: "..tostring(status))
        monitor.setCursorPos(1,2)

        if skada > 15 then
            monitor.setTextColor(colors.red)
        elseif skada > 4 then
            monitor.setTextColor(colors.yellow)
        else
            monitor.setTextColor(colors.green)
        end

        monitor.write("Damage: "..skada.."%")
        monitor.setCursorPos(1,3)
        monitor.setTextColor(colors.green)
        monitor.write("Temp: "..temp.."C")
        monitor.setCursorPos(1,4)
        monitor.write("Burnrate: "..burnrate.."%".."    Max: "..maxburnrate.."%")


        monitor.setCursorPos(1,5)
        if coolant_full < 6 then
            monitor.setTextColor(colors.red)
        elseif coolant_full < 21 then
            monitor.setTextColor(colors.yellow)
        else
            monitor.setTextColor(colors.green)
        end
        monitor.write("Water: "..coolant.."%")


        monitor.setCursorPos(1,6)
        if fuel_full < 6 then
            monitor.setTextColor(colors.red)
        elseif fuel_full < 21 then
            monitor.setTextColor(colors.yellow)
        else
            monitor.setTextColor(colors.green)
        end
        monitor.write("Fuel: ".. formatted_fuel_percent .."%")


        monitor.setCursorPos(1,7)
        monitor.setTextColor(colors.green)
        monitor.write("Radiation: ".. radia .." " .. radia_unit)

    end) -- Slut på pcall-funktionen

    if not success then
        term.clear()
        print("Runtime error or missing peripheral.")
        print("Error details: " .. tostring(result))
        print("Waiting 5 seconds before retrying loop...")
        os.sleep(5)
    else
        os.sleep(0.3)
    end
end
