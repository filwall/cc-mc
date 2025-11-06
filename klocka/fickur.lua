while true do

    local tid = os.date("%H:%M")
    print(tid)
    os.sleep(5)
    term.clear()
    term.setCursorPos(1,1)
end
