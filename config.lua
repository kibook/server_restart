Config = {}

-- List of times when the server restarts each day.
Config.restartTimes = {
	HMSToTime(2, 0, 0)
}

-- List of actions to perform at certain numbers of seconds prior to restarting.
Config.actions = {
	[3600] = function(sendRestartMessage)
		sendRestartMessage("1 hour")
	end,
	[1800] = function(sendRestartMessage)
		sendRestartMessage("30 minutes")
	end,
	[ 600] = function(sendRestartMessage)
		sendRestartMessage("10 minutes")
	end,
	[ 300] = function(sendRestartMessage)
		sendRestartMessage("5 minutes")
	end,
	[  60] = function(sendRestartMessage)
		sendRestartMessage("1 minute")
	end,
	[  30] = function(sendRestartMessage)
		sendRestartMessage("30 seconds")
	end

}

-- Extra actions to perform when a dry run ends
--Config.onDryRunEnd = function() end
