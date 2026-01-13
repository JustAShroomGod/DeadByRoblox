local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Utils = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PerkUtils"))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild("Blessing: Fresh Air"))

local this = {}

this.Player = nil
this.initialized = false
this.Tier = 0
this.Totem = nil
this.Runner = nil

this.PlayerList = {}

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier

	for i, v in pairs(game.Teams.Survivor:GetPlayers()) do
		this.PlayerList[v.Name] = false
	end

	Events.Killer.onTotemCrushed.Event:Connect(OnTotemCrushed)
	Events.Survivor.onTotemBlessed.Event:Connect(OnTotemBlessed)
end

function GetDistanceToTotem(Player: Player)

	local PlayerPos: Vector3 = Player.Character:GetPivot().Position
	local TotemPos: Vector3 = this.Totem:GetPivot().Position

	return (PlayerPos - TotemPos).Magnitude
end


function Disconnect()
	if (this.Runner ~= nil) then
		this.Runner:Disconnect()
		this.Runner = nil
	end

	game.ReplicatedStorage["-LockerAuras"]['ServerDisconnect']:Fire(this.Totem)
end

function OnTotemBlessed(Survivor: Player, Totem)

	if (this.Totem ~= nil or Survivor.Name ~= this.Player.Name) then
		if Survivor.Name ~= this.Player.Name then
			return
		else
			Disconnect()
		end
	end

	this.Totem = Totem
	script.Parent:SetAttribute("Active", true)
end

function OnTotemCrushed(Killer: Player, Totem)

	if (this.Totem == nil) then
		return
	end

	if (this.Totem.Name ~= Totem.Name) then
		return
	end

	script.Parent:SetAttribute("Active", false)
	Disconnect()
end

return this