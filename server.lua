local lang = Languages[Config.language] -- Get the language based on the Config value

-- Function to handle the /me command
local function onMeCommand(source, args)
    local text = "* " .. lang.prefix .. table.concat(args, " ") .. " *" -- Construct the formatted text
    TriggerClientEvent('eeme:shareDisplay', -1, text, source) -- Share the display text with all clients
end

RegisterCommand(lang.commandName, onMeCommand) -- Register the /me command

