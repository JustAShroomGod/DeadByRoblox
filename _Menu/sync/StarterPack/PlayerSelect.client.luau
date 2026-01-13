local Players : Players, RunService : RunService, UserInputService : UserInputService = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService")
local PlayerGui = Players.LocalPlayer.PlayerGui
local Mouse : Mouse = Players.LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local Handler = require(PlayerGui:WaitForChild("Statistic_Screen"):WaitForChild("Handler"))

local Highlight = Instance.new("Highlight")
Highlight.FillTransparency = 1
Highlight.Parent = Camera

RunService.RenderStepped:Connect(function()
	if not Mouse.Target or not Mouse.Target.Parent then return end
	
	if Mouse.Target.Parent:FindFirstChild("Humanoid") and Players:FindFirstChild(Mouse.Target.Parent.Name) then
		Highlight.Parent = Mouse.Target.Parent
	else
		Highlight.Parent = Camera
	end
end)

Mouse.Button1Down:Connect(function()
	if not Mouse.Target or not Mouse.Target.Parent then return end

	if Mouse.Target.Parent:FindFirstChild("Humanoid") and Players:FindFirstChild(Mouse.Target.Parent.Name) then
		Handler.Connect(Players:FindFirstChild(Mouse.Target.Parent.Name))
	end
end)
