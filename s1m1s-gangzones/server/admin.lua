local ESX = ESX

-- lazy getteriai, kad nevežtų nuo failų užkrovimo eilės
local function DGZ() return _G.dgz end
local function CFG() return _G.dgz and _G.dgz.cfg or {} end

local function isAdmin(src)
    local x = ESX.GetPlayerFromId(src); if not x then return false end
    local g = (x.getGroup and x.getGroup() or 'user'):lower()
    return g == 'admin' or g == 'superadmin' or g == 'owner' or g == 'dev'
end

-- CREATE ZONE
lib.callback.register('d-gangzones:createZone', function(src, title, takeMin, cooldownH, sx, sy, sz, ztype, official, coords, heading)
    if not isAdmin(src) then return false end
    title = string.upper(title or 'ZONA'); ztype = ztype or 'unknown'
    local key = string.lower(title)

    local zone = {
        title = title,
        coords = vector3(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0),
        size   = { x = sx + 0.0, y = sy + 0.0, z = sz + 0.0 },
        rotation = (heading or 0) + 0.0,
        cooldown = math.max(1, tonumber(cooldownH or 12)),
        time     = math.max(1, tonumber(takeMin or 15)),
        type     = ztype,
        official = official and true or false,
        owners   = nil,
        owned_since = 0,
        timesTaken  = 0,
        ppercent    = (ztype == 'plovimas') and 80 or nil,
        armour      = (ztype == 'addarmour') and { max = 3, cooldown = 60 } or nil,
        crafting    = (ztype == 'armour' or ztype == 'ammunition' or (ztype and ztype:find('guns')) or ztype == 'taisymas') and ('default_'..ztype) or nil,
        blackmarket = (ztype == 'blackmarket') and {} or nil,
        drugdealer  = (ztype == 'drugdealer') and {} or nil,
        next_take_at = 0,
        launder_cooldown_until = 0
    }

    DGZ().saveZone(zone)
    CFG().Zones[key] = zone
    DGZ().broadcastZone(zone) -- TriggerClientEvent('d-gangzones:update', -1, zone)
    return true
end)

-- GANGS ADD / EDIT
lib.callback.register('d-gangzones:addGang', function(src, job, official, color, name)
    if not isAdmin(src) then return false end
    job = string.lower(job or '')
    if job == '' then return false end
    color = (color or 'FFFFFF'):gsub('#','')
    name = name or job

    local existed = MySQL.scalar.await('SELECT COUNT(1) FROM d_gangzones_gangs WHERE job=?', { job }) > 0
    if existed then
        MySQL.update.await('UPDATE d_gangzones_gangs SET official=?, color=?, name=? WHERE job=?', { official and 1 or 0, color, name, job })
    else
        MySQL.insert.await('INSERT INTO d_gangzones_gangs (job, official, color, name) VALUES (?,?,?,?)', { job, official and 1 or 0, color, name })
    end

    CFG().GangsList[job] = { official = official and true or false, name = name }
    CFG().GangColors[job] = color
    DGZ().colorsChanged(); DGZ().gangsChanged()
    return true
end)

lib.callback.register('d-gangzones:editGang', function(src, job, official, color, name)
    if not isAdmin(src) then return false end
    job = string.lower(job or '')
    if job == '' then return false end
    color = (color or 'FFFFFF'):gsub('#','')
    name = name or job

    MySQL.update.await('UPDATE d_gangzones_gangs SET official=?, color=?, name=? WHERE job=?', { official and 1 or 0, color, name, job })
    CFG().GangsList[job] = { official = official and true or false, name = name }
    CFG().GangColors[job] = color
    DGZ().colorsChanged(); DGZ().gangsChanged()
    return true
end)

-- UPDATE / DELETE ZONE
lib.callback.register('d-gangzones:updateZone', function(src, zkey, newZone)
    if not isAdmin(src) then return false end
    local key = string.lower(zkey or '')
    local curr = CFG().Zones[key]; if not curr then return false end

    if not newZone then
        MySQL.update.await('DELETE FROM d_gangzones_zones WHERE id=?', { curr.id })
        CFG().Zones[key] = nil
        TriggerClientEvent('d-gangzones:updateZone', -1, key, nil)
        return true
    end

    curr.title = string.upper(newZone.title or curr.title)
    curr.coords = vector3(newZone.coords.x + 0.0, newZone.coords.y + 0.0, newZone.coords.z + 0.0)
    curr.size = { x = newZone.size.x + 0.0, y = newZone.size.y + 0.0, z = newZone.size.z + 0.0 }
    curr.rotation = (newZone.rotation or curr.rotation) + 0.0
    curr.cooldown = newZone.cooldown or curr.cooldown
    curr.time = newZone.time or curr.time
    curr.type = newZone.type or curr.type
    curr.official = newZone.official and true or false
    curr.owners = newZone.owners or nil
    curr.timesTaken = newZone.timesTaken or curr.timesTaken
    curr.ppercent = newZone.ppercent or curr.ppercent
    curr.blackmarket = newZone.blackmarket or curr.blackmarket
    curr.drugdealer = newZone.drugdealer or curr.drugdealer
    curr.armour = newZone.armour or curr.armour
    curr.crafting = newZone.crafting or curr.crafting

    local oldKey = key
    local newKey = string.lower(curr.title)
    if oldKey ~= newKey then
        CFG().Zones[oldKey] = nil
        CFG().Zones[newKey] = curr
    end

    DGZ().saveZone(curr)
    DGZ().pushZoneReplace(oldKey, curr) -- praneša visiems
    return true
end)

-- RESET COOLDOWN
lib.callback.register('d-gangzones:resetCooldown', function(src, zkey)
    if not isAdmin(src) then return false end
    local key = string.lower(zkey or '')
    local z = CFG().Zones[key]; if not z then return false end
    z.next_take_at = 0
    DGZ().saveZone(z)
    DGZ().broadcastZone(z)
    return true
end)
