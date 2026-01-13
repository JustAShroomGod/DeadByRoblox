local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Utils = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PerkUtils"))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("Hex: Ruin"))

local this = {}

this.Player = nil
this.initialized = false
this.Tier = 0
this.Totem = nil

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier

	Events.Gameplay.onExitPowered.Event:Connect(OnExitPowered)
end

function OnTotemBreak(Survivor: Player, Type, Totem)
	if (Type == "Curse") then
		if (Totem.Name ~= this.Totem.Name) then
			return
		end

		script.Parent:SetAttribute("Active", false)
		Code_Module:SetEffect("Haste", this.Player, nil, "Noed")
		for i, v in pairs(game.Teams.Survivor:GetPlayers()) do
			Code_Module:SetEffect("Exposed", v, nil, "Noed")
		end
	end
end

function OnTotemTransfer(Totem, NewTotem)
	if (Totem.Name == this.Totem.Name) then
		this.Totem = NewTotem
		script.Parent:SetAttribute("Active", true)
	end
end

function OnExitPowered()
	local totem, success = Perk_Utils.SetHex(this.Player)

	if (success) then
		this.Totem = totem
		script.Parent:SetAttribute("Active", true)

		Events.Gameplay.onTotemTransfer.Event:Connect(OnTotemTransfer)
		Events.Survivor.onTotemBreak.Event:Connect(OnTotemBreak)
		Events.Killer.onAttack.Event:Connect(OnAttack)
	end
end

function OnAttack(State, ObjectName)

	if (State ~= "Hit" or game.Players:FindFirstChild(ObjectName) == nil or not Perk_Utils.IsHexStanding(this.Totem)) then
		return
	end

	local Survivor = game.Players:FindFirstChild(ObjectName)
	Code_Module:SetHealthState(Survivor, 0)

	coroutine.resume(coroutine.create(function()
		repeat task.wait() until this.Player.Backpack.Scripts.values.KillerAction.Value == "Nothing"
		if Perk_Utils.IsHexStanding(this.Totem) then
			Code_Module:SetEffect("Haste", this.Player, {-1, Perk_Module.Tiers[this.Tier]}, "Noed")
		end
	end))
	for i, v in pairs(game.Teams.Survivor:GetPlayers()) do
		Code_Module:SetEffect("Exposed", v, -1, "Noed")
	end

end

return this