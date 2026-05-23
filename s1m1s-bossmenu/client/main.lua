-- dec4t-bossmenu/client/main.lua (FIXED FULL)

-- ESX handle (jei pas tave ESX globalus, šita eilutė netrukdys)
local ESX = ESX or exports["es_extended"] and exports["es_extended"]:getSharedObject() or nil

local Job = ""
local isBossMenuOpen = false
local currentMenu = nil

-- === Helperiai: būsena ===
local function _closeMenuState()
  isBossMenuOpen = false
  currentMenu = nil
end

local function _setOpen(id)
  isBossMenuOpen = true
  currentMenu = id
end

-- === Pagrindinis meniu aprašas (registruojamas prieš rodant) ===
local function _registerMainMenu(canusemoney, isgang)
  local jobName = (ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name) or Job or ""
  local money = lib.callback.await("d-bosmenu:getAccountMoney", false, jobName)

  lib.registerContext({
    id = "dbossmenu",
    title = "Direktoriaus veiksmai",
    onExit = function()
      _closeMenuState()
    end,
    options = {
      {
        title = "Darbuotojai",
        description = "Peržiūrėti darbuotojų sąrašą",
        icon = "fa-solid fa-users",
        onSelect = function()
          OpenEmployees()
        end,
      },
      {
        title = "Priimti darbuotoją",
        description = "Priimti naują darbuotoją į darbą",
        icon = "fa-solid fa-user-plus",
        onSelect = function()
          local ped = PlayerPedId()
          local coords = GetEntityCoords(ped)
          local available = lib.getNearbyPlayers(coords, 5.0, false)
          if not available or #available == 0 then return end

          for k, v in pairs(available) do
            available[k].id = GetPlayerServerId(v.id)
          end

          local players = lib.callback.await("d-bosmenu:getNames", false, available)
          OpenAddEmployee(players or {})
        end,
      },
      {
        title = "Įdėti į fondą",
        description = "Įdėti pinigus į fondą",
        icon = "fa-solid fa-piggy-bank",
        disabled = not canusemoney,
        metadata = {
          { label = "Fondo pajamos", value = ESX and ESX.Math and ESX.Math.GroupDigits(money) .. "€" or (tostring(money) .. "€") },
        },
        onSelect = function()
          local input = lib.inputDialog("Įdėti pinigus į fondą", {
            { type = "number", label = "Pinigų suma", description = "Suma, kurią įdėsite į fondą", required = true, icon = "fa-solid fa-piggy-bank" },
            { type = "select", label = "Sąskaita", description = "Iš kur nuskaityti", required = true, options = {
              { value = "money", label = "Grynaisiais" },
              { value = "bank",  label = "Banku" },
            }, default = "money" },
          })
          if not input or not input[1] or not input[2] then return lib.showContext("dbossmenu") end
          lib.callback.await("d-bosmenu:importMoney", false, input[1], input[2])
          lib.showContext("dbossmenu")
        end,
      },
      {
        title = "Išimti iš fondo",
        description = "Išimti pinigus iš fondo",
        icon = "fa-solid fa-money-bill-transfer",
        disabled = not canusemoney,
        metadata = {
          { label = "Fondo pajamos", value = ESX and ESX.Math and ESX.Math.GroupDigits(money) .. "€" or (tostring(money) .. "€") },
        },
        onSelect = function()
          local input = lib.inputDialog("Išimti pinigus iš fondo", {
            { type = "number", label = "Pinigų suma", description = "Suma, kurią išimsite", required = true, icon = "fa-solid fa-money-bill-transfer" },
            { type = "select", label = "Sąskaita", description = "Į kur pervesti", required = true, options = {
              { value = "money", label = "Grynaisiais" },
              { value = "bank",  label = "Banku" },
            }, default = "money" },
          })
          if not input or not input[1] or not input[2] then return lib.showContext("dbossmenu") end
          lib.callback.await("d-bosmenu:takeMoney", false, input[1], input[2])
          lib.showContext("dbossmenu")
        end,
      },
      {
        title = "Koreguoti algas",
        description = "Atidaryti algų valdymą",
        icon = "fa-solid fa-user-clock",
        disabled = not canusemoney,
        onSelect = function()
          if exports["dec4t-joblist"] and exports["dec4t-joblist"].menu then
            exports["dec4t-joblist"]:menu()
          else
            if ESX and ESX.ShowNotification then ESX.ShowNotification("dec4t-joblist nerastas") end
          end
        end,
      },
      {
        title = "Koreguoti patobulinimus",
        description = "Valdyti patobulinimus",
        icon = "fa-solid fa-cloud-arrow-up",
        disabled = not isgang,
        onSelect = function()
          if exports["dec4t-gangcredits"] and exports["dec4t-gangcredits"].openManage then
            exports["dec4t-gangcredits"]:openManage()
          else
            if ESX and ESX.ShowNotification then ESX.ShowNotification("dec4t-gangcredits nerastas") end
          end
        end,
      },
    }
  })
