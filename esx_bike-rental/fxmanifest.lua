server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
games { 'gta5' }
author 'NOBODY'
lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}


client_scripts {
    'config.lua',
    'client/*.lua'
}
server_scripts {
    'config.lua',
    'server/*.lua'
}
