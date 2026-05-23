server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'adamant'
game 'gta5'
lua54 'yes'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    '@es_extended/locale.lua',
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/**'
}