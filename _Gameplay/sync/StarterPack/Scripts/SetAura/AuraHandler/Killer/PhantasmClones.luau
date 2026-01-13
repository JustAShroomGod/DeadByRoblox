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
	
	if (not Scripts.Killer.Value or Data:GetCharacter() ~= "Phantasm") then
		return
	end
	
	local PhantasmModel: Model = workspace:WaitForChild("PhantomModel")
	PhantasmModel.ChildAdded:Connect(Added)
	PhantasmModel.ChildRemoved:Connect(Removed)
end

function Added(phantom)
	
	repeat task.wait(0.25)
	until phantom:GetAttribute("Deployed")
	
	local auraObj = Auras.AddAura("Objects", -1, phantom, false, `{phantom.Name}_CL`)
	auraObj.PrimaryPart.PhantasmParticles:Destroy()
end

function Removed(phantom)
	task.wait(0.5)
	Auras.RemoveAura(`{phantom.Name}_CL`, "Objects")
end

module.Start()

return module
