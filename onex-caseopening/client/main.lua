local currentCase = nil

local CASE_CONFIGS = {
    case1_new = Config.Case1Prizes,
    case2_new = Config.Case2Prizes,
    case3_new = Config.Case3Prizes
}

local function sendNUIMessage(action, shouldShow, prizes, caseId)
    SendNUIMessage({
        action = action,
        data = {
            shouldShow = shouldShow,
            prizes = prizes,
            caseId = caseId
        }
    })
end

local function toggleNuiFrame(shouldShow, prizes, caseId)
    SetNuiFocus(shouldShow, shouldShow)
    sendNUIMessage("setVisible", shouldShow, prizes, caseId)
end

local function spinWheel(caseId)
    return lib.callback.await("onex-caseopening:requestSpin", false, caseId)
end

RegisterNUICallback("hideFrame", function(_, cb)
    toggleNuiFrame(false, nil, nil)
    currentCase = nil
    cb({})
end)

RegisterNUICallback('spinWheel', function(_, cb)
    if not currentCase then
        cb(false)
        return
    end
    
    local prizeId = spinWheel(currentCase)
    cb(prizeId)
end)

local function tryOpenCase(caseId, keyId)
    local hasKey = lib.callback.await('onex-caseopening:checkKey', false, keyId)

    if not hasKey then
        print("[ERROR] Player does not have the required key: " .. tostring(keyId))
        return
    end

    local prizes = CASE_CONFIGS[caseId]
    if not prizes then
        print("[ERROR] Invalid case ID: " .. tostring(caseId))
        return
    end

    currentCase = caseId
    toggleNuiFrame(true, prizes, caseId)
end

exports('openCase', function(caseId)
    tryOpenCase(caseId, caseId .. '_key')
end)
