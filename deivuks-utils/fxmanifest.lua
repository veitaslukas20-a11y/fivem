server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'
author '`s1m1s#8641'
description 'Deivuks Utils'
version 'v1.0'

lua54 'yes'

shared_scripts {
	'@ox_lib/init.lua',
	'@es_extended/imports.lua',
}

client_script 'client/main.lua'

server_scripts {
	'server/main.lua',
	'@oxmysql/lib/MySQL.lua',
}