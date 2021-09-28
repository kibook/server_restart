fx_version "cerulean"
game "common"

name "server_restart"
author "kibukj"
description "Configurable automatic server restart with notifications"
repository "https://github.com/kibook/server_restart"

-- Can be commented out if Config.webhook is disabled
dependency "discord_rest" -- https://github.com/kibook/discord_rest

server_only "yes"

server_scripts {
	"common.lua",
	"config.lua",
	"server.lua"
}
