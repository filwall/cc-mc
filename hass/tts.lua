local function special(s)
  if s:find("\195\165")   -- å
     or s:find("\195\164") -- ä
     or s:find("\195\182") -- ö
     or s:find("\195\133") -- Å
     or s:find("\195\132") -- Ä
     or s:find("\195\150") -- Ö
  then
    return true
  end

  -- En-byte kodningar (latin1/ISO-8859-1) för å, ä, ö
  if s:find("\229") -- å (0xE5)
     or s:find("\228") -- ä (0xE4)
     or s:find("\246") -- ö (0xF6)
     or s:find("\197") -- Å (0xC5)
     or s:find("\196") -- Ä (0xC4)
     or s:find("\214") -- Ö (0xD6)
  then
    return true
  end

  return false
end


while true do
        local webhookURL = "https://styrdon.se/api/webhook/-Kjvkr50PAyGN4ZxNpfH5cAzQ"
        term.clear()
        term.setCursorPos(1,1)
        io.write("Send Message: ")
        local msg = io.read()

        while special(msg) do
                term.clear()
                term.setCursorPos(1,1)
                print("Cannot use ÅÄÖ, try again: ")
                msg = io.read()

        end

        local body = string.format('{"message":"%s"}', msg)

        local headers = {
          ["Content-Type"] = "application/json"
        }

        http.post(webhookURL, body, headers)

end

