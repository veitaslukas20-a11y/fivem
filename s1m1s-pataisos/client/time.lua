---@diagnostic disable: undefined-global
local cache = nil
local lastFetch = 0

local function getServerTime(force)
    local now = GetGameTimer()
    if force or not cache or (now - lastFetch) > 30000 then
        cache = lib.callback.await('d-pataisos:getServerTime', false)
        lastFetch = now
    end
    return cache
end

return {
    getServerTime = getServerTime
}
