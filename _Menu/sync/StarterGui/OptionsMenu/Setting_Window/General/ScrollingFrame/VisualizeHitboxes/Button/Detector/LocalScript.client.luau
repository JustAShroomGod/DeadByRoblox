local Remotes : Folder = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
local Button : ImageButton = script.Parent

local Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))
local Visualize = Module:VisualizeAttacks()
local Switching = false

script.Parent.Parent:WaitForChild('Button_Message').Text = tostring(Visualize)

Button.MouseButton1Click:Connect(function()
	if Switching then return end
	Switching = true
	Visualize = Module:VisualizeAttacks(true)
	script.Parent.Parent:WaitForChild('Button_Message').Text = tostring(Visualize)
	Switching = false
end)