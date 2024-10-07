fx_version "cerulean"
game "gta5"

author "Kugelspitzer"

name "Vision NameChange"
description "Vision NameChange"
version "1.0.0"

shared_script {
    '@es_extended/imports.lua',
    "Config.lua"
}

lua54 'yes'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/styles.css',
    'html/scripts.js',
    'html/image.png',
    'html/assets/*.png'
}

client_scripts {
    "Config.lua",
    "client/main.lua"
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "Config.lua",
    "server/main.lua"
}

