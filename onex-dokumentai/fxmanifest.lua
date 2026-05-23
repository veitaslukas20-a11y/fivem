server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'

version '1.0'

lua54 'yes'

ui_page 'web/dist/index.html'

files {
	'web/dist/**'
}

shared_scripts {
	'@ox_lib/init.lua',
	'@es_extended/imports.lua',
    'config.lua'
}

client_script 'client/main.lua'

server_scripts {
	'server/main.lua',
	'@oxmysql/lib/MySQL.lua',
}