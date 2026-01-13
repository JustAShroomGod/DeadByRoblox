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
	
	if (not Scripts.Killer.Value or Data:GetCharacter(LocalPlayer) ~= "Trapper") then
		return
	end
	
	for i, v in pairs(workspace:GetChildren()) do
		if (string.find(v.Name, "Trap_") == nil) then
			continue
		end

		v.Panel.State.Changed:Connect(function()
			StateChanged(v)
		end)
		
		v:GetPropertyChangedSignal("Parent"):Connect(function(parentName)
			
			if (parentName ~= nil) then
				return
			end
			
			Auras.RemoveAura(v.Name, "Objects")
		end)
		
		v.Destroying:Once(function()
			Auras.RemoveAura(v.Name, "Objects")
		end)
		
		RefreshAura(v, false)
	end
	
	workspace.ChildAdded:Connect(function(child: Instance)
		if (string.find(child.Name, "Trap_") == nil) then
			return
		end
		
		Auras.AddAura("Objects", -1, child, false, child.Name)
		
		child.Panel.State.Changed:Connect(function()
			StateChanged(child)
		end)
		
		child:GetPropertyChangedSignal("Parent"):Connect(function(parentName)
			
			if (parentName ~= nil) then
				return
			end

			Auras.RemoveAura(child.Name, "Objects")
		end)
		
		child.Destroying:Once(function()
			Auras.RemoveAura(child.Name, "Objects")
		end)
	end)
	
end

function StateChanged(Trap)
	RefreshAura(Trap, true)
end

function RefreshAura(Trap, bool)
	
	if (Trap == nil) then
		return print(Trap)
	end
	
	if (bool) then
		task.wait(.5)
	end
	
	Auras.RemoveAura(Trap.Name, "Objects")
	Auras.AddAura("Objects", -1, Trap, false, Trap.Name)
end

module.Start()

return module
