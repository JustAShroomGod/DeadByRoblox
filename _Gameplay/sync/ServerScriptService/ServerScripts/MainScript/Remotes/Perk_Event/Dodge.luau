local ReplicatedStorage : ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Code_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('DeadHard'))

local Animation = ReplicatedStorage:WaitForChild("Game_Assets"):WaitForChild("Animations"):WaitForChild("Perks"):WaitForChild("Survivor"):WaitForChild("Dodge"):WaitForChild("Dash")

local module = {}

local Animation_Track = script:WaitForChild('Animation')
local Back_Up_Length = 5 -- lenght of dead hard animation

function module:Activate(player, ...)
	local args = {...}
	local hasPerk, perkTier = Data_Module:GetPerk("DeadHard", player)

	if not hasPerk then return warn("Cheating") end
	if Code_Module:IsExhausted(player) then return warn("Currently Exhausted") end

	local Character = player.Character
	local Player_Pack = player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('PerksBase')
	local Player_Values = player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')

	Code_Module:SetEffect("IFrame", player, Perk_Module.IFrame_Duration) -- last for duration
	Code_Module:Exhaust(player, Perk_Module.Tiers[perkTier])

	Player_Values:WaitForChild('Action').Value = "DeadHard"

	local Length = Perk_Module.IFrame_Duration

	if Length <= 0.1 then
		Length = Back_Up_Length
	end

	task.wait(Length)

	Player_Values:WaitForChild('Action').Value = "Nothing"
end

return module
