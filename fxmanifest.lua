fx_version "cerulean"
game "common"

name "server_restart"
author "kibukj"
description "Configurable automatic server restart with notifications"
repository "https://github.com/kibook/server_restart"

server_only "yes"

server_scripts {
	"common.lua",
	"config.lua",
	"server.lua"
}
