fx_version 'adamant'
game 'common'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua',
    '@mysql-async/lib/MySQL.lua'
}
