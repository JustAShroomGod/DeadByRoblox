local Events = require(game.ServerScriptService["Event System"].Events)

local PowerModel = script.Parent.Parent.Parent
local PowerValues = PowerModel.PowerValues

local AddonValue = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild("Dark Orb"))

local this = {}

function this.Init()
	PowerValues:SetAttribute("Phantasm_Maximum",AddonValue.Phantasm_Maximum)
	PowerValues:SetAttribute("InstantlySpawn", AddonValue.InstantlySpawn)
	warn("REQUIRED!")
end


return this
