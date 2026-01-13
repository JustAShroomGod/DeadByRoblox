local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Utils = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PerkUtils"))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("Curse: Lockdown"))

local this = {}

this.Player = nil
this.initialized = false
this.Tier = 0
this.Totem = nil
this.Runner = nil
this.PreviousInjured = -1

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
		script.Event:Fire("Reactivated_Totem")
		Events.Gameplay.onTotemTransfer.Event:Connect(OnTotemTransfer)
		Events.Survivor.onTotemBreak.Event:Connect(OnTotemBreak)
		this.Runner = Events.Killer.onHook.Event:Connect(OnUpdate)
	end
end

function OnTotemBreak(Survivor: Player, Type, Totem)
	if (Type == "Curse") then
		if (Totem.Name ~= this.Totem.Name) then
			return
		end
		script.Event:Fire("Cleansed_Totem")

		script.Parent:SetAttribute("Active", false)
		Disconnect()
	end
end

function OnTotemTransfer(Totem, NewTotem)
	if (Totem.Name == this.Totem.Name) then
		this.Totem = NewTotem
		script.Event:Fire("Reactivated_Totem")
		script.Parent:SetAttribute("Active", true)
	end
end

function OnUpdate(delta)
	script.Event:Fire("Hooked_Player", this.Player)
end

function Disconnect()
	if (this.Runner) then
		this.Runner:Disconnect()
		this.Runner = nil
	end
end

return this