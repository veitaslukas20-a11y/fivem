local Inventory = exports.ox_inventory

exports('notepad', function(data, slot)
    local hash = slot?.metadata?.notepadhash

    if not hash then
        local input = lib.inputDialog('Užrašai', {
            {type = 'textarea', label = 'Įveskite užrašus', description = 'Įveskite tekstą, kurė galėsite perskaityti vėliau, ar perduoti kitiems.', required = true, min = 1, max = 10, autosize = true},
        })

        if not input then return end
        if not input[1] then return end

        lib.callback.await('notepad:registerText', false, slot.slot, input[1])
    else
        local text = lib.callback.await('notepad:getText', false, hash)
        if not text then return end
        lib.alertDialog({
            header = 'Užrašai',
            content = text,
            centered = true,
            cancel = false,
            labels = {
                confirm = 'Perskaičiau',
            }
        })
    end
end)