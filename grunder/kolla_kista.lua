-- Hitta en kista
local chest = peripheral.find("minecraft:chest")

if chest then
    -- Hitta en ansluten monitor
    local monitor = peripheral.find("monitor")

    if monitor then
        monitor.clear()  -- Rensa skärmen
        monitor.setTextScale(1)  -- Ställ in textstorlek (kan justeras för större eller mindre text)

        -- Skanna föremålen i kistan
        local items = chest.list()

        local totalItems = 0

        -- Gå igenom alla föremål i kistan och summera deras antal
        for _, item in pairs(items) do
            totalItems = totalItems + item.count
        end

        -- Visa resultatet på monitoren
        monitor.setCursorPos(1, 1)
        monitor.write(totalItems)
    else
        print("Ingen monitor hittades!")
    end
else
    print("Ingen kista hittades!")
end

