server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'bodacious'

game 'gta5'

lua54 'yes'

description 'OneX Speedcamera'

version '0.0.1'

shared_scripts {
  '@es_extended/imports.lua',
  '@ox_lib/init.lua'
}

client_scripts {
  'client/main.lua'
}