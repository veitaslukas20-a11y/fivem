local Status = lib.class('Status')

function Status:constructor(name, default, settings)
    self.val = default
	self.default = default
	self.name = name
	self.settings = settings
end

function Status:onTick(isDead, active)
	if isDead and not self.settings.whileDead then return end
	if self.settings.remove then
		self.val = math.max(0, active and (self.val - (self.settings.remove * 2)) or (self.val - self.settings.remove))
	elseif self.settings.add then
		self.val = math.min(Config.StatusMax, self.val + self.settings.add)
	end
end

function Status:set(val)
	self.val = val
end

function Status:add(val)
	self.val = math.min(Config.StatusMax, self.val + val)
end

function Status:remove(val)
	self.val = math.max(0, self.val - val)
end

function Status:getPercent()
	return (self.val / Config.StatusMax) * 100
end

function CreateStatus(name, default, settings)
	local status = Status:new(name, default, settings)

	return status
end