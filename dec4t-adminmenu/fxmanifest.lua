fx_version 'cerulean'
game 'gta5'

author 'dec4t'
description 'dec4t-adminmenu'
version 'v1.0'

lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
}

client_scripts {
	'client/*.lua',
}

server_scripts {
	'server/*.lua',
	'@oxmysql/lib/MySQL.lua',
	--'@mysql-async/lib/MySQL.lua', --⚠️ TURN IT ON IF YOU ARE NOT USING OXMYSQL ⚠️
}

ui_page 'dist/index.html'

files {
    'dist/**',
}
