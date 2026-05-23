server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version "cerulean"
games { "gta5", "rdr3" }
lua54 "yes"

title "OneX Case Opening"
description "OneX Case Opening"
author "OneX"
version "1.0.0"

client_script {
	"client/**/*.lua"
}
server_script {
	"server/**/*.lua"
}

shared_script {
	"config.lua",
    "@ox_lib/init.lua",
    '@es_extended/imports.lua',
}

ui_page "web/dist/browser/index.html"
--ui_page "http://localhost:4200/index.html"

files {
	"web/dist/browser/index.html",
	"web/dist/browser/**/*",
}
