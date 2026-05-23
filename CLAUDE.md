# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

A production FiveM (GTA V multiplayer) server resource collection. There is no build step, no test runner, and no package manager for the Lua resources — Lua files are loaded directly by the FiveM server at runtime. The repository is a monorepo of ~90 independent resources, each a self-contained directory with its own `fxmanifest.lua`.

## Development Workflow

Since resources run on a live FiveM server, the workflow is:
1. Edit files in the resource directory
2. In the server console: `refresh` → `restart <resource-name>`
3. Observe in-game or in server console output

There are no lint or test commands. Lua syntax errors surface as server console stack traces on resource start.

For NUI resources that use a compiled frontend (e.g., `onex-caseopening/web/`), the Angular app has a local dev mode:
- Change `ui_page` in `fxmanifest.lua` from the compiled path to the commented-out `http://localhost:4200/index.html` line during development
- Revert before committing

## Architecture

### Framework: ES Extended (`es_extended/`)

All resources depend on this. It manages player identity, accounts, jobs, inventory, and server callbacks. Key globals injected by `@es_extended/imports.lua`:

- **`ESX`** — shared object; accessed via `exports['es_extended']:getSharedObject()` on server, auto-populated by `imports.lua` on client
- **`ESX.PlayerData`** (client) — current player's job, accounts, identity; updated by `esx:setPlayerData` events
- **`ESX.GetPlayerFromId(src)`** (server) — returns xPlayer object with `.job`, `.accounts`, `.set()`, `.addAccountMoney()`, etc.

Player lifecycle events:
- `esx:playerLoaded` — fires on client when character is ready; xPlayer data is the argument
- `esx:setJob` — fires on client when job changes
- `esx:onPlayerJoined` — fires on server; entry point for creating/loading a player record

Database queries use **oxmysql** (async/await pattern):
```lua
local result = MySQL.scalar.await('SELECT 1 FROM users WHERE identifier = ?', { identifier })
MySQL.prepare.await(sql, { params })
```

Some older resources still use **mysql-async** (callback pattern) — check the `fxmanifest.lua` to see which is loaded.

### Resource Structure Pattern

Every resource follows:
```
resource-name/
  fxmanifest.lua    -- declares scripts, dependencies, ui_page
  config.lua        -- Config = {} table, loaded as shared_script
  client/
    main.lua        -- client-side logic
  server/
    main.lua        -- server-side logic
  data/             -- optional: large config tables (uniforms, items, locations)
  web/              -- optional: NUI frontend (Angular → dist/browser/)
```

The first two lines of every `fxmanifest.lua` inject ElectronAC (anti-cheat):
```lua
server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
```
This must be present in any new resource.

### Resource Author Prefixes

- **`s1m1s-`** — the primary custom job/system resources (police, gangs, prison, mechanic, boss menu, UI components). Most complex resources.
- **`onex-`** — case opening, fuel, storage, mini-games, utility exports
- **`deivuks-`** — garage system, regitra (vehicle registration), utility anti-cheat helpers
- **`dec4t-`** — admin menu (NUI dashboard), job garage, mechanic job
- **`2X-`** — lightweight client-side features (discord presence, neon, gunshots, animations)
- **`esx_`** — standard ESX ecosystem resources (billing, society, ambulance job, etc.)
- **`vms_`** — character creator, clothing store, multi-character system
- **`ox_`** — ox_target (interaction zones), ox_doorlock

### Inter-Resource Communication

**Exports** for synchronous cross-resource calls:
```lua
-- Caller
local Garage = exports['s1m1s-jobgarage']:initGarages()
exports['deivuks-utils']:armour()  -- notify anti-cheat before setting armor

-- Exporter (in server or client script)
exports('functionName', function(args) ... end)
```

**ox_lib callbacks** for client→server RPC (preferred in modern resources):
```lua
-- Server registers
lib.callback.register('resource:callbackName', function(source, arg1, arg2)
    return value
end)

-- Client calls (async)
local result = lib.callback.await('resource:callbackName', false, arg1, arg2)
```

**ESX server callbacks** (legacy pattern, still used):
```lua
-- Server
ESX.RegisterServerCallback('resource:name', function(source, cb, ...) cb(result) end)

-- Client
ESX.TriggerServerCallback('resource:name', function(result) ... end, ...)
```

**Net events** for fire-and-forget:
```lua
-- Server → all clients
TriggerClientEvent('resource:eventName', -1, data)
-- Server → specific client
TriggerClientEvent('resource:eventName', source, data)
-- Client → server
TriggerServerEvent('resource:eventName', data)
```

### Job Validation Pattern

Server-side, always validate the caller's job before acting:
```lua
local xPlayer = ESX.GetPlayerFromId(source)
if not xPlayer or xPlayer.job.name ~= 'police' then return false end
```

### Config Tables

`config.lua` is loaded as a `shared_script`, making the `Config` table available on both client and server. Coordinates use `vector3`/`vector4`. Blip, marker, and draw-distance values live in config rather than being hardcoded.

### NUI Pattern

Client communicates with the HTML page:
```lua
SendNUIMessage({ action = 'setVisible', data = { ... } })
SetNuiFocus(true, true)   -- give focus to NUI
SetNuiFocus(false, false) -- release focus

RegisterNUICallback('hideFrame', function(data, cb)
    SetNuiFocus(false, false)
    cb({})
end)
```

Compiled NUI resources (Angular) have their built output at `web/dist/browser/`. Do not edit files in `dist/` directly; edit the source in `web/src/` and rebuild with `ng build`.

### Localization

Resources that use i18n load `locale.lua` + `locales/*.lua` as shared scripts. Translation functions:
- `_(key, ...)` or `Translate(key, ...)` — returns translated string
- `_U(key, ...)` or `TranslateCap(key, ...)` — same but capitalizes first letter

The active locale is set via convar: `esx:locale` (default `en`).

### Society/Job Economy

Job resources that handle money register with `esx_society`:
```lua
TriggerEvent('esx_society:registerSociety', jobName, label, accountName, ...)
```
Player paychecks draw from the society account when `Config.EnableSocietyPayouts = true` in `es_extended/config.lua`.

### ox_lib Usage

`ox_lib` is a dependency of nearly every resource. Commonly used:
- `lib.progressCircle({ label, duration, canCancel, anim })` — progress bar with animation
- `lib.callback.register` / `lib.callback.await` — RPC callbacks
- `lib.zones` — polyzone-style interaction areas
- `lib.notify` — on-screen notifications
