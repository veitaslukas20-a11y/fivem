server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'onex-fuel'
author 'poponaut'
description 'Degalines'
version '1.0.1'

ui_page 'web/index.html'

files {
  'web/index.html',
  'web/style.css',
  'web/main.js'
}

shared_scripts {
  'config.lua'
}

client_scripts {
  '@ox_lib/init.lua',
  'client/fuel.lua',
  'client/ui.lua'
}

server_scripts {
  '@ox_lib/init.lua',
  '@es_extended/imports.lua',
  'server/fuel.lua'
}
