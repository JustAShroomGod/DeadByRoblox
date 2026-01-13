local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')

local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)

local module = {}


function module:Fire(Player : Player, Arguments : "table")
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')
	
	local Command : boolean = Arguments[2]
	
	print(Player, Arguments)
	
end

return module
