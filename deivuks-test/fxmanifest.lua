server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
shared_script '@fiveguard/ai_module_fg-obfuscated.lua'
fx_version 'cerulean'
game 'gta5'
author '🖤Deivuks_420🖤#8641'
description 'Deivuks'
version 'v1.0'
lua54 'yes'
shared_scripts { 
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
}
client_scripts {
	'client/main.lua',
}
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua',
}


--data_file 'ACTION_TABLE_DEFINITIONS' 'data/interrelations.meta'