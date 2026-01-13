local ReplicatedStorage : ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remote : RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SystemMessage")

local module = {}

function module.SendMessage(Message : string)
	Remote:FireAllClients(Message)
end

return module
