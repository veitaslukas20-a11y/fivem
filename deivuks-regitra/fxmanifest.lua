server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'

author '`s1m1s#8641'
description 'Deivuks Regitra'
version 'v1.0'

lua54 'yes'

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/style.css',
	'html/script.js',
    'html/font/*.*',
	'html/icon/*.*',
}

shared_scripts {
	'@es_extended/imports.lua',
}

client_script 'client/main.lua'

server_scripts {
	'server/main.lua',
}