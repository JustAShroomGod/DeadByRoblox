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
			v:GetAttributeChangedSignal("Sabotaged"):Connect(function()
				SabotageUpdate(v)
			end)
			v.Panel.Popped.Changed:Connect(function()
				SabotageUpdate(v)
			end)
		end
	end
end

function SabotageUpdate(Generator)

	if (Generator:GetAttribute("Sabotaged") and not Generator.Panel.Popped.Value) then
		Auras.AddAura("Objects", -1, Generator, false, `{Generator.Name}_Sabotaged`)
	else
		Auras.RemoveAura(`{Generator.Name}_Sabotaged`, "Objects", true)
	end

end

module.Start()

return module
