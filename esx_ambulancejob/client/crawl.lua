local isProne = false
local isCrouched = false
local isCrawling = false
local inAction = false
local proneType = 'onfront'
local forceEndProne = false


-- Utils --

---Checks if the player should be able to crawl or not
---@return boolean
local function CanPlayerCrouchCrawl()
    if not IsPedOnFoot(cache.ped) or IsPedJumping(cache.ped) or IsPedFalling(cache.ped) or IsPedInjured(cache.ped) or IsPedInMeleeCombat(cache.ped) or IsPedRagdoll(cache.ped) then
        return false
    end

    return true
end

---Plays an animation on the ped. (Loads an unloads needed anim dict)
---@param ped number
---@param animDict string
---@param animName string
---@param blendInSpeed number|nil
---@param blendOutSpeed number|nil
---@param duration number|nil
---@param startTime number|nil
local function PlayAnimOnce(animDict, animName, blendInSpeed, blendOutSpeed, duration, startTime)
    lib.requestAnimDict(animDict)
    TaskPlayAnim(cache.ped, animDict, animName, blendInSpeed or 2.0, blendOutSpeed or 2.0, duration or -1, 0, startTime or 0.0, false, false, false)
    RemoveAnimDict(animDict)
end

---Smoothly changes the ped's heading
---@param ped number
---@param amount number
---@param time number ms
local function ChangeHeadingSmooth(ped, amount, time)
    local times = math.abs(amount)
    local test = amount / times
    local wait = time / times

    for _i = 1, times do
        Wait(wait)
        SetEntityHeading(ped, GetEntityHeading(ped) + test)
    end
end

-- Crawling --

---Stops the player from being prone
---@param force boolean If forced then no exit anim is played
local function stopPlayerProne(force)
    isProne = false
    forceEndProne = force
end

---@param heading number|nil
---@param blendInSpeed number|nil
local function PlayIdleCrawlAnim(heading, blendInSpeed)
    local playerCoords = GetEntityCoords(cache.ped)
    TaskPlayAnimAdvanced(cache.ped, 'move_crawl', proneType..'_fwd', playerCoords.x, playerCoords.y, playerCoords.z, 0.0, 0.0, heading or GetEntityHeading(cache.ped), blendInSpeed or 2.0, 2.0, -1, 2, 1.0, false, false)
end

---@param forceEnd boolean
local function PlayExitCrawlAnims(forceEnd)
    if not forceEnd then
        inAction = true

        if proneType == 'onfront' then
            PlayAnimOnce('get_up@directional@transition@prone_to_knees@crawl', 'front', nil, nil, 780)

            -- Only stand fully up if we are not crouching
            if not isCrouched then
                Wait(780)
                PlayAnimOnce('get_up@directional@movement@from_knees@standard', 'getup_l_0', nil, nil, 1300)
            end
        else
            PlayAnimOnce('get_up@directional@transition@prone_to_seated@crawl', 'back', 16.0, nil, 950)

            -- Only stand fully up if we are not crouching
            if not isCrouched then
                Wait(950)
                PlayAnimOnce('get_up@directional@movement@from_seated@standard', 'get_up_l_0', nil, nil, 1300)
            end
        end
    end
end

---Crawls one "step" forward/backward
---@param type string
---@param direction string
local function Crawl(type, direction)
    isCrawling = true

    TaskPlayAnim(cache.ped, 'move_crawl', type..'_'..direction, 8.0, -8.0, -1, 2, 0.0, false, false, false)

    local time = {
        ['onfront'] = {
            ['fwd'] = 820,
            ['bwd'] = 990
        },
        ['onback'] = {
            ['fwd'] = 1200,
            ['bwd'] = 1200
        }
    }

    SetTimeout(time[type][direction], function()
        isCrawling = false
    end)
end

