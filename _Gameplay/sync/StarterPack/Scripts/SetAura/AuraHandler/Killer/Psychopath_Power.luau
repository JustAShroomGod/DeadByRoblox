local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules.Code)
local Data = require(ReplicatedStorage.Modules.Data)
local Auras = require(ReplicatedStorage.Modules.Auras)
local Killer_Data = require(game.ReplicatedStorage.Game_Data.Killers.Psychopath)

local Remotes = ReplicatedStorage.RemoteEvents
local AuraEvent = Remotes.ServerToClient.AuraEvent

local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local AuraFolder = workspace.Auras

local Backpack = LocalPlayer.Backpack
local Scripts = Backpack.Scripts
local Values = Scripts.values

local timestamp = workspace:GetServerTimeNow()

local module = {}

function module.Start()
	if (not Scripts.Killer.Value or Data:GetCharacter(LocalPlayer) ~= "Psychopath") then
		return
	end
	
	LocalCharacter:GetAttributeChangedSignal("Power_State"):Connect(function()
		local PowerState = LocalCharacter:GetAttribute("Power_State")
		
		if PowerState == "Using" then
			Update(true)
			task.delay(3, function()
				Update(false)
			end)
		else
			Update(false)
		end
	end)

--	RunService.Heartbeat:Connect(Update)
end

function Update(ShouldShow : boolean)
	
	if ((workspace:GetServerTimeNow() - timestamp) < 0.5) then
		return
	end
	
	timestamp = workspace:GetServerTimeNow()
	
	for i, plr: Player in pairs(Teams.Survivor:GetPlayers()) do
		
		if (plr.Name == LocalPlayer.Name) then
			continue
		end
		
		if ShouldShow then
			if (GetDistanceXZ(plr.Character) > Killer_Data.Aura_Distances.Min and 
				GetDistanceXZ(plr.Character) < Killer_Data.Aura_Distances.Max
				and (LocalPlayer.Character:GetAttribute("Power_State") == "Using")) then
				Auras.AddPlayerAura("Hostile", -1, plr, `{plr.Name}_BloodRage`)
			end
		else
			Auras.RemovePlayerAura(`{plr.Name}_BloodRage`, "Hostile")
		end
	end
end

function GetDistanceXZ(Character: Model)

	if (Character == nil) then
		return 999
	end

	local PositionLocal = LocalCharacter.PrimaryPart.CFrame.Position
	PositionLocal = Vector3.new(PositionLocal.X, 0, PositionLocal.Z)

	local PositionTarget = Character.PrimaryPart.CFrame.Position
	PositionTarget = Vector3.new(PositionTarget.X, 0, PositionTarget.Z)

	return (PositionLocal - PositionTarget).Magnitude
end

module.Start()

return module
