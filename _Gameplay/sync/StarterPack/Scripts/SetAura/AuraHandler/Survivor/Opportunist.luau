local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules.Code)
local Data = require(ReplicatedStorage.Modules.Data)
local Auras = require(ReplicatedStorage.Modules.Auras)
local Perk = require(game.ReplicatedStorage.Game_Data.Perks.Survivor.Opportunist)

local Remotes = ReplicatedStorage.RemoteEvents
local AuraEvent = Remotes.ServerToClient.AuraEvent

local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local AuraFolder = workspace.Auras

local Backpack = LocalPlayer.Backpack
local Scripts = Backpack.Scripts
local Values = Scripts.values

local Tier = 0
local timestamp = workspace:GetServerTimeNow()

local Windows = {}
local Pallets = {}

local States = {}
local Connections = {}

local module = {}

function module.Start()
	
	local HasPerk, _Tier = Data:GetPerk("Opportunist")
	Tier = _Tier
	
	if (Scripts.Killer.Value or not HasPerk) then
		return
	end
	
	RunService.Heartbeat:Connect(Update)
end

function Update()
	
	if ((workspace:GetServerTimeNow() - timestamp) < 0.5) then
		return
	end
	
	timestamp = workspace:GetServerTimeNow()
	CacheObjects()
	
	for i, window in pairs(Windows) do
		
		local dist = GetDistanceXZ(window)
		
		if (dist > Perk.Tiers[Tier] or dist < 10) then
			Auras.RemoveAura(`{window.Name}_Opportunist`, "Objects", false)
			continue
		end
		
		Auras.AddAura("Objects", -1, window, false, `{window.Name}_Opportunist`)
	end
	
	for i, pallet in pairs(Pallets) do
		
		local dist = GetDistanceXZ(pallet)

		if (dist > Perk.Tiers[Tier] or dist < 10 or pallet.Panel.State.Value > 1) then
			Auras.RemoveAura(`{pallet.Name}_Opportunist`, "Objects", false)
			continue
		end

		Auras.AddAura("Objects", -1, pallet, false, `{pallet.Name}_Opportunist`)
	end
	
	
end

function RefreshAura(pallet)
	
	if (GetDistanceXZ(pallet) > Perk.Tiers[Tier] or pallet.Panel.State.Value > 1) then
		Auras.RemoveAura(`{pallet.Name}_Opportunist`, "Objects", false)
		return
	end

	Auras.RemoveAura(`{pallet.Name}_Opportunist`, "Objects", false)
	Auras.AddAura("Objects", -1, pallet, false, `{pallet.Name}_Opportunist`)
end

function CacheObjects()
	
	for i, obj in pairs(workspace:GetChildren()) do
		if (string.find(obj.Name, "Window")) then
			Windows[obj.Name] = obj
		end
		
		if (string.find(obj.Name, "Pallet")) then
			Pallets[obj.Name] = obj
			
			if (Connections[obj.Name] ~= nil) then
				continue
			end
			
			Connections[obj.Name] = obj.Destroying:Connect(function()
				
				if (Connections[obj.Name] ~= nil) then
					Connections[obj.Name]:Disconnect()
					Connections[obj.Name] = nil
				end
				
				coroutine.wrap(function()
					timestamp = workspace:GetServerTimeNow()
					task.wait(0.5)
					
					Pallets[obj.Name] = workspace[obj.Name]
					RefreshAura(workspace[obj.Name])
				end)()
			end)
			
			States[obj.Name] = obj.Panel.State.Changed:Connect(function()
				
				if (States[obj.Name] ~= nil) then
					States[obj.Name]:Disconnect()
					States[obj.Name] = nil
				end

				coroutine.wrap(function()
					task.wait(1)

					RefreshAura(obj)
				end)()
			end)
		end
	end
	
end

function GetDistanceXZ(Object: Model)

	if (Object == nil) then
		return 999
	end

	local PositionLocal = LocalCharacter.PrimaryPart.CFrame.Position
	PositionLocal = Vector3.new(PositionLocal.X, 0, PositionLocal.Z)

	local PositionTarget = Object.PrimaryPart.CFrame.Position
	PositionTarget = Vector3.new(PositionTarget.X, 0, PositionTarget.Z)

	return (PositionLocal - PositionTarget).Magnitude
end

module.Start()

return module
