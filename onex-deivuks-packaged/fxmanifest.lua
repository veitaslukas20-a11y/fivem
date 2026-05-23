server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'adamant'

game 'gta5'

author 'Haroki'
description 'su packinti deivuko scriptai'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'shared/**/*.lua',
    'modules/**/server/*.lua'
}

client_scripts {
    'modules/**/client/*.lua'
}

files {
    './stream/*.ytyp',
    'admins.json',
    'postals.json'
}

this_is_a_map 'yes'

data_file 'DLC_ITYP_REQUEST' './stream/*.ytyp'