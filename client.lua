ESX = exports['es_extended']:getSharedObject()

local infoMarkers = {}
local defaultDistance = Config.DefaultDistance

RegisterNetEvent('info_markers:updateMarkers')
AddEventHandler('info_markers:updateMarkers', function(markers)
    infoMarkers = markers
end)

RegisterNetEvent('info_markers:sendTime')
AddEventHandler('info_markers:sendTime', function(dateTime, marker)
    local locale = Config.Locales[Config.Locale]
    TriggerEvent('chat:addMessage', {
        color = { 255, 255, 255 },
        multiline = false,
        args = { locale['info_message'], string.format(locale['phone_display'], dateTime, marker.phone, marker.text) }
    })
end)

if Config.UsePostalFeature then
    RegisterNetEvent('info_markers:setWaypoint')
    AddEventHandler('info_markers:setWaypoint', function(x, y)
        SetNewWaypoint(x, y)
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for index, marker in ipairs(infoMarkers) do
            local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, marker.x, marker.y, marker.z)
            
            if distance < defaultDistance then
                DrawMarker(32, marker.x, marker.y, marker.z, 0, 0, 0, 0, 0, 0, 0.7, 0.7, 0.7, 255, 255, 255, 255, false, true, 2, nil, nil, false)
                
                if distance < 1.5 and not marker.messageShown then
                    TriggerServerEvent('info_markers:requestTime', marker)
                    marker.messageShown = true
                end

                if Config.UsePostalFeature and IsControlJustReleased(0, 38) then
                    TriggerServerEvent('info_markers:triggerPostalCommand', marker.postal)
                end
            else
                marker.messageShown = false
            end
        end
    end
end)

RegisterCommand('listinfo', function()
    for index, marker in ipairs(infoMarkers) do
        TriggerEvent('chat:addMessage', {
            args = { '^4[HELP]', string.format("Index: %d - Location: [%.2f, %.2f, %.2f] - Phone: %s - Postal: %s - Text: %s - Distance: %d", index, marker.x, marker.y, marker.z, marker.phone, marker.postal, marker.text, marker.displayDistance) }
        })
    end
end, false)

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/infom', 'Create an info marker', {
        { name = 'phone', help = 'The phone number to display' },
        { name = 'postal', help = 'The postal code' },
        { name = 'text', help = 'The text to display' }
    })
    
    TriggerEvent('chat:addSuggestion', '/deleteinfo', 'Delete an info marker', {
        { name = 'index', help = 'The index of the marker to delete' }
    })
    
    TriggerEvent('chat:addSuggestion', '/listinfo', 'List all info markers')
end)
