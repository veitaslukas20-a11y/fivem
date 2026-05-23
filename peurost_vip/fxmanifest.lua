
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
	'@es_extended/imports.lua',
    'config.lua',
}
client_script 'client/*.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
	'server/*.lua',
}