local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules.Code)
local Data = require(ReplicatedStorage.Modules.Data)
local Auras = require(ReplicatedStorage.Modules.Auras)
local Perk = require(game.ReplicatedStorage.Game_Data.Perks.Killer.Dissent)

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
		if (string.find(v.Name, "Generator")) then
			v:GetAttributeChangedSignal("Blocked"):Connect(function()
				BlockUpdate(v)
			end)
		end
	end
	
	task.wait(.5)
	
	for i, v in pairs(workspace:GetChildren()) do
		if (string.find(v.Name, "Generator")) then
			if (v:GetAttribute("Blocked")) then
				Auras.AddAura("Objects", -1, v, false, `{v.Name}_Blocked`)
			end
		end
	end
end

function BlockUpdate(Generator)
	
	task.wait(.5)

	if (Generator:GetAttribute("Blocked")) then
		Auras.AddAura("Objects", -1, Generator, false, `{Generator.Name}_Blocked`)
	else
		Auras.RemoveAura(`{Generator.Name}_Blocked`, "Objects", false)
		Auras.AddAura("Default", -1, Generator, false)
	end

end

module.Start()

return module
