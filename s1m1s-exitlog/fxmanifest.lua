server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'

author 's1m1s'
description 'OneX exit log'
version 'v1.0'

lua54 'yes'

shared_scripts { 
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
}

client_scripts {
	'client/main.lua',
}

server_scripts {
	'server/main.lua',
}