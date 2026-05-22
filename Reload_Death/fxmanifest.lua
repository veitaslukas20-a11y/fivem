server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'adamant'
game 'gta5'
description 'Reload Death'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'client/death.lua',
}

server_scripts {
    'server/death.lua',
    "@oxmysql/lib/MySQL.lua"
}
