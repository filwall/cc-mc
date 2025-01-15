-- Funktion för ett steg framåt
function digStep()
    turtle.dig()
    turtle.forward()
    turtle.digUp()
end

-- Kontrollera om inventeringen är full
function isInventoryFull()
    for i = 1, 16 do
        if turtle.getItemCount(i) == 0 then
            return false
        end
    end
    return true
end

-- Kontrollera bränslenivån
function hasEnoughFuel(steps)
    return turtle.getFuelLevel() >= steps
end

-- Återvänd till startpunkten
function returnToStart(steps)
    for _ = 1, steps do
        turtle.back()
    end
end

-- Gräv en 2x2-tunnel och hantera bränsle/inventering
function digTunnel(length)
    local stepsTaken = 0
    for i = 1, length do
        -- Kontrollera bränsle och inventering
        if not hasEnoughFuel((length - stepsTaken) * 2) or isInventoryFull() then
            print("Återvänder till start...")
            returnToStart(stepsTaken)
            print("Turtlen har återvänt till startpunkten.")
            return
        end
        
        -- Gräv ett 2x2-segment
        digStep()
        turtle.turnRight()
        digStep()
        turtle.back()
        turtle.turnLeft()

        -- Öka stegräknaren
        stepsTaken = stepsTaken + 1
    end

    -- Återvänd till startpunkten efter färdig grävning
    returnToStart(stepsTaken)
    print("Tunnel färdig! Turtlen är tillbaka vid startpunkten.")
end

-- Ange längden på tunneln (exempel: 10 block)
local tunnelLength = 10
digTunnel(tunnelLength)

