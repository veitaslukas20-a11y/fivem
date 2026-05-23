client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'

author 's1m1s'
description 'OneX minigames'

version 'v1.0'

lua54 'yes'

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
}

client_scripts {
	'client/main.lua',
}