server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'adamant'
game 'gta5'
description 'devcore - by bary - discord - https://discord.gg/zcG9KQj3sa'
credits 'Pravidla pro jednani s produkty od sluzby devcore naleznete na discordu'
server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'locales/cs.lua',
	'locales/en.lua',
	'locales/de.lua',
	'locales/fr.lua',
	'locales/pl.lua',
	'server/server.lua'
}
client_scripts {
	'@es_extended/locale.lua',
	'@NativeUI/NativeUI.lua',
	'config.lua',
	'locales/cs.lua',
	'locales/en.lua',
	'locales/de.lua',
	'locales/fr.lua',
	'locales/pl.lua',
	'client/cigarette.lua',
	'client/cigar.lua',
	'client/joint.lua'
}