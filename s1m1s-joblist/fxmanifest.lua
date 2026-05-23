server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'adamant'

game 'gta5'

author 's1m1s'
description 'Onex JobList'

lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
}

client_scripts {
	'client/main.lua',
}

server_scripts {
	'server/main.lua',
	'@oxmysql/lib/MySQL.lua',
}

ui_page 'dist/index.html'

files {
    'dist/**',
}