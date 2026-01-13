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

	if (not Scripts.Killer.Value) then
		return
	end

	for i, v in pairs(workspace:GetChildren()) do
		if (string.find(v.Name, "Totem") == nil) then
			continue
		end

		v.Panel.Effect.Changed:Connect(EffectChanged)
		v.Panel.State.Changed:Connect(StateChanged)
	end

	RefreshAuras()
end

function EffectChanged ()
	RefreshAuras()
end

function StateChanged()
	RefreshAuras()
end

function RefreshAuras()
	for i, v in pairs(workspace:GetChildren()) do
		if (string.find(v.Name, "Totem") == nil) then
			continue
		end

		if (v.Panel.Effect.Value == "Blessing" and v.Panel.State.Value == 0) then
			Auras.AddAura("Totems", -1, v, false, `{v.Name}_Blessing`)
		else
			Auras.RemoveAura(v.Name, "Totems")
		end
	end
end

module.Start()

return module
