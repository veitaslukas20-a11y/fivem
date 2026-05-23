fx_version 'cerulean'
game 'gta5'

author '🖤Deivuks_420🖤#8641'
description 'Deivuks Garage v2'
version 'v1.0'

lua54 'yes'

ui_page 'html/index.html'

files {
	'html/dist/*.js',
	'html/images/*.png',
	'html/fonts/*.otf',
	'html/index.html',
	'html/style.css',
	'html/script.js',
}

shared_scripts {
	'configs/*.lua',
	'locales/*.lua'
}

client_script 'client/main.lua'

server_scripts {
	'server/*.lua',
	'@oxmysql/lib/MySQL.lua',
	--'@mysql-async/lib/MySQL.lua', --⚠️ TURN IT ON IF YOU ARE NOT USING OXMYSQL ⚠️,
    'module.js'
}

