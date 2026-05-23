local function showUI(jobs, reason, admin)
    SendNUIMessage({
        type = 'pataisos',
        show = true,
        jobs = jobs,
        reason = reason,
        admin = admin or ''
    })
end

local function hideUI()
    SendNUIMessage({
		type = 'pataisos',
		show = false,
	})
end

return {
    showUI = showUI,
    hideUI = hideUI
}