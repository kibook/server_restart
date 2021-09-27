fx_version "cerulean"
games "common"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

name "server_restart"
author "kibukj"
description "Configurable automatic server restart with notifications"
repository "https://github.com/kibook/server_restart"

dependency "events"
dependency "weathersync"

server_only "yes"

server_scripts {
	"common.lua",
	"config.lua",
	"server.lua"
}
