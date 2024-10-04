if Vision.Debug then
    local filename = function()
        local str = debug.getinfo(2, "S").source:sub(2)
        return str:match("^.*/(.*).lua$") or str
    end
    print("^1[DEBUG]^0 ^3-^0 "..filename()..".lua^0 ^2Loaded^0!");
end

print("^6[Vision-NameChange]^0 ^2Started Successfully!^0")
print("^6[Vision-NameChange]^0 ^2Thanks for using Vision-NameChange!^0")
print("^6[Vision-NameChange]^0 ^1If you need support: https://discord.gg/QjekMe2B5A^0")
print("^6[Vision-NameChange]^0 ^1Made by Kugelpsitzer^0")

SetConvarServerInfo('tags', 'Vision-Scripts')

RegisterServerEvent("Vision_NameChange:changeName")
AddEventHandler("Vision_NameChange:changeName", function(data)
    local xPlayer = ESX.GetPlayerFromId(source)
    local source = source
    if xPlayer then
        local firstname = data.firstname
        local lastname = data.lastname

        if firstname and lastname and firstname ~= "" and lastname ~= "" then
            local identifier = xPlayer.identifier

            if identifier and identifier:sub(1, 8) == "license:" then
                identifier = identifier:gsub("license:", "")
            end

            local account = xPlayer.getAccount('money')
            if account and account.money >= Vision.NameChangeCost then
                if identifier and identifier ~= "" then
                    local userInfo = MySQL.single.await('SELECT `firstname`, `lastname` FROM `users` WHERE `identifier` = ? LIMIT 1', {
                        identifier
                    })

                    if userInfo then
                        local oldFirstname = userInfo.firstname
                        local oldLastname = userInfo.lastname

                        MySQL.Async.execute('UPDATE users SET firstname = @firstname, lastname = @lastname WHERE identifier = @identifier', {
                            ['@firstname'] = firstname,
                            ['@lastname'] = lastname,
                            ['@identifier'] = identifier
                        }, function(rowsChanged)
                            if rowsChanged > 0 then
                                xPlayer.removeAccountMoney('money', Vision.NameChangeCost)
                                print(("Name Changed: %s %s [Identifier: %s]"):format(firstname, lastname, identifier))

                                if Vision.DiscordNotify then
                                    local webhook = Vision.Webhook
                                    local name = GetPlayerName(source)
                                    local steam = GetPlayerIdentifier(source, 0)
                                    local discord = GetPlayerIdentifier(source, 1)
                                    local id = source

                                    local VisionMessage = {
                                        embeds = {{
                                            title = "Vision - Change Name",
                                            description = "A player's name has been changed.",
                                            fields = {
                                                {name = "Player:", value = "```[" .. id .. "] " .. name .. "```"},
                                                {name = "Identifier:", value = "```" .. identifier .. "```"},
                                                {name = "Old Firstname:", value = "```" .. oldFirstname .. "```"},
                                                {name = "Old Lastname:", value = "```" .. oldLastname .. "```"},
                                                {name = "New Firstname:", value = "```" .. firstname .. "```"},
                                                {name = "New Lastname:", value = "```" .. lastname .. "```"}
                                            },
                                            footer = {
                                                text = "Vision - Change Name • Made by Kugelspitzer"
                                            },
                                            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                                            color = 0x6f249e
                                        }}
                                    }

                                    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode(VisionMessage), {['Content-Type'] = 'application/json'})
                                end

                                if source then
                                    TriggerClientEvent("esx:showNotification", source, "Your name has been successfully changed to ~g~ " .. firstname .. " " .. lastname .. "~s~!")
                                end
                            else
                                if source then
                                    TriggerClientEvent("esx:showNotification", source, "Error changing name!")
                                end
                            end
                        end)
                    end
                end
            else
                if source then
                    TriggerClientEvent("esx:showNotification", source, "You need at least ~r~ $" .. Vision.NameChangeCost .. " ~s~ money to change your name!")
                end
            end
        else
            if source then
                TriggerClientEvent("esx:showNotification", source, "Invalid name entry!")
            end
        end
    end
