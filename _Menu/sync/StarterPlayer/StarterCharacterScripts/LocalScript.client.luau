local ResetCFrame = CFrame.new(82.905, 289.55, -29.54)
local LowY = 259.659
local HumanoidRootPart = script.Parent:WaitForChild("HumanoidRootPart")

game:GetService("RunService").RenderStepped:Connect(function()
	if HumanoidRootPart.CFrame.Y <= LowY then
		HumanoidRootPart.CFrame = ResetCFrame
	end
end)