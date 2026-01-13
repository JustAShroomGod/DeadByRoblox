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
	
	for i, plr: Player in pairs(Teams.Survivor:GetPlayers()) do
		local backpack = plr.Backpack
		local scripts = backpack.Scripts
		local perksBase = scripts.PerksBase
		local perkFolder: Folder = perksBase.ObjectOfObsession
		
		perkFolder:GetAttributeChangedSignal("Watching"):Connect(function()
			WatchUpdate(plr, perkFolder)
		end)
	end
end

function WatchUpdate(Survivor, PerkFolder)
	
	if (PerkFolder:GetAttribute("Watching") == LocalPlayer.Name) then
		Auras.AddPlayerAura("Hostile", -1, Survivor, `{Survivor.Name}_Object`)
	else
		Auras.RemovePlayerAura(`{Survivor.Name}_Object`, "Hostile")
	end
	
end

module.Start()

return module
