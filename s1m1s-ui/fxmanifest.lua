server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'adamant'

game 'gta5'

author '`s1m1s#8641'
description 'Onex Ui'

lua54 'yes'

shared_scripts {
	'@ox_lib/init.lua',
}

client_scripts {
	'client/main.lua',
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/style.css',
	'html/script.js',
    'html/font/*.*',
}