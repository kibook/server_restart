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
	[ 180] = function(sendRestartMessage)
		sendRestartMessage("3 minutes")
		exports.weathersync:setWeather("sunny", 30.0, true, false)
		exports.weathersync:setTime(0, 19, 0, 0, 30000, false)
		exports.weathersync:setTimescale(15)
		exports.events:animpostfxPlay("Mission_FIN1_RideGood")
		exports.events:playAudio("https://redm.khzae.net/ttwii.ogg")
	end,
	[  60] = function(sendRestartMessage)
		sendRestartMessage("1 minute")
	end,
	[  30] = function(sendRestartMessage)
		sendRestartMessage("30 seconds")
	end,
	[  15] = function(sendRestartMessage)
		exports.events:screenFadeOut(15000)
	end,

}

-- Extra actions to perform when a dry run ends
Config.onDryRunEnd = function(sendRestartMessage)
	exports.events:animpostfxStop("Mission_FIN1_RideGood")
	exports.events:screenFadeIn(1000)
	exports.weathersync:resetWeather()
	exports.weathersync:resetTime()
	exports.weathersync:resetTimescale()
end
