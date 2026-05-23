server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
server_script '@esx_mechanicjob/src/include/server.lua'
client_script '@esx_mechanicjob/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'

author 's1m1s'
description 'OneX.lt pataisos'
version 'v1.0'

lua54 'yes'

shared_scripts {
	'@ox_lib/init.lua',
	'@es_extended/imports.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	"server/*.lua"
}

client_scripts {
	"client/*.lua"
}

ui_page 'web/dist/index.html'

files{
	'web/dist/**',
	'client/jobs.lua',
	'client/ui.lua',
	'client/questions.lua',
	'client/zones.lua',
	'client/time.lua',
}