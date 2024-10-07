local inMarker = false

local markerPos = Vision.Marker

if Vision.Debug then
    local filename = function()
        local str = debug.getinfo(2, "S").source:sub(2)
        return str:match("^.*/(.*).lua$") or str
    end
    print("^1[DEBUG]^0 ^3-^0 "..filename()..".lua^0 ^2Loaded^0!");
end

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Vision.Blip.Position.x, Vision.Blip.Position.y, Vision.Blip.Position.z)
    SetBlipSprite(blip, Vision.Blip.Sprite)
    SetBlipDisplay(blip, Vision.Blip.Display)
    SetBlipScale(blip, Vision.Blip.Scale)
    SetBlipColour(blip, Vision.Blip.Colour)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Vision.Blip.Name)
    EndTextCommandSetBlipName(blip)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        if GetDistanceBetweenCoords(coords, markerPos, true) < Vision.DrawDistance then
        
            DrawMarker(Vision.MarkerType, markerPos.x, markerPos.y, markerPos.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 155, 88, 242, 100, false, true, 2, nil, nil, false)

            if GetDistanceBetweenCoords(coords, markerPos, true) < 1.5 then
                ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to change your name")
                if IsControlJustReleased(0, 38) then
                    inMarker = true
                    SetNuiFocus(true, true)
                    SendNUIMessage({ action = 'openUI' })
                end
            end
        else
            Citizen.Wait(500)
        end
    end
end)

RegisterNUICallback("closeUI", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ hideAll = true })
    cb("ok")
end)

RegisterNUICallback("changeName", function(data, cb)
    TriggerServerEvent("Vision_NameChange:changeName", data)
    cb("ok")
end)

RegisterNetEvent("Vision_NameChange:openAdminMenu")
AddEventHandler("Vision_NameChange:openAdminMenu", function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openUI' })
end)

