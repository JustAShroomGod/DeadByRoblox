local HttpService = game:GetService("HttpService")

local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage.Modules.Code)
local Perk_Module = require(game.ReplicatedStorage.Game_Data.Perks.Survivor.DecisiveStrike)

local SkillCheckRemote = game.ReplicatedStorage.RemoteEvents:WaitForChild("SendSkillCheck")
local Main = script.Parent

local ConspicuousActions = {"BreakingTotem", "CraftingShard", "OtherHealing", "SelfHealing", "OpeningGate", "Repairing", "MedkitHeal"}

local this = {}

this.Player = nil
this.initialized = false
this.Tier = 0
this.CurrentSkillCheckID = nil
this.KillerToStun = nil

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier
	
	Main:SetAttribute("Duration", Perk_Module.Tiers[Tier])
	
	Events.Server.Heartbeat.Event:Connect(OnUpdate)
	Events.Killer.onGrasp.Event:Connect(GraspBegin)
	Events.Survivor.onHookRescue.Event:Connect(SurvivorUnhooked)
	SkillCheckRemote.OnServerEvent:Connect(SkillCheckReceived)
end

function OnUpdate(delta)
	
	local Character = this.Player.Character
	local Timer = Main:GetAttribute("Timer")
	
	if (Character == nil)  then
		return
	end
	
	if (Timer <= 0 or not Main:GetAttribute("Available")) then
		return
	end
	
	if (table.find(ConspicuousActions, Code_Module:GetSurvivorAction(this.Player)) ~= nil) then
		Main:SetAttribute("Timer", 0)
		return
	end
	
	if (Code_Module:InChase(this.Player)) then
		Main:SetAttribute("Timer", math.clamp(Timer, 5, Perk_Module.Tiers[this.Tier]))
		return
	end
	
	Timer -= delta
end

function GraspBegin(Killer: Player, Survivor: Player)
	
	if (Survivor.Name ~= this.Player.Name) then
		return
	end
	
	if (Main:GetAttribute("Timer") <= 0 or not Main:GetAttribute("Available")) then
		return
	end
	
	local randomID = HttpService:GenerateGUID(false)

	local SkillCheckConfig = {
		Sizes = {0, 6}
	}
	
	Main:SetAttribute("Timer", 0)

	this.KillerToStun = Killer
	this.CurrentSkillCheckID = randomID
	SkillCheckRemote:FireClient(Survivor, randomID, SkillCheckConfig, "Nothing")
end

function SurvivorUnhooked(Rescuer: Player, Survivor: Player)
	
	print(Rescuer, "unhooked", Survivor)
	
	if (Survivor.Name ~= this.Player.Name or not Main:GetAttribute("Available")) then
		return
	end
	
	Main:SetAttribute("Timer", Perk_Module.Tiers[this.Tier])
end

function SkillCheckReceived(Player: Player, ID, Result)
	
	if (Player.Name ~= this.Player.Name or this.KillerToStun == nil) then
		return
	end
	
	if (ID ~= this.CurrentSkillCheckID) then
		return warn("Insufficient ID")
	end
	
	if (Result == "Miss") then
		Main:SetAttribute("Timer", 0)
		return
	end
	
	if (Result == "Fail") then
		Main:SetAttribute("Timer", 0)
		Main:SetAttribute("Available", false)
		return
	end

	if (Result == "Good") then
		Code_Module:Stun_Killer(this.KillerToStun, "Defense")
		Main:SetAttribute("Available", false)
		return
	end
end

return this
