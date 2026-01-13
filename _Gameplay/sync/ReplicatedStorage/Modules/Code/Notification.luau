local Camera : Camera = workspace.CurrentCamera
local ReplicatedStorage : ReplicatedStorage, RunService : RunService ,TweenService : TweenService = game:GetService("ReplicatedStorage"), game:GetService("RunService"), game:GetService("TweenService")
local Prefab : Folder = script:WaitForChild("Notification")

local module = {}
module.__index = module

local TweenInfo_ = TweenInfo.new(
	0.3,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

local Threshold = 70; -- for it to be considered far

local NotificationSettings = {
	Min = 35; -- too close to notify
	Max = 100000; -- infinate range
}

local Types = {
	["Generator"] = "rbxassetid://9628972813";
	['Generator_Miss'] = "rbxassetid://13321880274";
	["Default"] = "rbxassetid://15139296115";
	["Totem"] = "rbxassetid://12278850506";
	['Hatch'] = "rbxassetid://9629002586";
	['Exit'] = "rbxassetid://120475661616351";
	['Locker'] = "rbxassetid://9825938846";
	['Hook'] = "rbxassetid://116615144150564";
}

function GenerateNoise(Sound : Sound)
	local Sound_Remote = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Sound_Event')

	Sound_Remote:Fire("Loud_Noise", Sound)
end

function module.New(DesiredCFrame : CFrame, Length : NumberValue, Type : StringValue)
	if (game.Players.LocalPlayer:DistanceFromCharacter(DesiredCFrame.Position) < NotificationSettings.Min and Type == "Default") then return end -- too close to notify so don't

	local Notification = {}
	setmetatable(Notification,module)

	Notification.Object = Prefab:Clone()
	Notification.Object.Parent = Camera
	Notification.Object.CFrame = if typeof(DesiredCFrame) == "CFrame" then DesiredCFrame else DesiredCFrame.CFrame
	Notification.Object.Main.Type.Image = if Types[Type] then Types[Type] else Types.Default

	Notification.Length = Length or 5

	Notification.Connections = {
		TweenCompletedStart = nil;
		TweenCompletedEnd = nil;
	}

	if Type ~= "Locker" then
		if game.Players.LocalPlayer:DistanceFromCharacter(DesiredCFrame.Position) > Threshold then
			GenerateNoise('Far')
		else
			GenerateNoise('Close')
		end
	end

	Notification:Create()

	return Notification
end

function module:Create()

	if RunService:IsClient() then
		local TweenStart = TweenService:Create(self.Object.Main,TweenInfo_,{Size = UDim2.fromOffset(100,100)})
		local TweenEnd = TweenService:Create(self.Object.Main,TweenInfo_,{Size = UDim2.fromOffset(0,0)})

		self.Connections.TweenCompletedEnd = TweenEnd.Completed:Connect(function()
			self:Destroy()
		end)

		self.Connections.TweenCompletedStart = TweenStart.Completed:Connect(function()
			task.wait(self.Length)

			TweenEnd:Play()
		end)

		TweenStart:Play()
	end
end

function module:Destroy() : "Destroys the notification object"
	self.Object:Destroy()

	for _,Connection in pairs(self.Connections) do
		Connection:Disconnect()
		Connection = nil
	end

	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
end

return module
