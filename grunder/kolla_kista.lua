-- Hitta kistan
local chest = peripheral.find("minecraft:chest")

if chest then
    -- Skanna genom alla föremål i kistan
    local items = chest.list()  -- Hämtar alla objekt i kistan

    -- Sätt föremålet du vill kontrollera (t.ex. diamanten)
    local itemName = "minecraft:diamond"
    local itemCount = 0

    -- Loop genom kistans objekt
    for slot, item in pairs(items) do
        if item.name == itemName then
            itemCount = itemCount + item.count
        end
    end

    -- Skriv ut resultatet
    if itemCount > 0 then
        print("Det finns " .. itemCount .. " diamanter i kistan.")
    else
        print("Inga diamanter hittades i kistan.")
    end
else
    print("Ingen kista hittades i närheten.")
end

