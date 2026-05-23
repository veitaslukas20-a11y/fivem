local ObjectsManager = {}
ObjectsManager.objects = {}
ObjectsManager.nextId = 1

local function warnf(fmt, ...)
    print(("^3[objectsmanager]^7 " .. fmt):format(...))
end

local function errf(fmt, ...)
    print(("^1[objectsmanager]^7 " .. fmt):format(...))
end

local function deepcopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local out = {}
    for k, v in pairs(tbl) do
        out[k] = (type(v) == "table") and deepcopy(v) or v
    end
    return out
end

--- Internal: broadcasts a single object creation to everyone (or a single target if provided)
local function broadcastCreateObject(obj, target)
    local data = {
        id       = obj.id,
        resource = obj.resource,
        position = obj.position,
        model    = obj.model,
        owner    = obj.owner,
        export   = obj.export,
        metadata = obj.metadata
    }
    if target then
        TriggerClientEvent('objectsmanager:createObject', target, data)
    else
        TriggerClientEvent('objectsmanager:createObject', -1, data)
    end
end

--- Internal: broadcast current full state to a specific player
local function sendFullState(target)
    if not target then return end
    if next(ObjectsManager.objects) == nil then return end
    local list = {}
    for _, obj in pairs(ObjectsManager.objects) do
        list[#list + 1] = {
            id       = obj.id,
            resource = obj.resource,
            position = obj.position,
            model    = obj.model,
            owner    = obj.owner,
            export   = obj.export,
            metadata = obj.metadata
        }
    end
    TriggerClientEvent('objectsmanager:createObjects', target, list)
end

--- Validate incoming object data minimally on the server.
local function validateObjectData(data)
    if type(data) ~= "table" then return false, "data must be a table" end

    local modelType = type(data.model)
    if modelType ~= "string" and modelType ~= "number" then
        return false, ("model must be string or number, got %s"):format(modelType)
    end

    -- position is a vector3 on the client; on the server it will be a userdata with type "vector3"
    -- We accept tables with x,y,z as well for flexibility.
    local posType = type(data.position)
    local validPos = (posType == "vector3")
        or (posType == "table" and type(data.position.x) == "number" and type(data.position.y) == "number" and type(data.position.z) == "number")
    if not validPos then
        return false, ("position must be a vector3 or table{x,y,z}, got %s"):format(posType)
    end

    if data.metadata and type(data.metadata) ~= "table" then
        return false, ("metadata must be table, got %s"):format(type(data.metadata))
    end

    if data.export and type(data.export) ~= "string" then
        return false, ("export must be string, got %s"):format(type(data.export))
    end

    return true
end

--- Adds an object to the registry and broadcasts to clients.
--- @param data { id?: number, position: vector3|{x:number,y:number,z:number}, model: string|number, owner?: string, export?: string, metadata?: table }
function ObjectsManager.addObject(data)
    local ok, err = validateObjectData(data)
    if not ok then return nil, err end

    local id = tonumber(data.id) or ObjectsManager.nextId
    if ObjectsManager.objects[id] then
        return nil, ("object id %d already exists"):format(id)
    end

    -- attach provenance
    local srcRes = GetInvokingResource()
    local obj = {
        id       = id,
        resource = srcRes,
        position = data.position,
        model    = data.model,
        owner    = data.owner,
        export   = data.export,
        metadata = deepcopy(data.metadata or {})
    }

    ObjectsManager.objects[id] = obj
    ObjectsManager.nextId = math.max(ObjectsManager.nextId, id + 1)

    broadcastCreateObject(obj)
    return id
end

--- Removes an object and broadcasts removal.
function ObjectsManager.removeObject(id)
    id = tonumber(id)
    if not id then return false, "invalid id" end
    local obj = ObjectsManager.objects[id]
    if not obj then return false, "not found" end

    -- Optional: only the creating resource may remove its objects
    local srcRes = GetInvokingResource()
    if srcRes and obj.resource and srcRes ~= obj.resource then
        return false, "resource mismatch"
    end

    ObjectsManager.objects[id] = nil
    TriggerClientEvent('objectsmanager:removeObject', -1, id)
    return true
end

--- Changes an object's model and tells clients to respawn it client-side.
--- @param data { id: number, model: string|number }
function ObjectsManager.changeModel(data)
    if type(data) ~= "table" or type(data.id) ~= "number" then
        return false, "invalid payload"
    end
    local modelType = type(data.model)
    if modelType ~= "string" and modelType ~= "number" then
        return false, "invalid model"
    end

    local obj = ObjectsManager.objects[data.id]
    if not obj then return false, "not found" end

    local srcRes = GetInvokingResource()
    if srcRes and obj.resource and srcRes ~= obj.resource then
        return false, "resource mismatch"
    end

    if obj.model == data.model then
        warnf("changeModel: object %d already has model %s", obj.id, tostring(obj.model))
        return true
    end

    obj.model = data.model
    TriggerClientEvent('objectsmanager:changeModel', -1, { id = obj.id, model = obj.model })
    return true
