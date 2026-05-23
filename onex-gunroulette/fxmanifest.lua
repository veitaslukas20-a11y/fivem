server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'adamant'
games { 'gta5' }

lua54 'yes'

shared_scripts {
  '@ox_lib/init.lua',
  '@es_extended/imports.lua',
  'config.lua',
}

client_scripts {
  "main/client.lua",
}

server_scripts {
  "@oxmysql/lib/MySQL.lua",
  "main/server.lua",
}

ui_page 'html/index.html'

files {
  'html/*',
}