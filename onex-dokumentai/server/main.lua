ESX = exports['es_extended']:getSharedObject()

lib.callback.register('onex-dokumentai:create', function(source, data)
    if type(data) == "table" and type(data.data) == "table" then
        data = data.data -- Extract correct table
    end

    if type(data) ~= "table" or not data.type then
        print("[onex-dokumentai] ⚠️ Klaida: Netinkami duomenys! Gauti duomenys:", json.encode(data or {}))
        return false, "Klaida: Netinkami duomenys"
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, "Žaidėjas nerastas" end

    local documentType = data.type
    local price = Config.DocPrices.Prices[documentType]

    if not price then
        print(("[onex-dokumentai] ⚠️ Klaida: Dokumento tipas '%s' nerastas Config'e."):format(documentType))
        return false, "Dokumento tipas nerastas"
    end

    -- 🚦 **Check if Required License Exists**
    if Config.DocPrices.RequiredLicenses[documentType] then
        local requiredLicense = Config.DocPrices.RequiredLicenses[documentType]
        local hasRequiredLicense = false

        -- 🔥 **Server-Side License Check** (FIXED!)
        TriggerEvent('esx_license:getLicenses', source, function(licenses)
            if not licenses then licenses = {} end -- Ensure licenses is a table

            for _, license in ipairs(licenses) do
                if license.type == requiredLicense then
                    hasRequiredLicense = true
                    break
                end
            end

            if not hasRequiredLicense then
                TriggerClientEvent('ox_lib:notify', source, {
                    title = 'Klaida',
                    description = 'Jūs neturite reikiamos licencijos (' .. requiredLicense .. ')!',
                    type = 'error'
                })
                return
            end

            -- 💰 **Check if Player Has Enough Money**
            if xPlayer.getAccount('bank').money >= price then
                xPlayer.removeAccountMoney('bank', price)

                -- 👤 **Handle Name Changes**
                if documentType == 'vardas' or documentType == 'pavarde' then
                    local newName = data.input
                    if not newName or #newName < 2 or #newName > 20 then
                        TriggerClientEvent('ox_lib:notify', source, {
                            title = 'Klaida',
                            description = 'Netinkamas vardas ar pavardė.',
                            type = 'error'
                        })
                        return
                    end

                    print(("[LOG] Žaidėjas %s (%s) pakeitė savo %s į: %s")
                        :format(xPlayer.getName(), xPlayer.identifier, documentType == 'vardas' and "vardą" or "pavardę", newName))

                    if documentType == 'vardas' then
                        MySQL.update('UPDATE users SET firstname = ? WHERE identifier = ?', { newName, xPlayer.identifier })
                    else
                        MySQL.update('UPDATE users SET lastname = ? WHERE identifier = ?', { newName, xPlayer.identifier })
                    end
                else
                    MySQL.insert('INSERT INTO user_licenses (owner, type) VALUES (?, ?)', {
                        xPlayer.identifier, documentType
                    })
                end

                -- 🎉 **Success Notification**
                TriggerClientEvent('ox_lib:notify', source, {
                    title = 'Dokumentas sukurtas',
                    description = 'Jūsų dokumentas buvo sėkmingai sukurtas!',
                    type = 'success'
                })
            else
                TriggerClientEvent('ox_lib:notify', source, {
                    title = 'Nepakanka pinigų',
                    description = 'Jūsų banko sąskaitoje trūksta lėšų!',
                    type = 'error'
                })
            end
        end)
    else
        -- **If no license is required, continue as normal**
        if xPlayer.getAccount('bank').money >= price then
            xPlayer.removeAccountMoney('bank', price)

            if documentType == 'vardas' or documentType == 'pavarde' then
                local newName = data.input
                if not newName or #newName < 2 or #newName > 20 then
                    TriggerClientEvent('ox_lib:notify', source, {
                        title = 'Klaida',
                        description = 'Netinkamas vardas ar pavardė.',
                        type = 'error'
                    })
                    return
                end

                print(("[LOG] Žaidėjas %s (%s) pakeitė savo %s į: %s")
                    :format(xPlayer.getName(), xPlayer.identifier, documentType == 'vardas' and "vardą" or "pavardę", newName))

                if documentType == 'vardas' then
                    MySQL.update('UPDATE users SET firstname = ? WHERE identifier = ?', { newName, xPlayer.identifier })
                else
                    MySQL.update('UPDATE users SET lastname = ? WHERE identifier = ?', { newName, xPlayer.identifier })
                end
            else
                MySQL.insert('INSERT INTO user_licenses (owner, type) VALUES (?, ?)', {
                    xPlayer.identifier, documentType
                })
            end

            -- 🎉 **Success Notification**
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Dokumentas sukurtas',
                description = 'Jūsų dokumentas buvo sėkmingai sukurtas!',
                type = 'success'
            })
        else
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Nepakanka pinigų',
                description = 'Jūsų banko sąskaitoje trūksta lėšų!',
                type = 'error'
            })
        end
    end
end)


-- 🔍 **Check if Player Already Has a Document**
lib.callback.register('onex-dokumentai:check', function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false, 'Žaidėjas nerastas.', false
    end

    local result = MySQL.scalar.await('SELECT COUNT(*) FROM user_licenses WHERE owner = ? AND type = ?', {
        xPlayer.identifier, data.type
    })

    if result and result > 0 then
        return false, 'Jūs jau turite šį dokumentą.', false
    else
        return true, 'Galite gauti naują dokumentą.', true
    end
end)

