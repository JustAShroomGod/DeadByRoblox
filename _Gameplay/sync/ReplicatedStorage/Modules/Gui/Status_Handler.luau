local Prefix = "rbxgameasset://Images/"
local UI_SETTINGS = game:GetService('ReplicatedStorage'):WaitForChild('UI_SETTINGS')

local Status_Images = UI_SETTINGS:WaitForChild('Status')

local warned = {}

local StatusFrame = {
	Modules = {}
}
StatusFrame.__index = StatusFrame

local RadialModule = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Circle_Dependency')) -- used to fill radials

for _,module in pairs(script:GetChildren())do
	StatusFrame.Modules[module.Name] = require(module)
end

function StatusFrame:Update(...) -- recieve perkframe, perkname
	local args = {...}
	local Frame, playerValues = args[1], args[2]
	
	for _, module in pairs(StatusFrame.Modules) do
		module:Process(Frame, playerValues, Status_Images)
	end
end

return StatusFrame
