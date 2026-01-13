local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Data_Module = require(game.ReplicatedStorage.Modules.Data)
local Save_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Rigged Game'))

local this = {}

this.Player = nil
this.initialized = false
this.Stacks = 0
this.Tier = 0

function this.GenUpdate()
	this.Stacks = workspace:WaitForChild("MatchValues"):WaitForChild("GeneratorsRepaired").Value
	script.Parent:SetAttribute("Stacks", this.Stacks)
	script.Parent:SetAttribute("Percentage", 1 - (Save_Module.Tiers[this.Tier]/100 * this.Stacks))
end

function this.initialize(Player: Player, Tier) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier

	workspace:WaitForChild("MatchValues"):WaitForChild("GeneratorsRepaired").Changed:Connect(this.GenUpdate)
	return
end

return this