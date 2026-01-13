local Players = game:GetService("Players")
local Runservice = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Modules.Data)
local Code = require(ReplicatedStorage.Modules.Code)
local BaseValues = require(game.ReplicatedStorage.Modules.BaseValues)
local Events = require(game.ServerScriptService["Event System"].Events)

local SendSkillCheck = ReplicatedStorage.RemoteEvents:WaitForChild("SendSkillCheck")

local ReadOnly = {"HealingTarget", "IsRunning", "Healers", "StateValue", "ProgressValue"}

local HealingAction = {}
HealingAction.__index = HealingAction

function HealingAction.New(Player: Player)
	local self = setmetatable({}, HealingAction)
	
	self.HealingTarget = Player
	self.Action = Player.Backpack.Scripts.values.Action
	self.State = Player.Backpack.Scripts.values.HealthState
	self.Progress = Player.Backpack.Scripts.values.HealProgress
	self.MendProgress = Player.Backpack.Scripts.values.MendProgress
	
	self.SkillChecks = {}
	self.Stuttering = workspace:GetServerTimeNow()
	self.LastSkillCheck = workspace:GetServerTimeNow()
	
	self.RestrictValues = false
	self.HealingSelf = false
	self.IsMending = false
	self.IsRunning = false
	self.SumKeys = {}
	self.ModKeys = {}
	self.Healers = {}
	
	SendSkillCheck.OnServerEvent:Connect(function(Player: Player, ID, Result)
		self:ProcessSkillCheck(Player, ID, Result)
	end)
	
	Runservice.Heartbeat:Connect(function(delta)
		self:Update(delta)
	end)
	
	return self
end

function HealingAction:AddHealer(Player: Player)
	
	if (self.HealingSelf and Player ~= self.HealingTarget) then
		return
	end
	
	self.Healers[Player.Name] = 0
end

function HealingAction:RemoveHealer(Player: Player)
	self.Healers[Player.Name] = nil
	
	if (_G.Utils.GetTableSize(self.Healers) <= 0) then
		Code.Speeds:removeMultiplier(self.HealingTarget, "Healing")
		self.HealingTarget.Character:SetAttribute("CurrentInteractable", "")
	end
end

function HealingAction:Configure(Attribute: string, value: "any")
	
	if (table.find(ReadOnly, Attribute) ~= nil) then
		return warn("Attempted to modify read-only Attribute (Likely Exploit)")
	end
	
	self[Attribute] = value
end

function HealingAction:Update(delta)
	
	self.IsRunning = (_G.Utils.GetTableSize(self.Healers) > 0)
	
	if (not self.IsRunning and self.Action.Value == "GettingHealing") then
		self.Action.Value = "Nothing"
		return
	end
	
	if (not self.IsRunning or (workspace:GetServerTimeNow() - self.Stuttering) < 4) then
		return
	end
	
	local healAmount = self:FetchHealingSpeed() * delta
	local mendSpeed = 83 * delta
	
	if (healAmount == 0 and self.Action.Value == "GettingHealing") then
		self.Action.Value = "Nothing"
		return
	end
	
	self:SpawnSkillCheck()
	
	if (self.IsMending) then
		self.MendProgress.Value += mendSpeed
	else
		self.Progress.Value += healAmount
	end
	
	if (self.MendProgress.Value >= 1000) then
		self.HealingTarget.Character:SetAttribute("Gash", nil)
		self.MendProgress.Value = 0
	end
	
	if (self.Progress.Value >= 1000) then
		self.Progress.Value = 0
		self.State.Value += 1
		Events.Survivor.onHealingFinished:Fire(self.HealingTarget, self.Healers)
	end
	
end

function HealingAction:SpawnSkillCheck()

	if (_G.Utils.GetTableSize(self.Healers) < 1 
		or not self:GetIsRunning() 
		or self.IsMending 
		or (workspace:GetServerTimeNow() - self.LastSkillCheck) < 3
		or self.Progress.Value >= 850) then
		return
	end

	self.LastSkillCheck = workspace:GetServerTimeNow()

	for player, value in pairs(self.Healers) do

		if (math.random(1, 100) > BaseValues.Gameplay.SkillCheckChances.Healing) then
			continue
		end

		local randomID = HttpService:GenerateGUID(false)

		local SkillCheckConfig = {
			Sizes = {4, 12}
		}

		self.SkillChecks[randomID] = 1
		SendSkillCheck:FireClient(Players[player], randomID, SkillCheckConfig, "Heal")
	end

end

function HealingAction:ProcessSkillCheck(Player: Player, ID, Result)

	if (self.SkillChecks[ID] == nil) then
		return-- warn(Player.Name, "tried sending an unknown SkillCheck ID")
	end

	self.SkillChecks[ID] = nil

	if (Result == "Fail" or Result == "Miss") then
		self.Progress.Value = math.clamp(self.Progress.Value - 50, 0, 1000)
		self.Stuttering = workspace:GetServerTimeNow()
		
		for i, plr in pairs(game.Teams.Killer:GetPlayers()) do
			Code:AddNotification(Player.PrimaryPart.CFrame, 5, "Default", plr) -->> notify killers
		end
	end
	
	if (Result == "Good") then
		Data:GiveBlood(Player, 50, "Altruism", "GOOD SKILL CHECK")
	end

	if (Result == "Great") then
		self.Progress.Value += 30
		Data:GiveBlood(Player, 300, "Altruism", "GREAT SKILL CHECK")
	end

end

function HealingAction:FetchHealingSpeed()
	
	local totalHeal = 0
	
	for player, value in pairs(self.Healers) do
		local healingAmount = if (self.RestrictValues) then _G.GetValue(player, "HealingSpeed"):Summarize(self.SumKeys) else _G.GetValue(player, "HealingSpeed"):Summarize(nil)

		totalHeal += healingAmount
	end
	
	return totalHeal
end

function HealingAction:GetIsRunning()
	return self.IsRunning
end

return HealingAction
