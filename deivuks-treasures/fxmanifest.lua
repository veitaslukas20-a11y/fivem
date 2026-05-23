server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'

author 's1m1s'

description 'Onex Treasures'

version 'v1.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
	'@es_extended/imports.lua',
}

client_scripts {
	'client/main.lua',
}

server_scripts {
	'config.lua',
	'server/main.lua',
}