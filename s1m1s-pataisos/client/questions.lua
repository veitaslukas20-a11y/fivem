---@diagnostic disable: undefined-global
local ui = require('client.ui')

local state = {
    base = {},
    order = {},
    cursor = 1,
    incorrect = 0,
}

local function shuffle(list)
    local result = {}
    for i = 1, #list do
        result[i] = list[i]
    end
    for i = #result, 2, -1 do
        local j = math.random(i)
        result[i], result[j] = result[j], result[i]
    end
    return result
end

local function normalizeValue(value)
    if value == nil then return nil end
    if type(value) == 'string' then return value end
    return tostring(value)
end

local function mapOptions(opts)
    if type(opts) ~= 'table' then return {} end
    local converted = {}
    for i = 1, #opts do
        local option = opts[i]
        local t = type(option)
        if t == 'table' then
            local label = option.label or option.value or option[1]
            local value = option.value or option.label or option[1]
            label = label and tostring(label) or nil
            value = normalizeValue(value)
            if label and value then
                converted[#converted+1] = { label = label, value = value }
            end
        elseif option ~= nil then
            local label = tostring(option)
            local value = normalizeValue(option)
            if label and value then
                converted[#converted+1] = { label = label, value = value }
            end
        end
    end
    return converted
end

local function sanitizeCorrect(correct)
    local values = {}
    if type(correct) == 'table' then
        for i = 1, #correct do
            local value = normalizeValue(correct[i])
            if value then
                values[#values+1] = value
            end
        end
    else
        local value = normalizeValue(correct)
        if value then
            values[1] = value
        end
    end
    return values
end

local function sanitizeQuestions(list)
    local sanitized = {}
    if type(list) ~= 'table' then return sanitized end
    for _, question in ipairs(list) do
        if type(question) == 'table' then
            local options = mapOptions(question.options)
            if #options > 0 then
                sanitized[#sanitized+1] = {
                    label = question.label or 'Klausimas',
                    description = question.description or '',
                    options = options,
                    correct = sanitizeCorrect(question.correct)
                }
            end
        end
    end
    return sanitized
end

local function setQuestions(list)
    state.base = sanitizeQuestions(list)
    if #state.base > 0 then
        state.order = shuffle(state.base)
        state.cursor = 1
    else
        state.order = {}
        state.cursor = 1
    end
    state.incorrect = 0
end

local function fetchQuestions()
    for attempt = 1, 3 do
        local fetched = lib.callback.await('d-pataisos:getQuestions', false)
        if type(fetched) == 'table' and #fetched > 0 then
            setQuestions(fetched)
            if #state.base > 0 then
                return true
            end
        end
        Wait(0)
    end
    return false
end

local function ensureQueue(forceRefresh)
    if forceRefresh then
        return fetchQuestions()
    end

    if #state.base == 0 then
        if not fetchQuestions() then
            return false
        end
    end

    if #state.order == 0 or state.cursor > #state.order then
        if #state.base == 0 then
            return false
        end
        state.order = shuffle(state.base)
        state.cursor = 1
    end

    if not state.order[state.cursor] then
        state.order = shuffle(state.base)
        state.cursor = 1
    end

    return state.order[state.cursor] ~= nil
end

local function notifyFailure()
    lib.notify({
        title = 'Pataisos',
        description = 'Klausimų nepavyko įkelti. Praneškite administratoriui.',
        type = 'error'
    })
    print('[pataisos][klaida] Nepavyko gauti klausimų iš serverio.')
end

local function checkAnswer(answer, correct)
    if not answer or type(correct) ~= 'table' then
        return false
    end
    for i = 1, #correct do
        if answer == correct[i] then
            return true
        end
    end
    return false
end

local function handleResult(isCorrect)
    if not isCorrect then
        state.incorrect += 1
        if state.incorrect >= 3 then
            lib.callback.await('d-pataisos:addPataisosJobs', false)
            Pataisos.jobs = (Pataisos.jobs or 0) + 1
            state.incorrect = 0
            ui.showUI(Pataisos.jobs, Pataisos.reason, Pataisos.admin)
        end
        return
    end

    if state.incorrect > 0 then
        state.incorrect -= 1
    end

    if (Pataisos.jobs or 0) > 0 then
        lib.callback.await('d-pataisos:updatePataisosJobs', false)
        Pataisos.jobs = math.max((Pataisos.jobs or 0) - 1, 0)
    end

    if Pataisos.jobs > 0 then
        ui.showUI(Pataisos.jobs, Pataisos.reason, Pataisos.admin)
    end
end

local function resetQuestions(forceRefresh)
    return ensureQueue(forceRefresh or false)
end

local function showQuestion()
    if not ensureQueue(false) then
        if not ensureQueue(true) then
            notifyFailure()
            return false
        end
    end

    local question = state.order[state.cursor]
    if not question then
        notifyFailure()
        return false
    end

    local options = shuffle(question.options)
    local input = lib.inputDialog('Klausimynas © twox.lt', {
        {
            type = 'select',
            label = question.label,
            description = question.description,
            required = true,
            icon = 'fa-solid fa-question',
            options = options
        },
    }, { allowCancel = false })

    if input and input[1] then
        local result = input[1]
        if type(result) == 'table' then
            result = result.value
        end
        result = normalizeValue(result)
        local isCorrect = checkAnswer(result, question.correct)
        handleResult(isCorrect)
        state.cursor += 1
        return true
    end

    return false
end

return {
    setQuestions = setQuestions,
    resetQuestions = resetQuestions,
    showQuestion = showQuestion
}