end

-- === Pagrindinis atidarymas (eksportuojamas) ===
function OpenMenu(canusemoney, isgang)
  -- blokas nuo atsitiktinio atsidarymo
  if isBossMenuOpen or lib.getOpenContextMenu() then return end

  Job = (ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name) or Job or ""
  _registerMainMenu(canusemoney, isgang)
  _setOpen("dbossmenu")
  lib.showContext("dbossmenu")
end

-- Eksportas, kurio ieško kiti resursai (pvz., dec4t-policejob)
exports("openMenu", OpenMenu)

-- === Įdarbinimo sub-meniu ===
function OpenAddEmployee(players)
  if not isBossMenuOpen then return end
  players = players or {}

  local Options = {}

  for _, v in pairs(players) do
    local option = {
      title = v.name,
      description = "Įdarbinkite " .. (v.name or "žaidėją") .. " į savo darbovietę",
      icon = "fa-solid fa-user",
      onSelect = function()
        local alert = lib.alertDialog({
          header = "Įdarbinimas",
          content = "Ar tikrai norite įdarbinti " .. (v.name or "žaidėją") .. " į savo darbovietę?",
          centered = true,
          cancel = true
        })
        if alert ~= "confirm" then return end
        local response = lib.callback.await("d-bosmenu:addEmployee", false, v.id)
        if exports["1x-hud"] and exports["1x-hud"].sendNotification then
          exports["1x-hud"]:sendNotification({
            type = response and response.success and "SUCCESS" or "ERROR",
            title = "Įdarbinimas",
            message = (response and response.message) or "Įvyko klaida",
            duration = 5000,
          })
        else
          if ESX and ESX.ShowNotification then ESX.ShowNotification((response and response.message) or "Įvyko klaida") end
        end
      end
    }
    table.insert(Options, option)
  end

  lib.registerContext({
    id = "dbossmenu:addemployee",
    menu = "dbossmenu",
    title = "Įdarbinimas",
    onExit = function()
      _setOpen("dbossmenu")
    end,
    options = Options
  })

  _setOpen("dbossmenu:addemployee")
  lib.showContext("dbossmenu:addemployee")
end

