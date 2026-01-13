local ReplicatedStorage : ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local Event = RemoteEvents:WaitForChild("Notification")

local Code = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Code"))

Event.OnClientEvent:Connect(function(DesiredCFrame : CFrame, Length : NumberValue, Type : StringValue)
	Code:AddNotification(DesiredCFrame, Length, Type)
end)