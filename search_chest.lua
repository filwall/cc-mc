-- ============================================================
--  ChestNet  |  Network Inventory Search  |  CC:Tweaked
-- ============================================================
--  Setup:
--    1. Place a wired modem next to each chest
--    2. Right-click each modem to activate it (turns green)
--    3. Run this program on the central computer
--
--  Controls:
--    Type / Backspace   -> Live search
--    Click buttons      -> Refresh / Rename / Quit
--    F5 / F2 / Esc      -> Same via keyboard
-- ============================================================

local LABEL_FILE  = "chestnet_labels.json"
local CACHE_FILE  = "chestnet_cache.json"
local isAdv = term.isColor and term.isColor()

local C = {
    title  = isAdv and colors.yellow   or colors.white,
    chest  = isAdv and colors.cyan     or colors.white,
    item   = isAdv and colors.white    or colors.white,
    count  = isAdv and colors.orange   or colors.white,
    found  = isAdv and colors.lime     or colors.white,
    input  = isAdv and colors.cyan     or colors.white,
    dim    = isAdv and colors.gray     or colors.white,
    err    = isAdv and colors.red      or colors.white,
    btnBg  = isAdv and colors.gray     or colors.white,
    btnFg  = isAdv and colors.white    or colors.black,
    btnHot = isAdv and colors.lightGray or colors.white,
}

local function col(fg, bg)
    if isAdv then
        if fg then term.setTextColor(fg) end
        if bg then term.setBackgroundColor(bg) end
    end
end
local function reset()
    if isAdv then
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
    end
end
local function twrite(text, fg, bg) col(fg, bg); io.write(text); reset() end
local function tprint(text, fg)     col(fg);     print(text or ""); reset() end

-- ── Buttons ───────────────────────────────────────────────────

local buttons = {}

local function makeButton(label, x, y, action)
    local w = #label + 2
    table.insert(buttons, { label = label, x = x, y = y, w = w, action = action })
    return x + w
end

local function drawButton(btn, highlight)
    term.setCursorPos(btn.x, btn.y)
    col(C.btnFg, highlight and C.btnHot or C.btnBg)
    io.write(" " .. btn.label .. " ")
    reset()
end

local function getClickedAction(mx, my)
    for _, btn in ipairs(buttons) do
        if my == btn.y and mx >= btn.x and mx < btn.x + btn.w then
            return btn.action
        end
    end
end

local function flashButton(action)
    for _, btn in ipairs(buttons) do
        if btn.action == action then
            drawButton(btn, true)
            os.sleep(0.1)
            drawButton(btn, false)
            reset()
            break
        end
    end
end

-- ── Labels ────────────────────────────────────────────────────

local labels = {}

local function loadLabels()
    if not fs.exists(LABEL_FILE) then return end
    local f = fs.open(LABEL_FILE, "r")
    local ok, data = pcall(textutils.unserialiseJSON, f.readAll())
    f.close()
    if ok and data then labels = data end
end

local function saveLabels()
    local f = fs.open(LABEL_FILE, "w")
    f.write(textutils.serialiseJSON(labels))
    f.close()
end

local function getLabel(name) return labels[name] or name end

-- ── Chest discovery ───────────────────────────────────────────

local function findInventories()
    local SIDES={left=true,right=true,top=true,bottom=true,front=true,back=true}
    local found = {}
    for _, name in ipairs(peripheral.getNames()) do
        if not SIDES[name] then
            local t = peripheral.getType(name) or ""
            if not t:find("modem") and not t:find("computer") and not t:find("turtle") then
                local p = peripheral.wrap(name)
                if p and type(p.list) == "function" then
                    table.insert(found, name)
                end
            end
        end
    end
    table.sort(found)
    return found
end

