server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'adamant'

game 'gta5'

description 'ESX Status'
version 'legacy'

lua54 'yes'

shared_script {
	'@ox_lib/init.lua',
	'@es_extended/imports.lua',
	'config.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

client_scripts {
	'client/classes/status.lua',
	'client/main.lua'
}