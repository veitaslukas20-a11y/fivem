server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'vames™️'
description 'vms_clothestore'
version '1.1.9'

shared_scripts {
	'config.lua',
	'config.prices.lua',
}

client_scripts {
	'client/components_qb.lua',
	'client/*.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua',
}

ui_page 'html/ui.html'

files {
	'html/*.*',
	'html/icons/*.*',
	'translation.js',
	'config.js',
}

escrow_ignore {
	'config.lua',
	'config.prices.lua',
	'client/*.lua',
	'server/*.lua',
	'server/version_check.lua',
}
dependency '/assetpacks'