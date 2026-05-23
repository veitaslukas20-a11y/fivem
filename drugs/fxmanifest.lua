server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 's1m1s-drugs'
author 's1m1s'
description 'TwoX drugs system'
version '1.0.0'

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target'
}

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@es_extended/imports.lua',
    'server.lua'
}
