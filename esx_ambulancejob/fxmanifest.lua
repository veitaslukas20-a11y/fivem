server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'adamant'
game 'gta5'

description 'Reworked ESX ambulance job'
author 's1m1s'
version 'v1.0'

lua54 'yes'

shared_scripts {
	'@ox_lib/init.lua',
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/*.lua'
}

client_scripts {
	'data/data.lua',
	'client/*.lua',
}

ui_page 'web/dist/browser/index.html'
-- ui_page "http://localhost:4200"

files {
	"web/dist/browser/index.html",
	"web/dist/browser/**/*",
}