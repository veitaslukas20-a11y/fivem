local function useExport(resource, export)
	return function(...)
		return exports[resource][export](nil, ...)
	end
end

---@class ObjectsManager.Client
---@field id number
---@field resource string?
---@field model string
---@field position vector3
---@field metadata table
---@field owner string?
---@field export string?
---@field created boolean
---@field entity number?
---@field preventCreation boolean
---@field distance number?
---@field createObject fun()
---@field removeObject fun()
---@field getMetadata fun(key: string)
---@field updateMetadata fun(key: string, value: any)

ObjectsManager = {}
ObjectsManager.objects = {}  ---@type ObjectsManager.Client[]
ObjectsManager.spawnedObjects = {} ---@type ObjectsManager.Client[]

---@param data { id: number, resource?: string, position: vector3, model: string, owner?: string, export?: string, metadata?: table }
local function createGameObject(data)
    local self = {
        id = data.id,
        resource = data.resource,
        model = data.model,
        position = data.position,
        metadata = data.metadata or {},
        owner = data.owner,
        export = data.export,
        created = false,
        entity = nil,
        preventCreation = false,
    }

    function self.createObject()
        if self.preventCreation then return end
        local success, response = pcall(lib.requestModel, self.model)
        if not success then
            return warn(('Unable to spawn object `%s`. Error: %s'):format(self.model, response))
        end

        local entity = CreateObject(
            response,
            self.position.x,
            self.position.y,
            self.position.z,
            false, true, false
        )

        local attempts = 100
        while not DoesEntityExist(entity) and attempts > 0 do
            attempts -= 1
            Wait(100)
        end

        if attempts <= 0 then
            return warn(('Unable to spawn object `%s`. Make sure that object hash is available.'):format(self.model))
        end

        self.entity = entity
        self.created = true

        PlaceObjectOnGroundProperly(self.entity)
        FreezeEntityPosition(self.entity, true)

        if self.export then
            local cb = useExport(string.strsplit('.', self.export))
            cb(self)
        end

        ObjectsManager.spawnedObjects[self.entity] = self
    end

    function self.removeObject()
        if self.entity and DoesEntityExist(self.entity) then
            DeleteEntity(self.entity)
            self.created = false
            ObjectsManager.spawnedObjects[self.entity] = nil
            self.entity = nil
        end
    end

    function self.getMetadata(key)
        if type(key) ~= "string" then
            return error(("Invalid metadata key: expected string, got %s."):format(type(key)), 2)
        end

        return self.metadata[key]
    end

    function self.updateMetadata(key, value)
        if type(key) ~= "string" then
            return error(("Invalid metadata key: expected string, got %s."):format(type(key)), 2)
        end

        if self.metadata[key] == value then return end

        self.metadata[key] = (value == json.null) and nil or value
    end

    return self ---@type ObjectsManager.Client
end

---@param data { id: number, resource?: string, position: vector3, model: string, owner?: string, export?: string, metadata?: table }
function ObjectsManager.addObject(data)
    if type(data) ~= "table" then
        return error(("Invalid object data: expected table, got %s."):format(type(data)), 2)
    end

    if type(data.id) ~= 'number' then
        return error(("Invalid object data: field 'id' expected to be number, got %s."):format(type(data.id)), 2)
    end

    if type(data.position) ~= 'vector3' then
        return error("Invalid object data: field 'position' must be vector3.", 2)
    end

    if type(data.model) ~= 'string' and type(data.model) ~= 'number' then
        return error(("Invalid object data: field 'model' must be string (name) or number (hash), got %s."):format(type(model)), 2)
    end

    if data.metadata and type(data.metadata) ~= "table" then
        return error(("Invalid object metadata: expected table, got %s."):format(type(data.metadata)), 2)
    end

    if data.export and type(data.export) ~= "string" then
        return error(("Invalid export name: expected string, got %s."):format(type(data.export)), 2)
    end

    local obj = createGameObject(data)

    ObjectsManager.objects[data.id] = obj
end

---@param id number
function ObjectsManager.removeObject(id)
    if type(id) ~= "number" then return end

    local obj = ObjectsManager.objects[id]
    if obj then
        obj.preventCreation = true
        obj.removeObject()
        ObjectsManager.objects[id] = nil
    end
end

---@param data { id: number, model: string }
function ObjectsManager.changeModel(data)
    if type(data) ~= "table" then
        return error(("Invalid object data: expected table, got %s."):format(type(data)), 2)
    end

    if type(data.id) ~= 'number' then
        return error(("Invalid object data: field 'id' expected to be number, got %s."):format(type(data.id)), 2)
    end

    if type(data.model) ~= 'string' and type(data.model) ~= 'number' then
        return error(("Invalid object data: field 'model' must be string (name) or number (hash), got %s."):format(type(model)), 2)
    end

    local obj = ObjectsManager.objects[data.id]
    if obj then
        if obj.model == data.model then
            return warn(("Object model is already %s. Attempted to change to the same model."):format(obj.model))
        end

        obj.model = data.model

        obj.preventCreation = true
        obj.removeObject()
        obj.preventCreation = false
    end
