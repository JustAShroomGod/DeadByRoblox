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

local Initialized = false
local IsBlind = false

function Setup()
	Auras.Setup()
	
	if (Scripts.Killer.Value) then
		for i, v in pairs(script.Killer:GetChildren()) do
			require(v)
		end
	else
		for i, v in pairs(script.Survivor:GetChildren()) do
			require(v)
		end
	end
	
end

ReplicatedStorage.Match.Started.Changed:Connect(Setup)