RegisterNetEvent('onex-dokumentai:show-player', function(targetId, dataType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        print("[ERROR] Player not found:", src)
        return
    end

    local documentData = {}

    -- Check which type of document is being requested
    if dataType == 'teises' then
        documentData = {
            type = 'teises',
            duomenys = {
                firstname = xPlayer.get('firstName') or 'Jonas',
                lastname = xPlayer.get('lastName') or 'Jonaitis',
                birth = xPlayer.get('dateofbirth') or '2000-01-01',
                given = '2023-01-01', -- Replace with actual given date if stored in DB
                valid = '2026-01-01', -- Replace with actual expiry date if stored
                code = 'LT' .. math.random(100000, 999999), -- Generate fake ID
                cardnumber = tostring(math.random(10000000, 99999999)), -- Random card number
                categories = "B, A1"
            }
        }
    elseif dataType == 'tapatybe' then
        documentData = {
            type = 'tapatybe',
            duomenys = {
                firstname = xPlayer.get('firstName') or 'Jonas',
                lastname = xPlayer.get('lastName') or 'Jonaitis',
                birth = xPlayer.get('dateofbirth') or '2000-01-01',
                code = 'LT' .. math.random(100000, 999999),
                cardnumber = tostring(math.random(10000000, 99999999)),
                valid = os.date('%Y-%m-%d', os.time() + (5 * 365 * 24 * 60 * 60)), -- Expires in 5 years
            }
        }
    else
        print("[ERROR] Unknown document type:", dataType)
        return
    end

    print("[DEBUG] Sending document menu event to client:", json.encode(documentData))

    -- Instead of triggering `show-player`, we now trigger `showMenu`
    TriggerClientEvent('onex-dokumentai:showMenu', targetId, documentData, dataType)
end)


ESX = exports["es_extended"]:getSharedObject()

-- Fetch document data based on type
RegisterNetEvent('onex-dokumentai:getDocument', function(docType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local identifier = xPlayer.identifier
    local firstName, lastName, birthDate = 'Jonas', 'Jonaitis', '2000-01-01' -- Default fallback values

    -- Fetch real data from users database
    local result = MySQL.single.await('SELECT firstname, lastname, dateofbirth FROM users WHERE identifier = ?', { identifier })
    if result then
        firstName = result.firstname
        lastName = result.lastname
        birthDate = result.dateofbirth
    end

    local documentData = {}

    if docType == 'teises' then
        documentData = {
            type = 'teises',
            duomenys = {
                firstname = firstName,
                lastname = lastName,
                birth = birthDate,
                given = '2023-01-01',
                valid = '2026-01-01',
                code = 'LT' .. math.random(100000, 999999),
                cardnumber = tostring(math.random(10000000, 99999999)),
                categories = "B, A1"
            }
        }
    elseif docType == 'tapatybe' then
        documentData = {
            type = 'tapatybe',
            duomenys = {
                firstname = firstName,
                lastname = lastName,
                birth = birthDate,
                given = '2023-01-01',
                valid = '2030-01-01',
                code = 'ID' .. math.random(100000, 999999),
                cardnumber = tostring(math.random(10000000, 99999999))
            }
        }
    else
        print(("[ERROR] Unknown document type requested: %s"):format(json.encode(docType)))
        return
    end

    print(("[DEBUG] Sending `%s` data to client ID %s: %s"):format(docType, src, json.encode(documentData)))

    -- Send the document data back to the client
    TriggerClientEvent('onex-dokumentai:receiveDocument', src, documentData, docType)
end)

-- Function to show the document to a nearby player
RegisterNetEvent('onex-dokumentai:showToNearby', function(targetId, docType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local identifier = xPlayer.identifier
    local firstName, lastName, birthDate = 'Jonas', 'Jonaitis', '2000-01-01' -- Default fallback values

    -- Fetch real data from database
    local result = MySQL.single.await('SELECT firstname, lastname, dateofbirth FROM users WHERE identifier = ?', { identifier })
    if result then
        firstName = result.firstname
        lastName = result.lastname
        birthDate = result.dateofbirth
    end

    local documentData = {}

    if docType == 'teises' then
        documentData = {
            type = 'teises',
            duomenys = {
                firstname = firstName,
                lastname = lastName,
                birth = birthDate,
                given = '2023-01-01',
                valid = '2026-01-01',
                code = 'LT' .. math.random(100000, 999999),
                cardnumber = tostring(math.random(10000000, 99999999)),
                categories = "B, A1"
            }
        }
    elseif docType == 'tapatybe' then
        documentData = {
            type = 'tapatybe',
            duomenys = {
                firstname = firstName,
                lastname = lastName,
                birth = birthDate,
                given = '2023-01-01',
                valid = '2030-01-01',
                code = 'ID' .. math.random(100000, 999999),
                cardnumber = tostring(math.random(10000000, 99999999))
            }
        }
    else
        print(("[ERROR] Unknown document type requested: %s"):format(json.encode(docType)))
        return
    end

    print(("[DEBUG] Sending `%s` data to nearby player %s: %s"):format(docType, targetId, json.encode(documentData)))

    -- Send the document to the target player (nearby player)
    TriggerClientEvent('onex-dokumentai:receiveDocument', targetId, documentData, docType)
end)

-- Export functions for `teises` and `tapatybe`
exports('teises', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end

    TriggerClientEvent('onex-dokumentai:getDocument', source, 'teises')
end)

exports('tapatybe', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end

    TriggerClientEvent('onex-dokumentai:getDocument', source, 'tapatybe')
end)
