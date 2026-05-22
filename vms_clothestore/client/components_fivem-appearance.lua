if (Config.SkinManager ~= 'fivem-appearance' and Config.SkinManager ~= 'illenium-appearance') then
    return
end

Character_AP = {}

function getCurrentValues(type, id, data)
    if type == "components" then
        if id == 1 then
            return "mask_1", data.drawable, "mask_2", data.texture
        elseif id == 3 then
            return "arms", data.drawable, "arms_2", data.texture
        elseif id == 4 then
            return "pants_1", data.drawable, "pants_2", data.texture
        elseif id == 5 then
            return "bags_1", data.drawable, "bags_2", data.texture
        elseif id == 6 then
            return "shoes_1", data.drawable, "shoes_2", data.texture
        elseif id == 7 then
            return "chain_1", data.drawable, "chain_2", data.texture
        elseif id == 8 then
            return "tshirt_1", data.drawable, "tshirt_2", data.texture
        elseif id == 9 then
            return "bproof_1", data.drawable, "bproof_2", data.texture
        elseif id == 10 then
            return "decals_1", data.drawable, "decals_2", data.texture
        elseif id == 11 then
            return "torso_1", data.drawable, "torso_2", data.texture
        end
    elseif type == "props" then
        if id == 0 then
            return "helmet_1", data.drawable, "helmet_2", data.texture
        elseif id == 1 then
            return "glasses_1", data.drawable, "glasses_2", data.texture
        elseif id == 2 then
            return "ears_1", data.drawable, "ears_2", data.texture
        elseif id == 6 then
            return "watches_1", data.drawable, "watches_2", data.texture
        elseif id == 7 then
            return "bracelets_1", data.drawable, "bracelets_2", data.texture
        end
    end
end

function appearance_switcher(type, number)
    if type == "tshirt_1" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 8 then
                v.drawable = tonumber(number)
            end
        end
    elseif type == "tshirt_2" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 8 then
                v.texture = tonumber(number)
            end
        end
    elseif type == "torso_1" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 11 then
                v.drawable = tonumber(number)
            end
        end
    elseif type == "torso_2" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 11 then
                v.texture = tonumber(number)
            end
        end
    elseif type == "arms" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 3 then
                v.drawable = tonumber(number)
            end
        end
    elseif type == "arms_2" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 3 then
                v.texture = tonumber(number)
            end
        end
    elseif type == "pants_1" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 4 then
                v.drawable = tonumber(number)
            end
        end
    elseif type == "pants_2" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 4 then
                v.texture = tonumber(number)
            end
        end
    elseif type == "shoes_1" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 6 then
                v.drawable = tonumber(number)
            end
        end
    elseif type == "shoes_2" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 6 then
                v.texture = tonumber(number)
            end
        end
    elseif type == "decals_1" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 10 then
                v.drawable = tonumber(number)
            end
        end
    elseif type == "decals_2" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 10 then
                v.texture = tonumber(number)
            end
        end
    elseif type == "mask_1" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 1 then
                v.drawable = tonumber(number)
            end
        end
    elseif type == "mask_2" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 1 then
                v.texture = tonumber(number)
            end
        end
    elseif type == "bproof_1" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 9 then
                v.drawable = tonumber(number)
            end
        end
    elseif type == "bproof_2" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 9 then
                v.texture = tonumber(number)
            end
        end
    elseif type == "chain_1" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 7 then
                v.drawable = tonumber(number)
            end
        end
    elseif type == "chain_2" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 7 then
                v.texture = tonumber(number)
            end
        end
    elseif type == "bags_1" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 5 then
                v.drawable = tonumber(number)
            end
        end
    elseif type == "bags_2" then 
        for k, v in pairs(Character_AP['components']) do
            if v.component_id == 5 then
                v.texture = tonumber(number)
            end
        end
    elseif type == "helmet_1" then 
        for k, v in pairs(Character_AP['props']) do
            if v.prop_id == 0 then
                v.drawable = tonumber(number)
            end
        end
    elseif type == "helmet_2" then 
        for k, v in pairs(Character_AP['props']) do
            if v.prop_id == 0 then
                v.texture = tonumber(number)
            end
        end
    elseif type == "glasses_1" then 
        for k, v in pairs(Character_AP['props']) do
            if v.prop_id == 1 then
                v.drawable = tonumber(number)
            end
        end
    elseif type == "glasses_2" then 
        for k, v in pairs(Character_AP['props']) do
            if v.prop_id == 1 then
                v.texture = tonumber(number)
            end
        end
    elseif type == "ears_1" then 
        for k, v in pairs(Character_AP['props']) do
            if v.prop_id == 2 then
                v.drawable = tonumber(number)
            end
        end
    elseif type == "ears_2" then 
        for k, v in pairs(Character_AP['props']) do
            if v.prop_id == 2 then
                v.texture = tonumber(number)
            end
        end
    elseif type == "watches_1" then 
        for k, v in pairs(Character_AP['props']) do
            if v.prop_id == 6 then
                v.drawable = tonumber(number)
            end
        end
    elseif type == "watches_2" then
        for k, v in pairs(Character_AP['props']) do
            if v.prop_id == 6 then
                v.texture = tonumber(number)
            end
        end
    elseif type == "bracelets_1" then 
        for k, v in pairs(Character_AP['props']) do
            if v.prop_id == 7 then
                v.drawable = tonumber(number)
            end
        end
    elseif type == "bracelets_2" then 
        for k, v in pairs(Character_AP['props']) do
            if v.prop_id == 7 then
                v.texture = tonumber(number)
            end
        end
    end
    updateValue()
end

function updateValue()
    local myPed = PlayerPedId()
    for i=1, #Character_AP.components, 1 do
        if Character_AP.components[i].component_id ~= 2 then
            SetPedComponentVariation(myPed, Character_AP.components[i].component_id, Character_AP.components[i].drawable, 0, 2)
            SetPedComponentVariation(myPed, Character_AP.components[i].component_id, Character_AP.components[i].drawable, Character_AP.components[i].texture, 0)
        end
    end
    for i=1, #Character_AP.props, 1 do
        if Character_AP.props[i].drawable ~= -1 then
            SetPedPropIndex(myPed, Character_AP.props[i].prop_id, Character_AP.props[i].drawable, 0, true)
            SetPedPropIndex(myPed, Character_AP.props[i].prop_id, Character_AP.props[i].drawable, Character_AP.props[i].texture, true)
        else
            ClearPedProp(myPed, Character_AP.props[i].prop_id)
        end
    end
end