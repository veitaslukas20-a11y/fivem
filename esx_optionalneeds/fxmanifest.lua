server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'adamant'

game 'gta5'

description 'Adds the ability to get drunk'
lua54 'yes'
version '1.0'
legacyversion '1.13.4'

shared_script '@es_extended/imports.lua'

server_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
    'server/main.lua'
}

shared_scripts {
    'client/scripts/staging.js'
}

client_scripts {
    'client/main.lua'
}
