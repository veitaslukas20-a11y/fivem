server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'bodacious'
game 'gta5'
client_script "client.lua"
server_scripts {
	'@mysql-async/lib/MySQL.lua',
	"server.lua"
}
files {
	"html/index.html",
	"html/index.js",
	"html/config.js",
	"html/index.css",
	"html/bg.jpg",
	"html/bg-dark.jpg",
	"html/icons/filemgr.jpg",
	"html/icons/firefox.png",
	"html/icons/menu.png",
	"html/icons/tuner.png"
}
ui_page "html/index.html"
dependency "es_extended"
