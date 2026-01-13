local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')

local Data_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Code_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('ExperimentalTech'))

local Events = require(ServerScripts:WaitForChild("Event System"):WaitForChild("Events"))

local module = {}

function module:Activate(player, ...)
	local args = {...}
	local hasPerk, perkTier = Data_Module:GetPerk("ExperimentalTech", player)
	
	if not hasPerk then return warn("Cheating") end

	Events.Survivor.onCustomEvent:Fire("ExperimentalTech", args[2], player)
end

return module
