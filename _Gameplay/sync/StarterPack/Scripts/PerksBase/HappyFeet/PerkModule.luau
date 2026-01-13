local Code = require(game.ReplicatedStorage.Modules.Code)
local Events = require(game.ServerScriptService["Event System"].Events)

local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('HappyFeet'))

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

	local Values = this.Player.Backpack.Scripts.values
	Values.HealthState.Changed:Connect(OnHealthUpdate)
end

function OnHealthUpdate(NewValue)
	if NewValue == 1 then
		Code:SetEffect(
			"Haste",
			this.Player,
			{Perk_Module.Duration, Perk_Module.Speed_Boost},
			"HappyFeet"
		)

		Code:Exhaust(this.Player, Perk_Module.Tiers[this.Tier])
	end
end

return this