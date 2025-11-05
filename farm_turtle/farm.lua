local hojd = 9
local bredd = 8

local function hitta_kista()
        local ja, data = turtle.inspectDown()
        if not ja then return false end
        local namn = data.name:lower()
        return string.find(namn, "chest")
end

local function alder()
        local ja, data = turtle.inspectDown()
        if ja and data.state.age == 7 then
                turtle.digDown()
                turtle.placeDown()
        end
        if not ja then
                turtle.placeDown()
        end
end

local function spara_kista()
        if not hitta_kista() then
                return
        end
        for plats = 1, 16 do
                local sak = turtle.getItemDetail(plats)

                if sak then
                        local namn = sak.name
                        if namn ~= "minecraft:coal" and namn ~= "ars_nouveau:magebloom_crop" then
                                turtle.select(plats)
                                turtle.dropDown()
                        end
                end
        end
        turtle.select(1)
end

local function rorelse(h, b)
    local upp = 1

    for i = 1, b do
        for j = 1, h do
            turtle.forward()
            alder()
        end

        if i < b then
            if upp == 1 then
                turtle.turnLeft()
                alder()
                turtle.forward()
                turtle.turnLeft()
                upp = 0
            else
                turtle.turnRight()
                alder()
                turtle.forward()
                turtle.turnRight()
                upp = 1
            end

        end
    end
    if upp == 0 then
            turtle.turnLeft()
            while not hitta_kista() do
                    turtle.forward()
            end
            turtle.turnLeft()
   else
           for k = 1,h do
                   turtle.forward()
           end
            turtle.turnLeft()
            while not hitta_kista() do 
                turtle.forward()
            end
            turtle.turnLeft()
    end
 end
while turtle.getFuelLevel() > 50 do
        rorelse(hojd,bredd)
        spara_kista()
end

