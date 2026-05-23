server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_script '@es_extended/imports.lua'
shared_script '@ox_lib/init.lua'

client_script 'neon.lua'  -- neonai
client_script 'finger.lua'  -- piršto rodymas
client_script 'handsup.lua'  -- ranku pakelimas
client_script 'tupimas.lua'  -- CTRL sliauzimas
client_script 'dalys.lua'  -- /dalys
client_script 'apsirengt.lua'  -- /apsirengti
client_script 'vehiclecmds.lua'  -- masinu komandos
client_script 'blips.lua' -- Blipai
client_script 'recoil.lua' -- pd
client_script 'fonts.lua'
client_script 'speednotire.lua'
client_script 'pausemenu.lua'
client_script 'masinosstumimas.lua'

server_script 'info.lua'