local monitor = peripheral.find("monitor")

if monitor then
    monitor.clear()  -- Rensa monitorn
    monitor.setTextScale(1)  -- Sätt textstorlek (kan ändras till 2 eller 3)
    monitor.setCursorPos(1, 1)  -- Sätt markören på övre vänstra hörnet
    monitor.write("Hej på dig!")  -- Skriv det ord eller meddelande du vill visa
else
    print("Ingen monitor kopplad.")
end
