local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules.Code)
local Data = require(ReplicatedStorage.Modules.Data)
local Auras = require(ReplicatedStorage.Modules.Auras)

local Remotes = ReplicatedStorage.RemoteEvents
local AuraEvent = Remotes.ServerToClient.AuraEvent

local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local AuraFolder = workspace.Auras

local Backpack = LocalPlayer.Backpack
local Scripts = Backpack.Scripts
local Values = Scripts.values

local module = {}

function module.Start()
	
	if (Scripts.Killer.Value) then
		return
	end
	
	Values.HealthState.Changed:Connect(HealthStateUpdated)
	Values.Hooked.Changed:Connect(HealthStateUpdated)
end

function HealthStateUpdated()
	
	if (Values.HealthState.Value > 0 and not Values.Hooked.Value) then
		for i, plr in pairs(Teams.Survivor:GetPlayers()) do
			Auras.RemovePlayerAura(`{plr.Name}_DyingSelf`, "Ally")
		end
		
		return
	end
	
	for i, plr in pairs(Teams.Survivor:GetPlayers()) do

		if (plr.Name == LocalPlayer.Name) then
			continue
		end

		Auras.AddPlayerAura("Ally", -1, plr, `{plr.Name}_DyingSelf`)
	end
end

module.Start()

return module
