gps_loc = {x = 10, y = 5, z = 0}  -- Målpunkten
 
function go_to_location()
    local x, y, z = gps.locate()  -- Hämta GPS-position
    if x and y and z then
        local x_dist = gps_loc.x - x
        local y_dist = gps_loc.y - y
        local z_dist = gps_loc.z - z
 
        -- Flytta till målpunkten genom att navigera varje axel
        move_to(x_dist, y_dist, z_dist)
    else
        print("Kan inte läsa GPS-position.")
    end
end
 
function move_to(x_dist, y_dist, z_dist)
    -- Flytta på X-axeln
    if x_dist > 0 then
        for i = 1, x_dist do
            turtle.forward()
        end
    elseif x_dist < 0 then
        for i = 1, -x_dist do
            turtle.back()
        end
    end
 
    -- Flytta på Y-axeln (uppåt eller nedåt)
    if y_dist > 0 then
        for i = 1, y_dist do
            turtle.up()
        end
    elseif y_dist < 0 then
        for i = 1, -y_dist do
            turtle.down()
        end
    end
 
    -- Flytta på Z-axeln (det kan vara att ändra riktning beroende på vilken mod du använder)
    -- Här kan du exempelvis behöva använda `turtle.forward()` om du har ett specifikt system för vertikal rörelse.
 
end
 
go_to_location()
