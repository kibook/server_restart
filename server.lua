local function getCurrentTime()
	local date = os.date("*t")
	return HMSToTime(date.hour, date.min, date.sec)
end

local function getNextRestartTime()
	local currentTime = getCurrentTime()
	local minRemaining, nextRestartTime

	for _, restartTime in ipairs(Config.restartTimes) do
		local remaining = (86400 - currentTime + restartTime) % 86400

		if not minRemaining or remaining < minRemaining then
			minRemaining = remaining
			nextRestartTime = restartTime
		end
	end

	return nextRestartTime
end

local restartTime = getNextRestartTime()
local dryRun = false

local function formatRestartMessage(time)
	if dryRun then
		return "[TEST] Server will restart in " .. time
	else
		return "Server will restart in " .. time
	end
end

local function printRestartMessage(time)
	print(formatRestartMessage(time))
end

local function sendRestartMessage(source, time)
	if not source or source == 0 then
		printRestartMessage(time)
	else
		TriggerClientEvent("chat:addMessage", source, {
			color = {255, 255, 128},
			args = {formatRestartMessage(time)}
		})
	end
end

local function sendRestartMessageToAll(time)
	sendRestartMessage(-1, time)
end

local function executeWebhook(message)
	local data = {
		embeds = {
			{
				color = Config.webhookColour,
				description = message
			}
		}
	}

	return exports.discord_rest:executeWebhookUrl(Config.webhook, data):next(nil, function(err)
		print("Execution of webhook failed: " .. err)
	end)
end

local function sendRestartMessageToDiscord(time)
	executeWebhook(formatRestartMessage(time))
end

local function broadcastRestartMessage(time)
	printRestartMessage(time)

	sendRestartMessageToAll(time)

	if Config.webhook then
		sendRestartMessageToDiscord(time)
	end
end

local function getRemainingTime()
	return (86400 - getCurrentTime() + restartTime) % 86400
end

local function prepareToQuit()
	local p = promise.new()

	if Config.webhook then
		executeWebhook("Server is restarting"):next(function()
			p:resolve()
		end)
	else
		p:resolve()
	end

	return p
end

local function quitServer()
	prepareToQuit():next(function()
		ExecuteCommand("quit Restarting")
	end)
end

local function endDryRun()
	if Config.onDryRunEnd then
		Config.onDryRunEnd(sendRestartMessageToAll)
	end
	restartTime = getNextRestartTime()
	dryRun = false
end

local function initializeActions()
	local actions = {}

	for time, action in pairs(Config.actions) do
		table.insert(actions, {time = time, perform = action, performed = false})
	end

	table.sort(actions, function(a, b)
		return a.time > b.time
	end)

	return actions
end

RegisterCommand("next_restart", function(source, args, raw)
	local remaining = getRemainingTime()
	local h1, m1, s1 = TimeToHMS(remaining)
	local h2, m2, s2 = TimeToHMS(restartTime)
	sendRestartMessage(source, string.format("%d hours, %d minutes, %d seconds (%.2d:%.2d:%.2d)", h1, m1, s1, h2, m2, s2))
end, false)

RegisterCommand("restart_server", function(source, args, raw)
	local delay = 300

	for i = 1, #args do
		if args[i] == "-delay" then
			delay = tonumber(args[i + 1]) or delay
		elseif args[i] == "-dryrun" then
			dryRun = true
		end
	end

	restartTime = getCurrentTime() + delay
end, true)

Citizen.CreateThread(function()
	local actions = initializeActions()

	while true do
		local remaining = getRemainingTime()

		for _, action in ipairs(actions) do
			if remaining <= action.time and action.perform then
				action.perform(broadcastRestartMessage)
				action.perform = nil
			end
		end

		if remaining <= 10 and remaining > 0 then
			sendRestartMessageToAll(string.format("%d seconds", remaining))
		elseif remaining <= 0 then
			if dryRun then
				endDryRun()
			else
				quitServer()
			end

			actions = initializeActions()
		end

		Citizen.Wait(1000)
	end
end)
