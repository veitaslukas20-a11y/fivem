server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'adamant'

game 'gta5'

description 'ESX Taxi Job'
lua54 'yes'
version '1.0'
legacyversion '1.9.1'

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'client/*.lua'
}

server_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'server/*.lua'
}

dependency 'es_extended'
