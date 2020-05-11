--made by exoticnx--

resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_script {
 "GUI.lua",
 "client.lua"
}

server_script { 
	"server.lua",
	'@mysql-async/lib/MySQL.lua'
}