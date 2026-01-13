local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules:WaitForChild("Code"))
local Data = require(ReplicatedStorage.Modules:WaitForChild("Data"))
local Auras = require(ReplicatedStorage.Modules:WaitForChild("Auras"))
local Perk = require(ReplicatedStorage.Game_Data.Perks.Killer:WaitForChild("Retaliation"))

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
	local HasPerk, _Tier = Data:GetPerk("Thrill of the Hunt")
	Tier = _Tier
	
	if (not Scripts.Killer.Value or not HasPerk) then
		return
	end
	
	Scripts.PerksBase["Thrill of the Hunt"]:GetAttributeChangedSignal("timestamp"):Connect(PerkUpdated)
end

function PerkUpdated()
	
	local plr = game.Players[Scripts.PerksBase["Thrill of the Hunt"]:GetAttribute("Player")]
	Auras.AddPlayerAura("Hostile", Perk.Tiers[Tier], plr, `{plr.Name}_Thrill`)
	
end

module.Start()

return module
