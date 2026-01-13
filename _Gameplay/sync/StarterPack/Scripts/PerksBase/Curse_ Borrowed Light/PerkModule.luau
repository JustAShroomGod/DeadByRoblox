local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Utils = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PerkUtils"))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("Curse: Borrowed Light"))

local this = {}

this.Player = nil
this.initialized = false
this.Tier = 0
this.Totem = nil
this.Runner = nil

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier
	
	local totem, success = Perk_Utils.SetHex(this.Player)

	if (success) then
		this.Totem = totem
		script.Parent:SetAttribute("Active", true)

		Events.Gameplay.onTotemTransfer.Event:Connect(OnTotemTransfer)
		Events.Survivor.onTotemBreak.Event:Connect(OnTotemBreak)
		this.Runner = Events.Server.Heartbeat.Event:Connect(OnUpdate)
	end
end

function OnTotemBreak(Survivor: Player, Type, Totem)
	if (Type == "Curse") then
		if (Totem.Name ~= this.Totem.Name) then
			return
		end
		
		script.Parent:SetAttribute("Active", false)
		Disconnect()
		Code_Module:SetEffect("Hidden", this.Player, nil, "Borrowed")
	end
end

function OnTotemTransfer(Totem, NewTotem)
	if (Totem.Name == this.Totem.Name) then
		this.Totem = NewTotem
		script.Parent:SetAttribute("Active", true)
	end
end

function GetClosestCurseDist()
	
	local dist = 10000
	
	for i, v: Model in pairs(workspace:GetChildren()) do
		if (string.find(v.Name, "Totem")) then
			local Totem_Effect = v.Panel.Effect
			
			if (Totem_Effect.Value == "Dull") then
				continue
			end
			
			local PlayerPos: Vector3 = this.Player.Character:GetPivot().Position
			local TotemPos: Vector3 = v:GetPivot().Position
			local calc = (PlayerPos - TotemPos).Magnitude
			
			if (calc < dist) then
				dist = calc
			end
		end
	end
	
	return dist
end

function OnUpdate(delta)
	
	local Dist = GetClosestCurseDist()
	
	if (Dist < Perk_Module.Tiers[this.Tier]) then
		Code_Module:SetEffect("Hidden", this.Player, -1, "Borrowed")
	else
		Code_Module:SetEffect("Hidden", this.Player, nil, "Borrowed")
	end
	
end

function Disconnect()
	if (this.Runner) then
		this.Runner:Disconnect()
		this.Runner = nil
	end
end

return this
