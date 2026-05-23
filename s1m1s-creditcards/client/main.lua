local CashingOut = false
local Inventory = exports.ox_inventory
local playerState = LocalPlayer.state

function CashOut(entity)
    if CashingOut then return end

    if Inventory:GetItemCount('credit_card', {creditUsed = true}) == Inventory:GetItemCount('credit_card') then
        return false
    end

    CashingOut = true
    playerState.invBusy = true

    local animDict = "anim@heists@ornate_bank@hack"
    lib.requestAnimDict(animDict, 1000)

    local gameData = {
        totalNumbers = 20,
        seconds = 30,
        timesToChangeNumbers = 3,
        amountOfGames = 1,
        incrementByAmount = 5,
    }

    TaskPlayAnim(cache.ped, animDict, "hack_enter", 8.0, -8.0, 4500, 1, 0, false, false, false)
    Wait(4500)

    TaskPlayAnim(cache.ped, animDict, "hack_loop", 8.0, -8.0, gameData.seconds * 1000, 1, 0, false, false, false)
    local success = exports['pure-minigames']:numberCounter(gameData)

    TaskPlayAnim(cache.ped, animDict, "hack_exit", 8.0, -8.0, 4500, 1, 0, false, false, false)
    Wait(4500)

    ClearPedTasks(cache.ped)

    if success then
        lib.callback.await('creditcard:cashOut', false, entity)
    end

    playerState.invBusy = false
    CashingOut = false
end

lib.callback.register('creditcard:getAtm', function(entity)
    local EntCoords = GetEntityCoords(entity)
    local PlyCoords = GetEntityCoords(cache.ped)
    local Exist = DoesEntityExist(entity)

    return CashingOut
       and Exist
       and #(PlyCoords - EntCoords) < 3.0
end)

Citizen.CreateThread(function()
    exports.ox_target:addModel({
        `prop_atm_01`,
        `prop_atm_02`,
        `prop_fleeca_atm`,
        `prop_atm_03`,
    }, {
        name = 'creditcard_cashout',
        icon = 'fa-solid fa-credit-card',
        label = 'Išsigryninti pinigus iš kortelės',
        distance = 1.0,
        items = {
            laptop = 1,
            credit_card = 1,
        },
        onSelect = function(data)
            CashOut(data.entity)
        end,
    })

    exports.ox_inventory:displayMetadata('creditUsed', 'Negaliojanti')
end)