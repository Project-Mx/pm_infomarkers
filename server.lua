ESX = exports['es_extended']:getSharedObject()

local infoMarkers = {}
local postals = {}
local playerMarkers = {}

if Config.UsePostalFeature then
    CreateThread(function()
        postals = json.decode(LoadResourceFile(GetCurrentResourceName(), "postals.json"))
        for i = 1, #postals do
            local postal = postals[i]
            postals[i] = {
                coords = vector3(postal.x, postal.y, 0),
                code = postal.code
            }
        end
    end)

    function getPostal(code)
        for i = 1, #postals do
            if postals[i].code == code then
                return postals[i]
            end
        end
        return nil
    end
end

function isPlayerAuthorized(xPlayer)
    local playerGroup = xPlayer.getGroup()
    local playerJob = xPlayer.getJob().name
    for _, group in ipairs(Config.AdminGroups) do
        if playerGroup == group then
            return true
        end
    end
    for _, job in ipairs(Config.WhitelistJobs) do
        if playerJob == job then
            return true
        end
    end
    return false
end

RegisterCommand('infom', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and isPlayerAuthorized(xPlayer) then
        local identifier = xPlayer.getIdentifier()
        if not playerMarkers[identifier] then
            playerMarkers[identifier] = 0
        end

        if playerMarkers[identifier] >= Config.MarkerLimit then
            TriggerClientEvent('chat:addMessage', source, { args = { '^4[HELP]', Config.Locales[Config.Locale]['marker_limit'] } })
            return
        end

        if #args < 3 then
            TriggerClientEvent('chat:addMessage', source, { args = { '^4[HELP]', Config.Locales[Config.Locale]['usage'] } })
            return
        end

        local phone = args[1]
        local postal = args[2]
        local text = table.concat(args, " ", 3)
        local displayDistance = 5
        
        local playerCoords = GetEntityCoords(GetPlayerPed(source))
        table.insert(infoMarkers, { x = playerCoords.x, y = playerCoords.y, z = playerCoords.z, text = text, phone = phone, postal = postal, displayDistance = displayDistance })
        playerMarkers[identifier] = playerMarkers[identifier] + 1
        TriggerClientEvent('info_markers:updateMarkers', -1, infoMarkers)
        TriggerClientEvent('chat:addMessage', source, { args = { '^4[HELP]', Config.Locales[Config.Locale]['marker_created'] } })
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^4[HELP]', Config.Locales[Config.Locale]['no_permission'] } })
    end
end, false)

RegisterCommand('deleteinfo', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and isPlayerAuthorized(xPlayer) then
        local index = tonumber(args[1])
        if not index or not infoMarkers[index] then
            TriggerClientEvent('chat:addMessage', source, { args = { '^4[HELP]', Config.Locales[Config.Locale]['invalid_marker'] } })
            return
        end

        local identifier = xPlayer.getIdentifier()
        table.remove(infoMarkers, index)
        if playerMarkers[identifier] then
            playerMarkers[identifier] = playerMarkers[identifier] - 1
        end
        TriggerClientEvent('info_markers:updateMarkers', -1, infoMarkers)
        TriggerClientEvent('chat:addMessage', source, { args = { '^4[HELP]', Config.Locales[Config.Locale]['marker_deleted'] } })
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^4[HELP]', Config.Locales[Config.Locale]['no_permission'] } })
    end
end, false)

if Config.UsePostalFeature then
    RegisterServerEvent('info_markers:triggerPostalCommand')
    AddEventHandler('info_markers:triggerPostalCommand', function(postal)
        local source = source
        local postalData = getPostal(postal)
        if postalData then
            TriggerClientEvent('chat:addMessage', source, { args = { '^2POSTAL', string.format("Location Was Marked.", postal, postalData.coords.x, postalData.coords.y) } })
            TriggerClientEvent('info_markers:setWaypoint', source, postalData.coords.x, postalData.coords.y)
        else
            TriggerClientEvent('chat:addMessage', source, { args = { '^4[HELP]', Config.Locales[Config.Locale]['postal_not_found'] } })
        end
    end)
end

RegisterServerEvent('info_markers:requestTime')
AddEventHandler('info_markers:requestTime', function(marker)
    local source = source
    local dateTime = os.date("%a %Y-%m-%d %H:%M:%S")
    TriggerClientEvent('info_markers:sendTime', source, dateTime, marker)
end)

-- Get the current resource name
local currentResourceName = GetCurrentResourceName()

-- Define the expected resource name
local expectedResourceName = "pm_infomarkers"

-- Function to stop the resource if the name has changed
local function stopResourceIfNameChanged()
    if currentResourceName ~= expectedResourceName then
        print("The resource name has been changed from '" .. expectedResourceName .. "' to '" .. currentResourceName .. "'. Stopping the resource.")
        print('^1It is required to keep the resource name original. Please rename the resource back to "' .. expectedResourceName .. '".^0')
        StopResource(currentResourceName)
    end
end

-- Call the function to perform the check
stopResourceIfNameChanged()
