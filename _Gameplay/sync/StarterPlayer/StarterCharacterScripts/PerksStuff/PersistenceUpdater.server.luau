local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Data_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Perk_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Perseverance'))
local Code_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Character = script.Parent.Parent
local Player = game.Players:FindFirstChild(Character.Name)

local playerValues = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')

local hasPerk, PerkTier = Data_Module:GetPerk("Persistence", Player)

if not hasPerk then
	script.Disabled = true
	script:Remove()
else
	Code_Module:SetEffect("Quiet", Player, {-1, Perk_Module.Tiers[PerkTier]}, "Persistence")
end -- do nothing