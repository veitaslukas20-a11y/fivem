server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'vames™️'
description 'vms_charcreator'
version '1.1.9'

shared_scripts {
	'config/config.lua', 
	'config/config.translation.lua'
}

client_scripts {
	'config/config.client.lua',
	'client/*.lua',
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config/config.server.lua',
	'server/*.lua',
}

ui_page 'html/ui.html'

files {
	'html/*.*',
	'html/icons/*.*',
	'html/parents/*.png',
	'config/translation.json',
	'config/config.js',
}

escrow_ignore {
	'config/*.lua',
	'client/*.lua',
	'server/*.lua',
	'server/version_check.lua',
}
dependency '/assetpacks'