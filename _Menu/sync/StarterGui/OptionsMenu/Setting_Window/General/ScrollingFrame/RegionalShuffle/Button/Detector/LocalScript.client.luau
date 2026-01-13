local Button : ImageButton = script.Parent

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = {
	Data = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
}

local SERVER_REGION = Modules.Data:Region()

script.Parent.Parent:WaitForChild('Button_Message').Text = "<b>" ..tostring(SERVER_REGION).."</b>"

Button.MouseButton1Click:Connect(function()
	local REGION = Modules.Data:Region(true)
	
	script.Parent.Parent:WaitForChild('Button_Message').Text = "<b>" ..tostring(REGION).."</b>"
end)