-- === Darbuotojų sąrašas ===
function OpenEmployees()
  if not isBossMenuOpen then return end

  local Players = lib.callback.await("d-bosmenu:getEmployees", false)
  if not Players then return end

  local Options = {}

  table.insert(Options, {
    title = "Ieškoti darbuotojo",
    description = "Ieškoti darbuotojo pagal vardą arba pavardę",
    icon = "fa-solid fa-magnifying-glass",
    onSelect = function()
      local input = lib.inputDialog("Ieškoti darbuotojo", {
        { type = "input", label = "Įveskite vardą arba pavardę", description = "Įveskite darbuotojo vardą arba pavardę", required = true, icon = "fa-solid fa-magnifying-glass" },
      })
      if not input or not input[1] then return lib.showContext("dbossmenu:employees") end

      local query = tostring(input[1] or "")
      local TPlayers = {}
      for _, v in pairs(Players) do
        if v.name and string.find(string.lower(v.name), string.lower(query), 1, true) then
          table.insert(TPlayers, v)
        end
      end

      local SOptions = {}
      for _, v in ipairs(TPlayers) do
        table.insert(SOptions, {
          title = v.name,
          description = v.job .. " - " .. v.grade .. "\nPeržiūrėti darbuotojo " .. v.name .. " duomenis",
          icon = "fa-solid fa-user",
          onSelect = function()
            OpenEmployee(v)
          end
        })
      end

      lib.registerContext({
        id = "dbossmenu:employees",
        menu = "dbossmenu",
        title = "Darbuotojai",
        onExit = function()
          _setOpen("dbossmenu")
        end,
        options = SOptions
      })

      _setOpen("dbossmenu:employees")
      lib.showContext("dbossmenu:employees")
    end,
  })

  for _, v in pairs(Players) do
    table.insert(Options, {
      title = v.name,
      description = v.job .. " - " .. v.grade .. "\nPeržiūrėti darbuotojo " .. v.name .. " duomenis",
      icon = "fa-solid fa-user",
      onSelect = function()
        OpenEmployee(v)
      end
    })
  end

  lib.registerContext({
    id = "dbossmenu:employees",
    menu = "dbossmenu",
    title = "Darbuotojai",
    onExit = function()
      _setOpen("dbossmenu")
    end,
    options = Options
  })

  _setOpen("dbossmenu:employees")
  lib.showContext("dbossmenu:employees")
end

