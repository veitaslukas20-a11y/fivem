server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
shared_script '@fiveguard/ai_module_fg-obfuscated.lua'
resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'
description 'esx menu list'
version '1.0.2'
client_scripts {
	'@es_extended/client/wrapper.lua',
	'client/main.lua'
}
ui_page 'html/ui.html'
files {
	'html/ui.html',
	'html/css/app.css',
	'html/js/mustache.min.js',
	'html/js/app.js',
	'html/fonts/pdown.ttf',
	'html/fonts/bankgothic.ttf'
}
dependency 'es_extended'
client_script "@errorlog/client/cl_errorlog.lua"
