server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'

author 's1m1s'
description 's1m1s-policezone'
version 'v1.0'

lua54 'yes'

shared_scripts {
	'@ox_lib/init.lua',
	'@es_extended/imports.lua',
}

client_scripts {
	'client/main.lua',
	'client/take.lua',
	'client/menu.lua',
}

server_scripts {
	'config/config.lua',
	'server/main.lua',
}

ui_page 'dist/index.html'

files {
    'dist/**',
}
