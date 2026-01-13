local module = {}
local http = game:GetService('HttpService')
local encryptor = require(script:WaitForChild('library'):WaitForChild('aeslua'))
local Hash = require(script.Parent:WaitForChild('Hash'))

local BanLoggerWebhook = if game:GetService("RunService"):IsStudio() then nil else http:GetSecret("BanLoggerWebhook")
local AntiCheatWebhook = if game:GetService("RunService"):IsStudio() then nil else http:GetSecret("AntiCheatWebhook")

local Password = "Alt_Dentified"

function module:Encrypt(data : "table", Player : Player)
	local converted = http:JSONEncode(data)
	
	converted = encryptor.encrypt(Password..'_'..Player.UserId, converted, 16, 2)
	
	return converted
end

function module:Store(data : "table")
	local converted = nil
	
	converted = Hash:Generate(data, 50)
	
	return converted
end

function module:Decrypt(data : string, Player : Player)
	local raw_data
	local success, _err = pcall(function()
		raw_data = encryptor.decrypt(Password..'_'..Player.UserId, data, 16, 2)
	end)
	
	if not success and _err then
		local DiscordMsg = {
			["content"] = "Anti-Cheat is tracking suspicious activity from "..Player.Name..' for corrupted data (could be false positive, but i doubt it - cheeta)'
		}

		DiscordMsg = http:JSONEncode(DiscordMsg)
		http:PostAsync(AntiCheatWebhook, DiscordMsg)
		
		task.wait(10)
		Player:Kick('Data got corrupted!')
	end
	
	raw_data = http:JSONDecode(raw_data)
	
	return raw_data
end

return module
