--made by exoticnx--

fx_version 'adamant' 
games { 'gta5' } 
 
description 'sm_properties scripts'

client_script {
    "GUI.lua",
    "client.lua"
}
   
server_script { 
    "server.lua",
    '@mysql-async/lib/MySQL.lua'
}