end

--- Updates metadata keys for a single object.
--- @param id number
--- @param updates table<string, any>
function ObjectsManager.updateMetadata(id, updates)
    id = tonumber(id)
    if not id or type(updates) ~= "table" then
        return false, "invalid arguments"
    end

    local obj = ObjectsManager.objects[id]
    if not obj then return false, "not found" end

    local srcRes = GetInvokingResource()
    if srcRes and obj.resource and srcRes ~= obj.resource then
        return false, "resource mismatch"
    end

    for k, v in pairs(updates) do
        if v == json.null then
            obj.metadata[k] = nil
        else
            obj.metadata[k] = v
        end
    end

    TriggerClientEvent('objectsmanager:updateMetadata', -1, { id = id, updates = updates })
    return true
end

--- Batch metadata updates: { { id, updates = {...} }, ... }
function ObjectsManager.updateBatchedMetadata(list)
    if type(list) ~= "table" then return false, "invalid list" end
    local srcRes = GetInvokingResource()

    for _, item in pairs(list) do
        if type(item) == "table" and type(item.id) == "number" and type(item.updates) == "table" then
            local obj = ObjectsManager.objects[item.id]
            if obj then
                if not srcRes or not obj.resource or srcRes == obj.resource then
                    for k, v in pairs(item.updates) do
                        if v == json.null then
                            obj.metadata[k] = nil
                        else
                            obj.metadata[k] = v
                        end
                    end
                end
            end
        end
    end

    TriggerClientEvent('objectsmanager:updateBatchedMetadata', -1, list)
    return true
end

--- Read helpers
function ObjectsManager.getObject(id)
    return ObjectsManager.objects[tonumber(id)]
end

-- Optional filter: { resource?: string, owner?: string }
function ObjectsManager.getObjects(filter)
    if type(filter) ~= "table" or next(filter) == nil then
        return ObjectsManager.objects
    end
    local out = {}
    for id, obj in pairs(ObjectsManager.objects) do
        local ok = true
        if filter.resource and obj.resource ~= filter.resource then ok = false end
        if filter.owner and obj.owner ~= filter.owner then ok = false end
        if ok then out[id] = obj end
    end
    return out
end

-- === Player Sync ===
-- Send the full object list to new players. Small delay to ensure their client-side is ready.
AddEventHandler('playerJoining', function()
    local src = source
    CreateThread(function()
        Wait(1500)
        sendFullState(src)
    end)
end)

-- === Resource lifecycle ===
-- If a resource that created objects stops, remove its objects and notify clients.
AddEventHandler('onResourceStop', function(res)
    local toRemove = {}
    for id, obj in pairs(ObjectsManager.objects) do
        if obj.resource == res then
            toRemove[#toRemove + 1] = id
        end
    end
    if #toRemove > 0 then
        for _, id in ipairs(toRemove) do
            ObjectsManager.objects[id] = nil
            TriggerClientEvent('objectsmanager:removeObject', -1, id)
        end
        warnf("Cleaned up %d objects for resource '%s'", #toRemove, res)
    end
end)

-- === Exports ===
-- Use these from other server resources to manage objects.

exports('addObject', function(data)
    local id, err = ObjectsManager.addObject(data)
    if not id then errf("addObject failed: %s", err or "unknown") end
    return id, err
end)

exports('removeObject', function(id)
    local ok, err = ObjectsManager.removeObject(id)
    if not ok then errf("removeObject(%s) failed: %s", tostring(id), err or "unknown") end
    return ok, err
end)

exports('changeModel', function(data)
    local ok, err = ObjectsManager.changeModel(data)
    if not ok then errf("changeModel failed: %s", err or "unknown") end
    return ok, err
end)

exports('updateMetadata', function(id, updates)
    local ok, err = ObjectsManager.updateMetadata(id, updates)
    if not ok then errf("updateMetadata failed: %s", err or "unknown") end
    return ok, err
end)

exports('updateBatchedMetadata', function(list)
    local ok, err = ObjectsManager.updateBatchedMetadata(list)
    if not ok then errf("updateBatchedMetadata failed: %s", err or "unknown") end
    return ok, err
end)

exports('getObject', function(id)
    return ObjectsManager.getObject(id)
end)

exports('getObjects', function(filter)
    return ObjectsManager.getObjects(filter)
end)
