local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")

local Game_Data = ReplicatedStorage.Game_Data
local Remotes = ReplicatedStorage.RemoteEvents.ClientToServer

local HealingAction = require(script.HealingAction)
local Data = require(ReplicatedStorage.Modules.Data)
local Code = require(ReplicatedStorage.Modules.Code)
local BadgeManager = require(ServerStorage.Modules.BadgeManager)
local Events = require(game.ServerScriptService["Event System"].Events)

local Operations = {}

function Initialize()
	Remotes.HealingEvent.OnServerEvent:Connect(HealingReceived)
	ReplicatedStorage.Match.Started.Changed:Connect(MatchStarted)
end

function HealingReceived(Player, PlayerName, State, Config)
	
	if (Config and not Operations[PlayerName]:GetIsRunning()) then
		for attr, value in pairs(Config) do
			Operations[PlayerName]:Configure(attr, value)
		end
	end
	
	if (State == "Start") then
		StartOtherHealing(Player, game.Players[PlayerName], Config)
		StartSelfHealing(Player, game.Players[PlayerName], Config)
		StartSelfMending(Player, game.Players[PlayerName], Config)
	else
		Code.Speeds:removeMultiplier(Player, "Healing")
		Operations[PlayerName]:RemoveHealer(Player)
		Code:SetSurvivorAction(Player, "Nothing")
	end
end

function StartOtherHealing(Player, Target, Config)
	
	if (Player == Target or Config.SelfHealing) then
		return
	end
	
	Code.Speeds:addMultiplier(Player, "Healing", 0, 0)
	Code.Speeds:addMultiplier(Target, "Healing", 0, 0)
	Operations[Target.Name]:AddHealer(Player)
	BadgeManager.Award("Healer", Target.UserId)
	
	Code:SetSurvivorAction(Player, "OtherHealing")
	Code:SetSurvivorAction(Target, "GettingHealing")
	
	Player.Character:SetAttribute("CurrentInteractable", Target.Name)
	Player.Character:SetAttribute("CurrentInteractable", Player.Name)
end

function StartSelfHealing(Player, Target, Config)

	if (Player ~= Target or Config.IsMending or not Config.SelfHealing) then
		return
	end

	Code.Speeds:addMultiplier(Player, "Healing", 0, 0)
	Operations[Player.Name]:AddHealer(Player)

	Code:SetSurvivorAction(Player, "SelfHealing")
	
	Player.Character:SetAttribute("CurrentInteractable", Player.Name)
end

function StartSelfMending(Player, Target, Config)

	if (Player ~= Target or not Config.IsMending or not Config.SelfHealing) then
		return
	end

	Code.Speeds:addMultiplier(Player, "Healing", 0, 0)
	Operations[Player.Name]:AddHealer(Player)

	Code:SetSurvivorAction(Player, "Mending")
	
	Player.Character:SetAttribute("CurrentInteractable", Player.Name)
end

function MatchStarted()
	
	for i, plr in pairs(Teams.Survivor:GetPlayers()) do
		Operations[plr.Name] = HealingAction.New(plr)
	end
	
end

Initialize()