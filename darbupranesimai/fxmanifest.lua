
fx_version 'cerulean'
game 'gta5'

author 'YourName'
description 'Job Boss Global Notifications via ox_lib and 1x-hud'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua'
}

client_scripts {
    '@ox_lib/init.lua',
    'client.lua'
}

server_scripts {
    '@ox_lib/init.lua',
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_lib'
}

ui_page 'html/ui.html'