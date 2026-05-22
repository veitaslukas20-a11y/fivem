Config.AddMoneyToHospital = function()
    if Config.Core == "ESX" then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_ambulance', function(account)
            account.addMoney(Config.PlasticSurgery.Price)
        end)
    elseif Config.Core == "QB-Core" then
        exports['qb-management']:AddMoney('ambulance', Config.PlasticSurgery.Price)
    end
end