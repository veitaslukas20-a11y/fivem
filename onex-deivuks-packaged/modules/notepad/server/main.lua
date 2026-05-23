local Inventory = exports.ox_inventory
local Notes = {}

local function generateHash(length)
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local hash = ''
    for i = 1, length do
        local rand = math.random(1, #chars)
        hash = hash .. chars:sub(rand, rand)
    end
    return hash
end

lib.callback.register('notepad:registerText', function(source, slot, text)
    local hash = generateHash(12)
    Notes[hash] = text

    Inventory:SetMetadata(source, slot, {
        notepadhash = hash
    })

    return true
end)

lib.callback.register('notepad:getText', function(source, hash)
    return Notes[hash]
end)

AddEventHandler('playerDropped', function(playerId)
end)
