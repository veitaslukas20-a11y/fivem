ESX = exports['es_extended']:getSharedObject()

lib.callback.register('esx_billing:getBills', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end

    local result = MySQL.Sync.fetchAll('SELECT * FROM billing WHERE identifier = ?', {xPlayer.identifier})
    local bills = {}

    for i=1, #result do
        local bill = result[i]
        table.insert(bills, {
            id = bill.id,
            label = bill.label or 'Unknown',
            amount = bill.amount or 0
        })
    end

    return bills
end)

lib.callback.register('esx_billing:payBill', function(source, billId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local result = MySQL.Sync.fetchAll('SELECT * FROM billing WHERE id = ?', {billId})
    
    if not result or #result == 0 then
        TriggerClientEvent('esx:showNotification', source, _U('no_invoices'))
        return false
    end

    local bill = result[1]

    if bill.identifier ~= xPlayer.identifier then
        TriggerClientEvent('esx:showNotification', source, 'Ši sąskaita jums nepriklauso')
        return false
    end

    local amount = tonumber(bill.amount) or 0

    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)

        MySQL.Async.execute('DELETE FROM billing WHERE id = @id', {
            ['@id'] = billId
        }, function(rowsChanged)
            if rowsChanged > 0 then
                if bill.sender then
                    local sender = ESX.GetPlayerFromIdentifier(bill.sender)
                    if sender then
                        sender.addMoney(amount)
                        TriggerClientEvent('esx:showNotification', sender.source, 
                            _U('received_payment', ESX.Math.GroupDigits(amount)))
                    end
                end

                TriggerClientEvent('esx:showNotification', source, 
                    _U('paid_invoice', ESX.Math.GroupDigits(amount)))
            end
        end)

        return true
    else
        TriggerClientEvent('esx:showNotification', source, _U('no_money'))
        return false
    end
end)

lib.callback.register('esx_billing:payAllBills', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local result = MySQL.Sync.fetchAll('SELECT * FROM billing WHERE identifier = ?', {xPlayer.identifier})
    
    if not result or #result == 0 then
        TriggerClientEvent('esx:showNotification', source, _U('no_invoices'))
        return false
    end

    local totalAmount = 0
    local bills = {}

    for i=1, #result do
        local bill = result[i]
        local amount = tonumber(bill.amount) or 0
        totalAmount = totalAmount + amount
        table.insert(bills, bill)
    end

    if xPlayer.getMoney() >= totalAmount then
        xPlayer.removeMoney(totalAmount)

        local paidSenders = {}

        for _, bill in ipairs(bills) do
            MySQL.Async.execute('DELETE FROM billing WHERE id = @id', {
                ['@id'] = bill.id
            })

            if bill.sender then
                if not paidSenders[bill.sender] then
                    paidSenders[bill.sender] = 0
                end
                paidSenders[bill.sender] = paidSenders[bill.sender] + (tonumber(bill.amount) or 0)
            end
        end

        for senderIdentifier, amount in pairs(paidSenders) do
            local sender = ESX.GetPlayerFromIdentifier(senderIdentifier)
            if sender then
                sender.addMoney(amount)
                TriggerClientEvent('esx:showNotification', sender.source, 
                    _U('received_payment', ESX.Math.GroupDigits(amount)))
            end
        end

        TriggerClientEvent('esx:showNotification', source, 
            ('Sėkmingai apmokėjote visas sąskaitas. Iš viso: %s€'):format(ESX.Math.GroupDigits(totalAmount)))

        return true
    else
        TriggerClientEvent('esx:showNotification', source, 
            ('Neturite pakankamai pinigų apmokėti visų sąskaitų. Reikia: %s€'):format(ESX.Math.GroupDigits(totalAmount)))
        return false
    end
end)

RegisterServerEvent('esx_billing:sendBill')
AddEventHandler('esx_billing:sendBill', function(target, sender, label, amount)
    local xTarget = ESX.GetPlayerFromId(target)
    local xSender = ESX.GetPlayerFromId(sender)

    if not xTarget then
        if xSender then
            TriggerClientEvent('esx:showNotification', xSender.source, _U('player_not_online'))
        end
        return
    end

    if not xSender then
        return
    end

    amount = ESX.Math.Round(tonumber(amount))

    if amount <= 0 then
        return
    end

    MySQL.Async.execute('INSERT INTO billing (identifier, sender, target, label, amount) VALUES (@identifier, @sender, @target, @label, @amount)', {
        ['@identifier'] = xTarget.identifier,
        ['@sender'] = xSender.identifier,
        ['@target'] = xTarget.identifier,
        ['@label'] = label,
        ['@amount'] = amount
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('esx:showNotification', xSender.source, 
                ('Išrašėte sąskaitą %s: %s€'):format(xTarget.getName(), ESX.Math.GroupDigits(amount)))
        end
    end)
end)

RegisterServerEvent('esx_billing:sendSocietyBill')
AddEventHandler('esx_billing:sendSocietyBill', function(target, society, label, amount)
    local xTarget = ESX.GetPlayerFromId(target)

    if not xTarget then
        return
    end

    amount = ESX.Math.Round(tonumber(amount))

    if amount <= 0 then
        return
    end

    MySQL.Async.execute('INSERT INTO billing (identifier, sender, target, label, amount) VALUES (@identifier, @sender, @target, @label, @amount)', {
        ['@identifier'] = xTarget.identifier,
        ['@sender'] = society,
        ['@target'] = xTarget.identifier,
        ['@label'] = label,
        ['@amount'] = amount
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print(string.format("^2[BILLING] Sąskaita gavo %s: %s - %s€^7", xTarget.getName(), label, amount))
        end
    end)
end)

RegisterServerEvent('esx_billing:isiustiisrasa')
AddEventHandler('esx_billing:isiustiisrasa', function(target, society, label, amount)    
    TriggerEvent('esx_billing:sendSocietyBill', target, society, label, amount)
end)

AddEventHandler('esx_billing:sendSocietyBill', function(target, society, label, amount)
end)