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
	
	for i, plr in pairs(Teams.Survivor:GetPlayers()) do
		
		if (plr.Name == LocalPlayer.Name) then
			continue
		end
		
		local _backpack = plr.Backpack
		local _scripts = _backpack.Scripts
		local _values = _scripts.values
		
		_values.HealthState.Changed:Connect(function()
			HealthStateUpdated(plr, _values.HealthState, _values.Hooked)
		end)
		
		_values.Hooked.Changed:Connect(function()
			HealthStateUpdated(plr, _values.HealthState, _values.Hooked)
		end)
	end
	
end

function HealthStateUpdated(player, healthState, hooked)
	
	if (healthState.Value > 0 and not hooked.Value) then
		Auras.RemovePlayerAura(`{player.Name}_Dying`, "Ally")
	else
		Auras.AddPlayerAura("Ally", -1, player, `{player.Name}_Dying`)
	end
end

module.Start()

return module
