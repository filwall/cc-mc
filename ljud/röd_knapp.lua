local volume = 15
local fil = "fucked_up.dfpwm"
local input = "top"

local prev = redstone.getInput(input)

local detect = peripheral.wrap("front")
local chat = peripheral.wrap("back")

while true do
    os.pullEvent("redstone")
    os.sleep(0.1)

    local cur = redstone.getInput(input)
    if cur and not prev then
        local dfpwm = require("cc.audio.dfpwm")
        local s = peripheral.find("speaker")
        if not s then
            print("Ingen speaker hittad!")
        else
            local decoder = dfpwm.make_decoder()
            for chunk in io.lines(fil, 16 * 1024) do
                local buffer = decoder(chunk)
                while not s.playAudio(buffer, volume) do
                    os.pullEvent("speaker_audio_empty")
                end
            end
        end
        local player = detect.getPlayersInRange(7)[1]
        chat.sendMessage(player .. " pressed the Red Button")
        os.sleep(0.1)
    end
    prev = cur
end
