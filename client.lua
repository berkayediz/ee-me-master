local c = Config -- Store Config in a local variable for easier access
local lang = Languages[Config.language] -- Get the language based on the Config value
local peds = {} -- Create an empty table to store information about displayed texts
local GetGameTimer = GetGameTimer -- Store GetGameTimer function in a local variable for faster access

-- Function to draw 3D text
local function draw3dText(coords, text)
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    
    -- Calculate the scale of the text based on camera FOV and distance
    local scale = 200 / (GetGameplayCamFov() * dist)

    -- Set text properties
    SetTextColour(c.color.r, c.color.g, c.color.b, c.color.a)
    SetTextScale(0.0, c.scale * scale)
    SetTextFont(c.font)
    SetTextDropshadow(0, 0, 0, 0, 55)
    SetTextDropShadow()
    SetTextCentre(true)

    -- Begin displaying text
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

-- Function to display text above a ped
local function displayText(ped, text)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local targetPos = GetEntityCoords(ped)
    local dist = #(playerPos - targetPos)
    local los = HasEntityClearLosToEntity(playerPed, ped, 17)

    -- Check if the ped is within the distance and has line of sight
    if dist <= c.dist and los then
        local exists = peds[ped] ~= nil -- Check if the ped already has a displayed text

        -- Store the text information for the ped
        peds[ped] = {
            time = GetGameTimer() + c.time,
            text = text
        }

        -- If the ped doesn't have a displayed text, start displaying it
        if not exists then
            local display = true

            -- Loop until the display time is over
            while display do
                Wait(0)
                local pos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 1.0)
                draw3dText(pos, peds[ped].text)
                display = GetGameTimer() <= peds[ped].time
            end

            peds[ped] = nil -- Remove the stored text information after display time is over
        end
    end
end

-- Function to handle the event of sharing display text
local function onShareDisplay(text, target)
    local player = GetPlayerFromServerId(target)
    
    -- Check if the target player is valid or if it's the local player
    if player ~= -1 or target == GetPlayerServerId(PlayerId()) then
        local ped = GetPlayerPed(player)
        displayText(ped, text) -- Display the text above the ped
    end
end

-- Register the event handler for 'eeme:shareDisplay' event
RegisterNetEvent('eeme:shareDisplay', onShareDisplay)

-- Add command suggestion for the chat
TriggerEvent('chat:addSuggestion', '/' .. lang.commandName, lang.commandDescription, lang.commandSuggestion)
