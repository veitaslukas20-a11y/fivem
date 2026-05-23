fx_version 'cerulean'
game 'gta5'

author 'dec4t'
description 'dec4t-gangzones'
version 'v1.0'

lua54 'yes'

-- Add these if you have ElectronAC (keep them at the top)
server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'

-- SHARED SCRIPTS - Load config FIRST!
shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua',           -- ← THIS WAS MISSING!
}

client_scripts {
    'client/main.lua',
    'client/take.lua',
    'client/admin.lua',
    'client/menu.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/take.lua',
    'server/admin.lua',
    'server/menu.lua',
}

ui_page 'dist/index.html'

files {
    'dist/**',
}