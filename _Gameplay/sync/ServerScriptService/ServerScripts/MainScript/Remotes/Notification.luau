local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
local Code = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local WebhookHandler = require(game.ServerStorage.Modules.WebhookHandler)

local remote = {}

local function GrabRemote()
	
	for _,r in pairs(RemoteStorage:GetChildren())do
		
		if string.lower(r.Name) == string.lower(script.Name) then
			return r
		end
	end
	
	return false
end

function remote.new()
	local self = {}
	setmetatable(self, remote)
	
	local connection = GrabRemote()
	
	if connection then
		
		connection.OnServerEvent:Connect(function(Player : Player,DesiredCFrame : CFrame, Length : NumberValue, Type : StringValue, DesiredPlayer : Player)
			warn(Player, DesiredCFrame, DesiredPlayer, Type, Length)
			local ForwardedMessage = "[***NOT BANNED***] Anti-Cheat is tracking suspicious activity from "..Player.Name..' for trying to send notifications to ' .. DesiredPlayer.Name
			WebhookHandler.TriggerPEL(ForwardedMessage)
			--Code:AddNotification(DesiredCFrame,Length,Type,DesiredPlayer)
		end)
	elseif script.Name ~= "Template" then
		warn('Remote does not exist:', script.Name)
	end
	
	return self
end

return remote.new()
