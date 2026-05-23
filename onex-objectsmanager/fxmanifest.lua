server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'

author 's1m1s'
description 'OneX Objects Manager'

version 'v1.0'

lua54 'yes'

shared_scripts {
	'@ox_lib/init.lua',
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}