end

---@param id number
function ObjectsManager.getObject(id)
    if type(id) ~= "number" then
        return false
    end

    return ObjectsManager.objects[id]
end

---@param filter? { resource: string?, distance: number?, owner: string? }
---@param position? vector3
function ObjectsManager.getSpawnedObjects(filter, position)
    if next(ObjectsManager.spawnedObjects) == nil then
        return {}
    end

    if type(filter) ~= 'table' then
        return ObjectsManager.spawnedObjects
    end

    if filter.distance and type(position) ~= 'vector3' then
        return error(("Invalid position type: expected vector3, got %s."):format(type(position)), 2)
    end

    if filter.distance and type(filter.distance) ~= "number" then
        return error(("Invalid filter field distance: expected number, got %s."):format(type(filter.distance)), 2)
    end

    if filter.resource and type(filter.resource) ~= "string" then
        return error(("Invalid filter field resource: expected string, got %s."):format(type(filter.resource)), 2)
    end

    if filter.owner and type(filter.owner) ~= "string" then
        return error(("Invalid filter field owner: expected string, got %s."):format(type(filter.owner)), 2)
    end

    local filteredObjects = {}
    local checkResource = filter.resource ~= nil
    local checkDistance = filter.distance ~= nil
    local checkOwner = filter.owner ~= nil

    for _, obj in pairs(ObjectsManager.spawnedObjects) do
        local resourceMatch = not checkResource or obj.resource == filter.resource
        local ownerMatch = not checkOwner or obj.owner == filter.owner
        local distanceMatch = true
        local distance

        if checkDistance then
            distance = #(obj.position - position)
            distanceMatch = distance < filter.distance
        end

        if resourceMatch and distanceMatch and ownerMatch then
            if checkDistance then
                obj.distance = distance
            end
            filteredObjects[#filteredObjects + 1] = obj
        end
    end

    return filteredObjects
end

---@param objects table<number, { id: number, resource?: string, position: vector3, model: string, owner?: string, export?: string, metadata?: table }>
RegisterNetEvent('objectsmanager:createObjects', function(objects)
    if type(objects) ~= 'table' then return error(("Invalid objects data: expected table, got %s."):format(type(objects)), 2) end
    for _, obj in pairs(objects) do
        ObjectsManager.addObject({
            id = obj.id,
            resource = obj.resource,
            position = obj.position,
            model = obj.model,
            owner = obj.owner,
            export = obj.export,
            metadata = obj.metadata
        })
    end
end)

---@param data { id: number, resource?: string, position: vector3, model: string, owner?: string, export?: string, metadata?: table }
RegisterNetEvent('objectsmanager:createObject', function(data)
    if
        type(data) ~= "table"
        or type(data.id) ~= "number"
        or type(data.position) ~= "vector3"
        or (type(data.model) ~= "string" and type(data.model) ~= "number")
    then return end

    ObjectsManager.addObject({
        id = data.id,
        resource = data.resource,
        position = data.position,
        model = data.model,
        owner = data.owner,
        export = data.export,
        metadata = data.metadata
    })
end)

---@param id number
RegisterNetEvent('objectsmanager:removeObject', function(id)
    if type(id) ~= 'number' then return end

    ObjectsManager.removeObject(id)
end)

---@param data { id: number, model: string }
RegisterNetEvent('objectsmanager:changeModel', function(data)
    if
        type(data) ~= "table"
        or type(data.id) ~= "number"
        or (type(data.model) ~= "string" and type(data.model) ~= "number")
    then return end

    ObjectsManager.changeModel(data)
end)

---@param data { id: number, updates: table<string, any> }
RegisterNetEvent('objectsmanager:updateMetadata', function(data)
    if
        type(data) ~= "table"
        or type(data.id) ~= 'number'
        or type(data.updates) ~= 'table'
    then return end

    local obj = ObjectsManager.getObject(data.id)
    if not obj then return end

    for key, value in pairs(data.updates) do
        obj.updateMetadata(key, value)
    end
end)

---@param data { id: number, updates: table<string, any> }[]
RegisterNetEvent('objectsmanager:updateBatchedMetadata', function(data)
    if
        type(data) ~= "table"
    then return end

    for _, updateData in pairs(data) do
        if type(updateData.id) == "number" and type(updateData.updates) == "table" then
            local obj = ObjectsManager.getObject(updateData.id)
            if obj then
                for key, value in pairs(updateData.updates) do
                    obj.updateMetadata(key, value)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if next(ObjectsManager.objects) then
            local playerCoords = cache.coords or GetEntityCoords(cache.ped)
            for _, obj in pairs(ObjectsManager.objects) do
                local distance = #(playerCoords - obj.position)
                if distance < 50.0 and not obj.created then
                    obj.createObject()
                elseif distance > 50.0 and obj.created then
                    obj.removeObject()
                end
            end
            Wait(1000)
        else
            Wait(5000)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, obj in pairs(ObjectsManager.objects) do
        ObjectsManager.removeObject(obj.id)
    end
end)

exports('getObject', function()
    return ObjectsManager
end)