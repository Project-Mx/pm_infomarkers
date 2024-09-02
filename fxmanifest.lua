shared_script "@ReaperV4/bypass.lua"
lua54 "yes" -- needed for Reaper


fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Project M'
description 'Infomarkers'
version '1.0.0'


shared_scripts {
  '@ox_lib/init.lua',
	'@es_extended/locale.lua',
  'config.lua'
}
client_scripts {
  'client.lua'
}

server_script {
	'server.lua'
}

escrow_ignore {
  'config.lua'
}

files {
  'postals.json'
}
