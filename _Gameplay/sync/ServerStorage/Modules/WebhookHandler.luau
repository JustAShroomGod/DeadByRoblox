local Https : HttpService = game:GetService("HttpService")

local BanLoggerWebhook = if game:GetService("RunService"):IsStudio() then nil else Https:GetSecret("BanLoggerWebhook")
local AntiCheatWebhook = if game:GetService("RunService"):IsStudio() then nil else Https:GetSecret("AntiCheatWebhook")

local module = {}

function module.TriggerPEL(Message : string)
	local ForwardedMessage = Https:JSONEncode({["content"] = Message})
	Https:PostAsync(AntiCheatWebhook, ForwardedMessage)
end

return module
