local Players : Players, ReplicatedStorage = game:GetService("Players"), game:GetService("ReplicatedStorage")

repeat task.wait()
until Players.LocalPlayer.Character

local Player = Players.LocalPlayer
local Backpack = Player.Backpack
local Scripts = Backpack:WaitForChild("Scripts")
local values = Scripts:WaitForChild("values")

local Perk_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Fugitive'))
local Data = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'));

local Connection = nil

Connection = values.Hooked.Changed :Connect(function()
	local HasFugitive,Fugitive_Tier = Data:GetPerk("Fugitive", Player)
	
	if not HasFugitive then
		Connection:Disconnect()
		Connection = false
	end
	
	if HasFugitive and not (values.Hooked.Value) then
		script.Parent.Value = true
		
		task.wait(Perk_Module.Aura_Tiers[Fugitive_Tier])
		
		script.Parent.Value = false
	end
end)