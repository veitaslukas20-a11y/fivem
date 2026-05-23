server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'adamant'
game 'gta5'

description 'ESX Basic Needs'
version 'legacy'

lua54 'yes'

shared_script {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    '@oxmysql/lib/MySQL.lua',
}

server_scripts {
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}