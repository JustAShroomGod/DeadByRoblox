local Code = require(game.ReplicatedStorage.Modules.Code)
local Events = require(game.ServerScriptService["Event System"].Events)
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild("SpineChill"))

local RunService  = game:GetService("RunService")
local Active_Variable = script.Parent.Active
local MaxDistance ,Accuracy = Perk_Module.MaxDistance, .75

local this = {}

this.Player = nil
this.initialized = false
this.Runner = nil
this.Tier = 0

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier
	this.Runner = RunService.Heartbeat:Connect(OnUpdate)
end

function OnUpdate(delta)
	local Killer_Looking = false

	for _, Killer_Player in pairs(game.Teams:WaitForChild('Killer'):GetPlayers()) do
		local character = Killer_Player.Character
		local CHARACTER = this.Player.Character

		if character == CHARACTER then
			this.Runner:Disconnect()
			this.Runner = nil
		end

		if character and CHARACTER and character.PrimaryPart and CHARACTER.PrimaryPart then
			local KHRP, SHRP = character.PrimaryPart, CHARACTER.PrimaryPart
			local Distance = (KHRP.Position - SHRP.Position).magnitude
			local Direction = (SHRP.CFrame.Position - KHRP.CFrame.Position).Unit
			local DotProduct = KHRP.CFrame.LookVector:Dot(Direction)

			if DotProduct >= Accuracy and Distance <= MaxDistance then
				Killer_Looking = true
			end
		end
	end
	
	local ActionSpeed = Code.BaseValues.Survivor.Action.ActionSpeed
	local RepairSpeed = Code.BaseValues.Survivor.Action.RepairSpeed
	local VaultSpeed = Code.BaseValues.Survivor.Movement.WindowVaultSpeed
	local HealSpeed = Code.BaseValues.Survivor.Action.HealingSpeed
	local CleanseSpeed = Code.BaseValues.Survivor.Action.CleanseSpeed
	local OpeningSpeed = Code.BaseValues.Survivor.Action.OpeningSpeed
	
	if (Killer_Looking) then
		_G.GetValue(this.Player.Name, "ActionSpeed"):Add("SpineChill", (ActionSpeed / 100 * Perk_Module.Tiers[this.Tier]), nil)
		_G.GetValue(this.Player.Name, "RepairSpeed"):Add("SpineChill", (RepairSpeed / 100) * Perk_Module.Tiers[this.Tier], -1)
		_G.GetValue(this.Player.Name, "HealingSpeed"):Add("SpineChill", (HealSpeed / 100) * Perk_Module.Tiers[this.Tier], -1)
		_G.GetValue(this.Player.Name, "WindowVaultSpeed"):Add("SpineChill", -((VaultSpeed / 100) * Perk_Module.Tiers[this.Tier]), -1)
		_G.GetValue(this.Player.Name, "CleanseSpeed"):Add("SpineChill", (CleanseSpeed / 100) * Perk_Module.Tiers[this.Tier], -1)
		_G.GetValue(this.Player.Name, "OpeningSpeed"):Add("SpineChill", (OpeningSpeed / 100) * Perk_Module.Tiers[this.Tier], -1)
	else
		_G.GetValue(this.Player.Name, "ActionSpeed"):Remove("SpineChill")
		_G.GetValue(this.Player.Name, "RepairSpeed"):Remove("SpineChill")
		_G.GetValue(this.Player.Name, "HealingSpeed"):Remove("SpineChill")
		_G.GetValue(this.Player.Name, "WindowVaultSpeed"):Remove("SpineChill")
		_G.GetValue(this.Player.Name, "CleanseSpeed"):Remove("SpineChill")
		_G.GetValue(this.Player.Name, "OpeningSpeed"):Remove("SpineChill")
	end

	Active_Variable.Value = Killer_Looking
end

return this
