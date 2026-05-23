fx_version 'adamant'
game 'gta5'
description 'ESX Mechanic Job'
version 'legacy'
lua54 'yes'
shared_scripts {
    'modules/commands.js',
	'@ox_lib/init.lua',
	'@es_extended/imports.lua',
}
client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'config.lua',
	'saskaitos.lua',
	'client/main.lua'
}
server_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'server/main.lua'
}