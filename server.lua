function GetCurrentTime()
	local date = os.date("*t")
	return HMSToTime(date.hour, date.min, date.sec)
end

function GetNextRestartTime()
	local currentTime = GetCurrentTime()
	local minRemaining, nextRestartTime

	for _, restartTime in ipairs(Config.RestartTimes) do
		local remaining = (86400 - currentTime + restartTime) % 86400

		if not minRemaining or remaining < minRemaining then
			minRemaining = remaining
			nextRestartTime = restartTime
		end
	end

	return nextRestartTime
end

local RestartTime = GetNextRestartTime()
local DryRun = false

function SendRestartMessage(source, time)
	if not source or source == 0 then
		print('Server will restart in ' .. time)
	else
		if DryRun then
			TriggerClientEvent('chat:addMessage', source, {
				color = {255, 255, 128},
				args = {'[Test] Server will restart in ' .. time}
			})
		else
			TriggerClientEvent('chat:addMessage', source, {
				color = {255, 255, 128},
				args = {'Server will restart in ' .. time}
			})
		end
	end
end

function GetRemainingTime()
	return (86400 - GetCurrentTime() + RestartTime) % 86400
end

RegisterCommand('nextRestart', function(source, args, raw)
	local remaining = GetRemainingTime()
	local h1, m1, s1 = TimeToHMS(remaining)
	local h2, m2, s2 = TimeToHMS(RestartTime)
	SendRestartMessage(source, string.format("%d hours, %d minutes, %d seconds (%.2d:%.2d:%.2d)", h1, m1, s1, h2, m2, s2))
end, false)

function KickAllPlayers()
	for _, id in ipairs(GetPlayers()) do
		DropPlayer(id, 'Server restarting')
	end
end

function QuitServer()
	KickAllPlayers()

	SetTimeout(5000, function()
		ExecuteCommand('quit')
	end)
end

function EndDryRun()
	exports.events:screenFadeIn(1000)

	exports.weathersync:resetWeather()
	exports.weathersync:resetTime()
	exports.weathersync:resetTimescale()

	RestartTime = GetNextRestartTime()
	DryRun = false
end

RegisterCommand('restartServerDryRun', function(source, args, raw)
	DryRun = true
	RestartTime = GetCurrentTime() + 190
end, true)

RegisterCommand('restartServer', function(source, args, raw)
	RestartTime = GetCurrentTime() + 190
end, true)

local MessageSent = {}

CreateThread(function()
	while true do
		Wait(1000)

		local remaining = GetRemainingTime()

		if remaining <= 3600 and not MessageSent[3600] then
			SendRestartMessage(-1, '1 hour')
			MessageSent[3600] = true
		elseif remaining <= 1800 and not MessageSent[1800] then
			SendRestartMessage(-1, '30 minutes')
			MessageSent[1800] = true
		elseif remaining <= 900 and not MessageSent[900] then
			SendRestartMessage(-1, '15 minutes')
			MessageSent[900] = true
		elseif remaining <= 600 and not MessageSent[600] then
			SendRestartMessage(-1, '10 minutes')
			MessageSent[600] = true
		elseif remaining <= 300 and not MessageSent[300] then
			SendRestartMessage(-1, '5 minutes')
			MessageSent[300] = true
		elseif remaining <= 180 and not MessageSent[180] then
			SendRestartMessage(-1, '3 minutes')
			MessageSent[180] = true
			exports.weathersync:setWeather('sunny', 30.0, true, false)
			exports.weathersync:setTime(19, 0, 0, 30000, false)
			exports.weathersync:setTimescale(15)
			exports.events:playAudio(Config.Music)
		elseif remaining <= 60 and not MessageSent[60] then
			SendRestartMessage(-1, '1 minute')
			MessageSent[60] = true
		elseif remaining <= 30 and not MessageSent[30] then
			SendRestartMessage(-1, '30 seconds')
			MessageSent[30] = true
		elseif remaining <= 15 and not MessageSent[15] then
			exports.events:screenFadeOut(15000)
			MessageSent[15] = true
		elseif remaining <= 12 and not MessageSent[12] then
			CreateThread(function()
				Wait(10000)

				if DryRun then
					EndDryRun()
				else
					QuitServer()
				end
			end)
			MessageSent[12] = true
		elseif remaining <= 10 then
			SendRestartMessage(-1, string.format('%d seconds', remaining))
		end
	end
end)
