game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

dependency 'weathersync' -- https://github.com/kibook/redm-weathersync
dependency 'events'      -- https://github.com/kibook/redm-events

server_only 'yes'

server_scripts {
	'common.lua',
	'config.lua',
	'server.lua'
}
