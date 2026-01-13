local TextChatService : TextChatService, ReplicatedStorage : ReplicatedStorage = game:GetService("TextChatService"), game:GetService("ReplicatedStorage")

local Remote : RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SystemMessage")

local TextChannels = TextChatService:WaitForChild("TextChannels")
local RBXSystem = TextChannels:WaitForChild("RBXSystem")

Remote.OnClientEvent:Connect(function(Message)
	RBXSystem:DisplaySystemMessage(Message)
end)