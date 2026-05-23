server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5' 
author 'Boost#4383'
description 'Discord rich presence with ESX compatibility'
version '1.0.5'

lua54 'yes'

shared_scripts {
	'config.lua',
	'@ox_lib/init.lua',
} 

client_script {
	'client/main.lua'
}

server_script {
	'server/main.lua'
}