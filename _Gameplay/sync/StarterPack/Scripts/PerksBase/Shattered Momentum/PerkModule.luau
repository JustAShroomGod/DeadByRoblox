local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("Shattered Momentum"))

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
	
	Events.Killer.onBreak.Event:Connect(PalletBroken)
	Events.Killer.onAttack.Event:Connect(DownedSurvivor)
end

function PalletBroken(Player : Player, Type : "Pallet/Wall")

	if (Player.Name ~= this.Player.Name) then
		return
	end

	if Type == "Pallet" then
		script.Parent:SetAttribute("Count",math.clamp(script.Parent:GetAttribute("Count") + 1, 0, Perk_Module.Tiers[this.Tier]))
		Code_Module:SetEffect("Haste", this.Player, nil, 'Shattered_Momentum')
		Code_Module:SetEffect("Haste", Player, {-1, script.Parent:GetAttribute("Count")}, "Shattered_Momentum")
	end
end

function DownedSurvivor(State, Name)

	if (State ~= "Hit") then
		return
	end

	local plr = game.Players[Name]
	
	if plr.Backpack.Scripts.values.HealthState.Value == 0 then
		script.Parent:SetAttribute("Count", 0)
		Code_Module:SetEffect("Haste", this.Player, nil, 'Shattered_Momentum')
	end
end

return this
