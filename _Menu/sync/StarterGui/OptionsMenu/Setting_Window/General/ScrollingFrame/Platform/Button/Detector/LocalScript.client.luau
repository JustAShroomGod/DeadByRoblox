local Remotes : Folder = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
local Button : ImageButton = script.Parent

local Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))
local Platform_Type = Module:Platform()
local Switching = false

script.Parent.Parent:WaitForChild('Button_Message').Text = Platform_Type

Button.MouseButton1Click:Connect(function()
	if Switching then return end
	Switching = true
	Platform_Type = Module:Platform(true)
	script.Parent.Parent:WaitForChild('Button_Message').Text = Platform_Type
	Switching = false
end)