server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5' 

author 's1m1s'
description 's1m1s Pack'
version 'v1.0'

lua54 'yes'

use_fxv2_oal 'yes'

shared_scripts {
   '@ox_lib/init.lua',
   '@es_extended/imports.lua',
}

server_scripts{
   '@oxmysql/lib/MySQL.lua',
   './**/ServerConfig.lua',
   './**/config.lua',
   './**/server/*.lua',
}


client_scripts {
   './**/config.lua',
   './**/client/*.lua'
}

dependency 'ox_lib'

data_file 'DLC_ITYP_REQUEST' 'stream/mads.ytyp'