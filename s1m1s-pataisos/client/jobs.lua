---@diagnostic disable: undefined-global
local isWorking = false
local cooldowns = {}
local COOLDOWN_MS = 120000 

local function makeKey(zoneOrEntity)
	if type(zoneOrEntity) == 'number' then
		return ('n:%s'):format(zoneOrEntity)
	end
	return tostring(zoneOrEntity)
end

local function isOnCooldown(zoneOrEntity)
	local key = makeKey(zoneOrEntity)
	local now = GetGameTimer()
	local expiry = cooldowns[key]
	if expiry and now < expiry then
		return true, math.ceil((expiry - now) / 1000)
	end
	return false, 0
end

local function playLoading(label, time, anim)
	return lib.progressBar({
		duration = time,
		label = label,
		useWhileDead = false,
		canCancel = false,
		disable = {
			car = true,
			move = true,
			combat = true,
			mouse = true,
		},
		anim = anim,
	})
end

local function startJob(label, anim, zoneOrEntity)
	if isWorking then return false end

	local onCd, remain = isOnCooldown(zoneOrEntity)
	if onCd then
		lib.notify({
			title = 'Pataisos',
			description = ('Šią lokaciją galėsite valyti po %d s.'):format(remain),
			type = 'error',
			duration = 5000
		})
		return false
	end

	isWorking = true
	local result = playLoading(label, 40000, anim)
	isWorking = false

	if not result then
		return false
	end

	local key = makeKey(zoneOrEntity)
	cooldowns[key] = GetGameTimer() + COOLDOWN_MS

	return true
end

return {
    startJob = startJob
}