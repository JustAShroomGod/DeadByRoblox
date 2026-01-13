local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Data_Module = require(game.ReplicatedStorage.Modules.Data)
local Save_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('SaveTheBestForLast'))

local this = {}

this.Player = nil
this.initialized = false
this.Tier = 0

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier

	script.Parent:GetAttributeChangedSignal("Stacks"):Connect(StacksUpdated)
	Events.Killer.onAttack.Event:Connect(onAttack)
end

function StacksUpdated()

	local Stacks = script.Parent:GetAttribute("Stacks")
	local WipeBonus = Save_Module.Bonuses[this.Tier] / 100
	WipeBonus *= Stacks

	_G.GetValue(this.Player.Name, "WipeSpeed"):Remove("STBFL")

	if (Stacks < 1) then
		return
	end

	_G.GetValue(this.Player.Name, "WipeSpeed"):Add("STBFL", WipeBonus, -1)
end

function onAttack(State, PlayerName)
	if (State ~= "Hit" or PlayerName == nil) then
		return
	end

	local Player = game.Players:FindFirstChild(PlayerName)

	if (Player == nil) then
		return
	end

	if not script.Parent:GetAttribute("Stacks") then
		script.Parent:SetAttribute("Stacks", 0)
	end

	local Stacks = script.Parent:GetAttribute("Stacks")

	if (Code_Module:IsObsession(Player)) then
		script.Parent:SetAttribute("Stacks", math.clamp(Stacks - Save_Module.Tiers[this.Tier], 0, Save_Module.MaxStacks[this.Tier]))
	else
		script.Parent:SetAttribute("Stacks", math.clamp(Stacks + 1, 0, Save_Module.MaxStacks[this.Tier]))
	end
end

return this