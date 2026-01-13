local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Perk_Utils = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PerkUtils"))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild(script.Parent.Name))

local CustomRemote = game.ReplicatedStorage.RemoteEvents.ClientToServer.CustomRemote

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
	
	CustomRemote.OnServerEvent:Connect(RemoteReceived)
end

function RemoteReceived(Player, ...)
	
	if (not Data_Module:GetPerk("ObjectOfObsession", Player)) then
		return
	end
	
	local args = {...}
	
	if (args[1] ~= "ObjectSet") then
		return
	end
	
	script.Parent:SetAttribute("Watching", args[2])
	
end

return this
