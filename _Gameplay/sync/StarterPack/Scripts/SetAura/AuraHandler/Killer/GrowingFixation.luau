local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules:WaitForChild("Code"))
local Data = require(ReplicatedStorage.Modules:WaitForChild("Data"))
local Auras = require(ReplicatedStorage.Modules:WaitForChild("Auras"))
local Perk = require(ReplicatedStorage.Game_Data.Perks.Killer:WaitForChild("GrowingFixation"))

local Remotes = ReplicatedStorage.RemoteEvents
local AuraEvent = Remotes.ServerToClient.AuraEvent

local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local AuraFolder = workspace.Auras

local Backpack = LocalPlayer.Backpack
local Scripts = Backpack.Scripts
local Values = Scripts.values

local Tier = 0

local module = {}

function module.Start()
	local HasPerk, _Tier = Data:GetPerk("GrowingFixation")
	Tier = _Tier
	
	if (not Scripts.Killer.Value or not HasPerk) then
		return
	end
	
	Scripts.PerksBase.GrowingFixation:GetAttributeChangedSignal("timestamp"):Connect(PerkUpdated)
end

function PerkUpdated()
	
	local playerName = Scripts.PerksBase.GrowingFixation:GetAttribute("player")
	local plr = Players[playerName]
	
	Auras.AddPlayerAura("Hostile", Perk.Aura_Duration, plr, `{plr.Name}_GrowingFixation`)
	
	local activeAuras = Auras.GetAll()
	
	for count = 1, #activeAuras do
		if (activeAuras[count].Timer == nil) then
			continue
		end
		
		activeAuras[count].Timer.Increase(Perk.Tiers[Tier])
	end
	
end

module.Start()

return module
