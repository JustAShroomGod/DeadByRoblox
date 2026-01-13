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
	workspace.MatchValues.GeneratorsRepaired.Changed:Connect(GeneratorRepaired)
end

function GeneratorRepaired()
	
	local amount = workspace.MatchValues.GeneratorsRepaired.Value

	if (not Scripts.Killer.Value or amount < 5) then
		return
	end
	
	for i, v in pairs(workspace:GetChildren()) do
		if (string.find(v.Name, "ExitGate")) then
			Auras.AddAura("Objects", 0, v.Wall_Mount, false, v.Name)
		end
	end

end

module.Start()

return module