end)

RegisterCommand("changename", function(source, args, rawCommand)
    if source == 0 or (ESX.GetPlayerFromId(source) and ESX.GetPlayerFromId(source).getGroup() == Vision.Group) then
        if args[1] and tonumber(args[1]) then
            local targetId = tonumber(args[1])
            local xPlayer = ESX.GetPlayerFromId(targetId)

            if xPlayer then
                local playerMoney = xPlayer.getMoney()
                local moneyAction = ""

                if playerMoney < 20000 then
                    local missingAmount = 20000 - playerMoney

                    TriggerClientEvent("esx:showNotification", targetId, "You were credited $" .. missingAmount .. " for a name change!")

                    xPlayer.addMoney(missingAmount)
                    moneyAction = "Added $" .. missingAmount .. " to meet the requirement of $20,000."
                else
                    moneyAction = "Player already has sufficient money: $" .. playerMoney
                end

                openAdminNameMenu(targetId)

                if Vision.DiscordNotify then
                    local webhook = Vision.Webhook
                    local adminName = source == 0 and "[CONSOLE]" or GetPlayerName(source)
                    local adminGroup = source == 0 and "CONSOLE" or ESX.GetPlayerFromId(source).getGroup()
                    local playerName = GetPlayerName(targetId)
                    local playerSteam = GetPlayerIdentifier(targetId, 0)
                    local adminSteam = source ~= 0 and GetPlayerIdentifier(source, 0) or "N/A"
                    local discordId = source ~= 0 and string.gsub(GetPlayerIdentifier(source, 1) or "N/A", "discord:", "") or nil

                    local fields = {
                        {name = "Admin Info:", value = "```[ID: " .. source .. "] [" .. adminGroup .. "] " .. adminName .. "```", inline = true},
                        {name = "Admin Identifier:", value = "```" .. adminSteam .. "```", inline = true},
                        {name = "Player Info:", value = "```[ID: " .. targetId .. "] " .. playerName .. "```", inline = true},
                        {name = "Player Identifier:", value = "```" .. playerSteam .. "```", inline = true},
                        {name = "Player's Current Money:", value = "```$" .. playerMoney .. "```", inline = true},
                        {name = "Financial Action Taken:", value = "```" .. moneyAction .. "```", inline = false}
                    }

                    if discordId then
                        table.insert(fields, 1, {name = "Discord Admin:", value = "<@" .. discordId .. ">", inline = false})
                    end

                    local VisionMessage = {
                        embeds = { {
                            title = "Name Change & Financial Action Alert",
                            description = "An admin initiated a name change process and reviewed the player's finances.",
                            fields = fields,
                            footer = {
                                text = "Vision - Name Change & Finance • Made by Kugelspitzer"
                            },
                            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                            color = 0x6f249e
                        } }
                    }

                    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode(VisionMessage), { ['Content-Type'] = 'application/json' })
                end
            else
                TriggerClientEvent('esx:showNotification', source, "Invalid player ID!")
            end
        else
            if source ~= 0 then
                TriggerClientEvent('esx:showNotification', source, "Please provide a valid player ID!")
            else
                print("Please provide a valid player ID!")
            end
        end
    else
        if source ~= 0 then
            TriggerClientEvent('esx:showNotification', source, "Only admins can use this command!")
        else
            print("Only admins can use this command!")
        end
    end
end, true)

function openAdminNameMenu(targetSource)
    local xPlayer = ESX.GetPlayerFromId(targetSource)

    if not xPlayer then
        return
    end


    TriggerClientEvent('esx:showNotification', targetSource, "An admin has requested that you change your name. If you refuse, it may result in sanctions")

    TriggerClientEvent("Vision_NameChange:openAdminMenu", targetSource)
end