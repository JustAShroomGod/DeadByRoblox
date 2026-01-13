local Code = require(game.ReplicatedStorage.Modules.Code)
local Events = require(game.ServerScriptService["Event System"].Events)

local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild("Adrenaline"))

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
	
	Events.Gameplay.onExitPowered.Event:Connect(OnExitPowered)
	
end

function OnExitPowered()
	
	if (not script.Parent:GetAttribute("Available")) then
		return
	end
	
	local HasMither, MitherTier = Data_Module:GetPerk("NoMither", this.Player)
	local HasHope, HopeTier = Data_Module:GetPerk("Adrenaline", this.Player)
	local IsBroken = Code:GetEffect("Broken", this.Player)

	Code:Exhaust(this.Player, Perk_Module.Tiers[this.Tier])

	repeat task.wait()
	until (not Code:isCarried(this.Player) and not Code:IsHooked(this.Player))

	if (HasMither or (IsBroken and not IsBroken.Active)) then
		return
	end

	script.Parent:SetAttribute("Available", false)
	Code:SetHealthState(this.Player, Code:GetHealthState(this.Player) + 1)
	Code:SetCollision(this.Player, 'Survivor')
	Code:SetEffect("Haste", this.Player, {Perk_Module.Duration, Perk_Module.Speed_Boost}, "Hope")
	
end

return this
