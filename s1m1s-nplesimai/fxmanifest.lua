server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'adamant'

game 'gta5'

author 's1m1s'
description 'Onex namų plėšimas'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
	'@ox_lib/init.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config.lua',
    'server/main.lua',
}

client_scripts {
	'client/main.lua',
}