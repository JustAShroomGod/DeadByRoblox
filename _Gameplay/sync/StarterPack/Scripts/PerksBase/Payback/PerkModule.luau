local HTTPService = game:GetService("HttpService")

local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Utils = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PerkUtils"))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("Payback"))

local SendSkillCheck = game.ReplicatedStorage.RemoteEvents:WaitForChild("SendSkillCheck")
local SkillChecks = {}
local Multiplier = {}

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
	
	Events.Survivor.onKillerStun.Event:Connect(KillerStunned)
	SendSkillCheck.OnServerEvent:Connect(SkillCheckReceived)
end

function KillerStunned(Survivor: Player, Killer: Player)

	if (Killer.Name ~= this.Player.Name) then
		return
	end

	local SkillCheckConfig = {
		Sizes = {0, 6}
	}

	Multiplier[Survivor.Name] = 0

	coroutine.wrap(function()
		for count = 1, Perk_Module.SkillChecks do
			task.wait(0.5)
			local randomID = HTTPService:GenerateGUID(false)

			SkillChecks[randomID] = 1
			SendSkillCheck:FireClient(Survivor, randomID, SkillCheckConfig, "Nothing")
		end
	end)()
end

function SkillCheckReceived(Player: Player, ID, Result)

	if (SkillChecks[ID] == nil) then
		return-- warn(Player.Name, "tried sending an unknown SkillCheck ID")
	end

	SkillChecks[ID] = nil

	if (Result == "Fail" or Result == "Miss") then
		Multiplier[Player.Name] += 1
		Code_Module:SetEffect("Slow", Player, {Perk_Module.Duration, (Perk_Module.Tiers[this.Tier] * Multiplier[Player.Name])})
	end

end

return this
