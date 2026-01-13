local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules:WaitForChild("Code"))
local Data = require(ReplicatedStorage.Modules:WaitForChild("Data"))
local Auras = require(ReplicatedStorage.Modules:WaitForChild("Auras"))
local Perk = require(ReplicatedStorage.Game_Data.Perks.Survivor:WaitForChild("Serene"))

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
	local HasPerk, _Tier = Data:GetPerk("Serene")
	Tier = _Tier
	
	if (Scripts.Killer.Value or not HasPerk) then
		return
	end
	
	Scripts.PerksBase.Serene:GetAttributeChangedSignal("timestamp"):Connect(PerkUpdated)
end

function PerkUpdated()
	
	for i, obj in pairs(workspace:GetChildren()) do
		
		if (string.find(obj.Name, "Generator") == nil) then
			continue
		end
		
		if (obj.Panel.Popped.Value) then
			continue
		end
		
		Auras.AddAura("Default", Perk.Tiers[Tier], obj, false, `{obj.Name}_Serene`)
	end
	
end

module.Start()

return module
