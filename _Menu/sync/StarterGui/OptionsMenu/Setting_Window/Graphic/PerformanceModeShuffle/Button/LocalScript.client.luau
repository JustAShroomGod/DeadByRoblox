local Button : TextButton = script.Parent
local text = script.Parent.state

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = {
	Data = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
}

local PERFORMANCE_MODE = Modules.Data:Performance()

text.Text = "<b>"..tostring(PERFORMANCE_MODE).."</b>"

Button.MouseButton1Click:Connect(function()
	local PERFORMANCE_MODE = Modules.Data:Performance(true)
	
	text.Text = "<b>"..tostring(PERFORMANCE_MODE).."</b>"
end)