-- ── Display name from item ID (no network call needed) ────────
-- "minecraft:iron_ingot" -> "Iron Ingot"
-- "create:brass_ingot"   -> "Brass Ingot"
local function makeDisplayName(itemName)
    local base = itemName:match(":(.+)$") or itemName
    base = base:gsub("_", " ")
    return base:gsub("(%a)([%w]*)", function(a, b)
        return a:upper() .. b:lower()
    end)
end

-- Items where the display name carries important info (NBT-based names).
-- For these we call getItemDetail. For everything else we use the fast path.
local NEEDS_DETAIL = {
    ["minecraft:enchanted_book"]    = true,
    ["minecraft:potion"]            = true,
    ["minecraft:splash_potion"]     = true,
    ["minecraft:lingering_potion"]  = true,
    ["minecraft:tipped_arrow"]      = true,
    ["minecraft:written_book"]      = true,
}

-- ── Scanning (getItemDetail only where it matters) ────────────

local function scanChest(name)
    local p = peripheral.wrap(name)
    if not p then return {} end
    local ok, list = pcall(p.list)
    if not ok or not list then return {} end
    local items = {}
    for slot, item in pairs(list) do
        local displayName = makeDisplayName(item.name)
        if NEEDS_DETAIL[item.name] then
            pcall(function()
                local d = p.getItemDetail(slot)
                if d and d.displayName then displayName = d.displayName end
            end)
        end
        table.insert(items, {
            name        = item.name,
            displayName = displayName,
            count       = item.count,
            slot        = slot,
        })
    end
    return items
end

-- ── Cache: save/load scan results ────────────────────────────

local function saveCache(data, time, numChests)
    local f = fs.open(CACHE_FILE, "w")
    f.write(textutils.serialiseJSON({ time=time, chests=numChests, data=data }))
    f.close()
end

local function loadCache()
    if not fs.exists(CACHE_FILE) then return nil, nil end
    local f = fs.open(CACHE_FILE, "r")
    local content = f.readAll()
    f.close()
    local ok, d = pcall(textutils.unserialiseJSON, content)
    if ok and d and d.data then return d.data, d.time end
    return nil, nil
end