-- === Vieno darbuotojo meniu ===
function OpenEmployee(Employee)
  if not isBossMenuOpen then return end

  local info = lib.callback.await("d-bosmenu:getEmployeeInfo", false, Employee)

  local Options = {
    {
      title = "Pakeisti darbuotojo pareigas",
      description = "Pažeminti arba pakelti darbuotoją pareigose",
      icon = "fa-solid fa-arrow-up-wide-short",
      onSelect = function()
        local tgrades = lib.callback.await("d-bosmenu:returnGrades", false) or {}

        local grades = {}
        for k, v in pairs(tgrades) do
          table.insert(grades, { value = k, label = v.label })
        end

        local input = lib.inputDialog("Paaukštinti darbuotoją", {
          { type = "select", label = "Pasirinkite pareigas", description = "Pasirinkite į kokias pareigas norite nužeminti/paaukštinti", required = true, default = Employee.grade_id, icon = "fa-solid fa-user-graduate", options = grades },
        })
        if not input or not input[1] then return OpenEmployee(Employee) end

        local ok = lib.callback.await("d-bosmenu:changeGrade", false, Employee, input[1])
        if ESX and ESX.ShowNotification then
          ESX.ShowNotification(ok and "Pareigos pakeistos" or "Nepavyko pakeisti pareigų")
        end
        if ok then
          OpenEmployees()
        else
          OpenEmployee(Employee)
        end
      end,
    },
    {
      title = "Išmesti darbuotoją iš darbo",
      description = "Atleisti darbuotoją",
      icon = "fa-solid fa-user-xmark",
      onSelect = function()
        local alert = lib.alertDialog({
          header = "Išmesti darbuotoją",
          content = "Ar esate įsitikinęs, kad norite išmesti " .. (Employee.name or "darbuotoją") .. " iš savo darbovietės?",
          centered = true,
          cancel = true
        })
        if alert == "confirm" then
          local ok = lib.callback.await("d-bosmenu:unemployePlayer", false, Employee)
          if ok then
            OpenEmployees()
          else
            OpenEmployee(Employee)
          end
        else
          OpenEmployee(Employee)
        end
      end,
    },
    {
      title = "Išmokėti algą",
      description = "Išmokėti darbuotojui algą",
      icon = "fa-solid fa-hand-holding-dollar",
      onSelect = function()
        local input = lib.inputDialog("Išmokėti algą", {
          { type = "number", label = "Algos suma", description = "Suma, kurią išmokėsite", required = true, icon = "fa-solid fa-hand-holding-dollar" },
        })
        if not input or not input[1] then return OpenEmployee(Employee) end
        local ok = lib.callback.await("d-bosmenu:giveSalary", false, Employee, input[1])
        if ESX and ESX.ShowNotification then
          if ok then
            ESX.ShowNotification("Alga pervesta darbuotojui " .. (Employee.name or "") .. " (" .. tostring(input[1]) .. "€)")
          else
            ESX.ShowNotification("Fonde nepakanka lėšų arba įvyko klaida")
          end
        end
        OpenEmployee(Employee)
      end,
    },
    {
      title = "Darbuotojo einamos pareigos",
      description = "Darbuotojas pareigos " .. (Employee.job or "") .. " - " .. (Employee.grade or ""),
      icon = "fa-solid fa-briefcase",
      disabled = true,
    },
  }

  if (ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "ambulance") and info then
    table.insert(Options, {
      title = "Prikeltų/pagydytų žmonių skaičius",
      description = "Darbuotojas prikėlė/pagydė " .. tostring(info.healed or 0) .. " žmonių",
      icon = "fa-solid fa-stethoscope",
      disabled = true,
    })
  end

  if info then
    table.insert(Options, {
      title = "Išrašytų sąskaitų skaičius",
      description = "Sąskaitų: " .. tostring(info.bills or 0) .. " (suma " .. tostring(info.bills_money or 0) .. "€)",
      icon = "fa-solid fa-file-circle-check",
      disabled = true,
    })
    table.insert(Options, {
      title = "Pradirbtos darbo valandos",
      description = "Pradirbo " .. tostring(info.hours or 0) .. " val " .. tostring(info.minutes or 0) .. " min",
      icon = "fa-solid fa-clock",
      disabled = true,
    })
  end

  lib.registerContext({
    id = "dbossmenu:employee",
    menu = "dbossmenu:employees",
    title = Employee.name,
    onExit = function()
      _setOpen("dbossmenu:employees")
    end,
    options = Options
  })

  _setOpen("dbossmenu:employee")
  lib.showContext("dbossmenu:employee")
end

-- === REFRESH įvykiai ===
RegisterNetEvent("d-bosmenu:updateEmployees", function(job)
  local PlayerData = ESX and ESX.GetPlayerData and ESX.GetPlayerData() or (ESX and ESX.PlayerData) or {}
  if PlayerData.job and (not job or PlayerData.job.name == job) then
    if isBossMenuOpen and (currentMenu == "dbossmenu:employees" or currentMenu == "dbossmenu:employee") then
      OpenEmployees()
    end
  end
end)

RegisterNetEvent("d-bosmenu:forceRefresh", function(job)
  local PlayerData = ESX and ESX.GetPlayerData and ESX.GetPlayerData() or (ESX and ESX.PlayerData) or {}
  if PlayerData.job and (not job or PlayerData.job.name == job) then
    if isBossMenuOpen and (currentMenu == "dbossmenu:employees" or currentMenu == "dbossmenu:employee") then
      OpenEmployees()
    end
  end
end)

-- === Watcher: jei UI užsidaro, išvalom būseną ===
CreateThread(function()
  while true do
    Wait(500)
    local open = lib.getOpenContextMenu()
    if not open and isBossMenuOpen then
      _closeMenuState()
    end
  end
end)

-- === onResourceStop: sutvarkyti UI ir būseną ===
AddEventHandler("onResourceStop", function(res)
  if res == GetCurrentResourceName() then
    if lib.getOpenContextMenu() then lib.hideContext(false) end
    _closeMenuState()
  end
end)

-- Back-compat helper kitiems resursams
function RefreshEmployeesList()
  if isBossMenuOpen then OpenEmployees() end
end
