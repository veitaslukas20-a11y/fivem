server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
game 'common'
fx_version 'cerulean'
author 'S1M1S'
description 'Scanner - kodas'

server_script 'server.lua'
client_script 'client.lua'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}