---The crawl loop
local function CrawlLoop()
    Wait(400)

    while isProne do

        -- Checks if the player is falling, in vehicle, dead etc.
        if not CanPlayerCrouchCrawl() or IsEntityInWater(cache.ped) then
            ClearPedTasks(cache.ped)
            stopPlayerProne(true)
            break
        end

        -- Handles forwad/backward movement
        local forward, backwards = IsControlPressed(0, 32), IsControlPressed(0, 33) -- INPUT_MOVE_UP_ONLY, INPUT_MOVE_DOWN_ONLY
        if not isCrawling then
            if forward then -- Forward
                Crawl(proneType, 'fwd')
            elseif backwards then -- Back
                Crawl(proneType, 'bwd')
            end
        end

        -- Moving left/right
        if IsControlPressed(0, 34) then -- INPUT_MOVE_LEFT_ONLY
            if isCrawling then
                local headingDiff = forward and 1.0 or -1.0
                SetEntityHeading(cache.ped, GetEntityHeading(cache.ped) + headingDiff)
            else
                inAction = true
                if proneType == 'onfront' then
                    local playerCoords = GetEntityCoords(cache.ped)
                    TaskPlayAnimAdvanced(cache.ped, 'move_crawlprone2crawlfront', 'left', playerCoords.x, playerCoords.y, playerCoords.z, 0.0, 0.0, GetEntityHeading(cache.ped), 2.0, 2.0, -1, 2, 0.1, false, false)
                    ChangeHeadingSmooth(cache.ped, -10.0, 300)
                    Wait(700)
                else
                    PlayAnimOnce('get_up@directional_sweep@combat@pistol@left', 'left_to_prone')
                    ChangeHeadingSmooth(cache.ped, 25.0, 400)
                    PlayIdleCrawlAnim()
                    Wait(600)
                end
                inAction = false
            end
        elseif IsControlPressed(0, 35) then -- INPUT_MOVE_RIGHT_ONLY
            if isCrawling then
                local headingDiff = backwards and 1.0 or -1.0
                SetEntityHeading(cache.ped, GetEntityHeading(cache.ped) + headingDiff)
            else
                inAction = true
                if proneType == 'onfront' then
                    local playerCoords = GetEntityCoords(cache.ped)
                    TaskPlayAnimAdvanced(cache.ped, 'move_crawlprone2crawlfront', 'right', playerCoords.x, playerCoords.y, playerCoords.z, 0.0, 0.0, GetEntityHeading(cache.ped), 2.0, 2.0, -1, 2, 0.1, false, false)
                    ChangeHeadingSmooth(cache.ped, 10.0, 300)
                    Wait(700)
                else
                    PlayAnimOnce('get_up@directional_sweep@combat@pistol@right', 'right_to_prone')
                    ChangeHeadingSmooth(cache.ped, -25.0, 400)
                    PlayIdleCrawlAnim()
                    Wait(600)
                end
                inAction = false
            end
        end

        Wait(0)
    end

    TriggerEvent('crouch_crawl:onCrawl', false)

    -- If the crawling wasn't forcefully ended, then play the get up animations
    PlayExitCrawlAnims(forceEndProne)

    -- Reset variabels
    isCrawling = false
    inAction = false
    forceEndProne = false
    proneType = 'onfront'
    SetPedConfigFlag(cache.ped, 48, false) -- CPED_CONFIG_FLAG_BlockWeaponSwitching

    -- Unload animation dictionaries
    RemoveAnimDict('move_crawl')
    RemoveAnimDict('move_crawlprone2crawlfront')
end

---Gets called when the crawl key is pressed
function EnsureCrawl()
    -- If we already are doing something, then don't continue
    if inAction then
        return
    end

    -- If already prone, then stop
    if isProne then
        isProne = false
        return
    end

    -- If we are crouching we should stop that first
    local wasCrouched = false
    if isCrouched then
        isCrouched = false
        wasCrouched = true
    end

    if not CanPlayerCrouchCrawl() or IsEntityInWater(cache.ped) or not IsPedHuman(cache.ped) then
        return
    end
    inAction = true

    -- If we are pointing then stop pointing
    if Pointing then
        Pointing = false
    end

    isProne = true
    SetPedConfigFlag(cache.ped, 48, true) -- CPED_CONFIG_FLAG_BlockWeaponSwitching

    -- Force leave stealth mode
    if GetPedStealthMovement(cache.ped) == 1 then
        SetPedStealthMovement(cache.ped, false, 'DEFAULT_ACTION')
        Wait(100)
    end

    -- Load animations that the crawling is going to use
    lib.requestAnimDict('move_crawl')
    lib.requestAnimDict('move_crawlprone2crawlfront')

    if wasCrouched then
        PlayAnimOnce('amb@world_human_sunbathe@male@front@enter', 'enter', nil, nil, -1, 0.3)
        Wait(1500)
    else
        PlayAnimOnce('amb@world_human_sunbathe@male@front@enter', 'enter')
        Wait(3000)
    end

    -- Set the player into the idle position (but only if we can still crawl)
    if CanPlayerCrouchCrawl() and not IsEntityInWater(cache.ped) then
        PlayIdleCrawlAnim(nil, 3.0)
    end

    TriggerEvent('crouch_crawl:onCrawl', true)

    inAction = false
    CreateThread(CrawlLoop)
end

-- Exports --

---Returns if the player is crawling (only when moving forward/backward)
---@return boolean
function IsPlayerCrawling()
	return isProne
end
exports('IsPlayerCrawling', IsPlayerCrawling)