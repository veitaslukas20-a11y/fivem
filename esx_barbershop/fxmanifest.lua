server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
shared_script '@fiveguard/ai_module_fg-obfuscated.lua'
fx_version 'adamant'
game 'gta5'
description 'ESX Barber Shop'
version 'legacy'

lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua'
}

server_scripts {
	'@es_extended/locale.lua',
	'locales/br.lua',
	'locales/de.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/es.lua',
	'locales/cs.lua',
	'locales/pl.lua',
	'locales/tr.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/br.lua',
	'locales/de.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/es.lua',
	'locales/cs.lua',
	'locales/pl.lua',
	'locales/tr.lua',
	'config.lua',
	'client/main.lua'
}

dependencies {
	'es_extended',
	'esx_skin'
}