local function scanAll(inventories)
    local w = term.getSize()
    local data = {}
    local _, y = term.getCursorPos()
    for i, name in ipairs(inventories) do
        term.setCursorPos(1, y)
        term.clearLine()
        local s = string.format("[%d/%d] Scanning: %s", i, #inventories, getLabel(name))
        twrite(s:sub(1, w - 1), C.dim)
        data[name] = scanChest(name)
    end
    term.setCursorPos(1, y)
    term.clearLine()
    return data
end

-- ── Search ────────────────────────────────────────────────────

-- Relevance score (lower = better match):
--   0  exact display name match        "Book"         query "book"
--   1  display name starts with query  "Book and Quill"
--   2  item ID ends with query         "minecraft:book"
--   3  word boundary in display name   "Pocket Book"
--   4  anywhere in display name        "Enchanted Book"
--   5  only matches item ID            "minecraft:bookshelf"
local function matchScore(item, q)
    local dn = item.displayName:lower()
    local id = item.name:lower()
    if dn == q then return 0 end
    if dn:sub(1, #q) == q then return 1 end
    if id:match(":(.-)$") == q then return 2 end
    if dn:find("%s"..q) or dn:find("_"..q) then return 3 end
    if dn:find(q, 1, true) then return 4 end
    return 5
end

local function searchItems(data, query)
    if query == "" then return {} end
    local q = query:lower()
    local results = {}
    for chestName, items in pairs(data) do
        for _, item in ipairs(items) do
            if item.name:lower():find(q, 1, true)
            or item.displayName:lower():find(q, 1, true) then
                table.insert(results, {
                    chest       = chestName,
                    label       = getLabel(chestName),
                    name        = item.name,
                    displayName = item.displayName,
                    count       = item.count,
                    slot        = item.slot,
                    score       = matchScore(item, q),
                })
            end
        end
    end
    table.sort(results, function(a, b)
        if a.score ~= b.score then return a.score < b.score end
        if a.displayName:lower() ~= b.displayName:lower() then
            return a.displayName:lower() < b.displayName:lower()
        end
        return a.label < b.label
    end)
    return results
end

-- ── Draw ──────────────────────────────────────────────────────

local function drawScreen(query, results, numChests, refreshTime)
    local w, h = term.getSize()
    buttons = {}
    term.clear()

    -- Title bar
    term.setCursorPos(1, 1)
    twrite("ChestNet", C.title)
    twrite("  " .. numChests .. " chests", C.dim)
    if refreshTime then
        local t = "updated " .. refreshTime
        term.setCursorPos(w - #t, 1)
        twrite(t, C.dim)
    end

    -- Divider
    term.setCursorPos(1, 2)
    twrite(string.rep("\140", w), C.dim)

    -- Search bar
    term.setCursorPos(1, 3)
    twrite("Search: ", C.input)
    twrite(query, C.item)
    twrite("_", C.dim)

    -- Divider
    term.setCursorPos(1, 4)
    twrite(string.rep("\140", w), C.dim)

    -- Results
    local row = 5
    local maxRow = h - 3

    if query == "" then
        term.setCursorPos(1, row)
        twrite("Start typing to search all chests...", C.dim)
    elseif #results == 0 then
        term.setCursorPos(1, row)
        twrite('No results for: "' .. query .. '"', C.err)
    else
        local total = 0
        for _, r in ipairs(results) do total = total + r.count end

        term.setCursorPos(1, row)
        twrite(#results .. " slot(s)   ", C.found)
        twrite("Total: " .. total, C.count)
        row = row + 1

        local grouped, order = {}, {}
        for _, r in ipairs(results) do
            if not grouped[r.chest] then
                grouped[r.chest] = { total = 0, items = {} }
                table.insert(order, r.chest)
            end
            grouped[r.chest].total = grouped[r.chest].total + r.count
            table.insert(grouped[r.chest].items, r)
        end

        for _, chest in ipairs(order) do
            if row > maxRow then
                term.setCursorPos(1, row)
                twrite("  ... (refine search to see more)", C.dim)
                break
            end
            local g = grouped[chest]
            term.setCursorPos(1, row)
            twrite("  > ", C.chest)
            twrite(getLabel(chest), C.chest)
            twrite("  " .. g.total .. " item(s)", C.count)
            row = row + 1

            for _, item in ipairs(g.items) do
                if row > maxRow then break end
                term.setCursorPos(1, row)
                twrite(string.format("      x%-5d", item.count), C.count)
                local s = item.displayName .. "  [slot " .. item.slot .. "]"
                twrite(s:sub(1, w - 13), C.item)
                row = row + 1
            end
        end
    end

    -- Footer
    term.setCursorPos(1, h - 1)
    twrite(string.rep("\140", w), C.dim)
    term.setCursorPos(1, h)
    local x = 1
    x = makeButton("Refresh",  x, h, "refresh") + 1
    x = makeButton("Rename",   x, h, "label")   + 1
        makeButton("Quit",     x, h, "quit")
    for _, btn in ipairs(buttons) do drawButton(btn, false) end
    reset()
end

-- ── Rename chests ─────────────────────────────────────────────

local function renameMenu(inventories)
    while true do
        term.clear()
        term.setCursorPos(1, 1)
        tprint("=== Rename Chests ===", C.title)
        tprint("Give chests friendly names, e.g. 'Iron', 'Food'.", C.dim)
        tprint("")
        for i, name in ipairs(inventories) do
            twrite(string.format("%2d. ", i), C.count)
            twrite(name, C.dim)
            if labels[name] then twrite("  ->  " .. labels[name], C.chest) end
            tprint("")
        end
        tprint("")
        twrite("Number (Q = back): ", C.input)
        local inp = read()
        if inp:lower() == "q" or inp == "" then break end
        local idx = tonumber(inp)
        if idx and inventories[idx] then
            local name = inventories[idx]
            twrite('New name for "' .. name .. '": ', C.input)
            local newLabel = read()
            if newLabel == "" then
                labels[name] = nil
                tprint("Label removed.", C.dim)
            else
                labels[name] = newLabel
                tprint("Saved: " .. newLabel, C.found)
            end
            saveLabels()
            os.sleep(0.6)
        end
    end
end

-- ── Main ──────────────────────────────────────────────────────

loadLabels()

term.clear()
term.setCursorPos(1, 1)
tprint("=== ChestNet ===", C.title)
tprint("")
tprint("Searching for chests on the network...", C.dim)
tprint("")

local inventories = findInventories()

if #inventories == 0 then
    tprint("No chests found!", C.err)
    tprint("")
    tprint("Make sure wired modems are placed next to", C.dim)
    tprint("each chest and activated (right-click).", C.dim)
    tprint("")
    tprint("Press any key...", C.dim)
    os.pullEvent("key")
    return
end

local REFRESH_INTERVAL = 30  -- auto-refresh every 30 seconds

tprint(#inventories .. " chest(s) found! Scanning...", C.found)
tprint("")

local cache       = scanAll(inventories)
local refreshTime = os.date("%H:%M:%S")
saveCache(cache, refreshTime, #inventories)
local query       = ""
local results     = {}

drawScreen(query, results, #inventories, refreshTime)

local refreshTimer = os.startTimer(REFRESH_INTERVAL)

while true do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "timer" and p1 == refreshTimer then
        -- Auto-refresh every 30 seconds
        inventories = findInventories()
        cache = scanAll(inventories)
        refreshTime = os.date("%H:%M:%S")
        saveCache(cache, refreshTime, #inventories)
        results = searchItems(cache, query)
        drawScreen(query, results, #inventories, refreshTime)
        refreshTimer = os.startTimer(REFRESH_INTERVAL)

    elseif event == "char" then
        query = query .. p1
        results = searchItems(cache, query)
        drawScreen(query, results, #inventories, refreshTime)

    elseif event == "key" then
        if p1 == keys.backspace and #query > 0 then
            query = query:sub(1, -2)
            results = searchItems(cache, query)
            drawScreen(query, results, #inventories, refreshTime)
        elseif p1 == keys.escape then
            break
        elseif p1 == keys.f5 then
            flashButton("refresh")
            inventories = findInventories()
            cache = scanAll(inventories)
            refreshTime = os.date("%H:%M:%S")
            saveCache(cache, refreshTime, #inventories)
            results = searchItems(cache, query)
            drawScreen(query, results, #inventories, refreshTime)
            refreshTimer = os.startTimer(REFRESH_INTERVAL)
        elseif p1 == keys.f2 then
            flashButton("label")
            renameMenu(inventories)
            for _, r in ipairs(results) do r.label = getLabel(r.chest) end
            drawScreen(query, results, #inventories, refreshTime)
        end

    elseif event == "mouse_click" then
        local action = getClickedAction(p2, p3)
        if action == "refresh" then
            flashButton("refresh")
            inventories = findInventories()
            cache = scanAll(inventories)
            refreshTime = os.date("%H:%M:%S")
            saveCache(cache, refreshTime, #inventories)
            results = searchItems(cache, query)
            drawScreen(query, results, #inventories, refreshTime)
            refreshTimer = os.startTimer(REFRESH_INTERVAL)
        elseif action == "label" then
            flashButton("label")
            renameMenu(inventories)
            for _, r in ipairs(results) do r.label = getLabel(r.chest) end
            drawScreen(query, results, #inventories, refreshTime)
        elseif action == "quit" then
            flashButton("quit")
            break
        end
    end
end

term.clear()
term.setCursorPos(1, 1)
tprint("ChestNet closed.", C.dim)
