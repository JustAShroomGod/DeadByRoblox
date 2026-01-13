local Player : Player, ReplicatedStorage : ReplicatedStorage = game:GetService("Players").LocalPlayer, game:GetService("ReplicatedStorage")
local Backpack : Backpack  = Player.Backpack
local Perk : Folder = Backpack:WaitForChild("Scripts"):WaitForChild("PerksBase"):WaitForChild("SpiritFury")
local Pallets : NumberValue = Perk:WaitForChild("Pallets")

local Game_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Perks')

local Data_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local SpiritFury_Module = require(Game_Data:WaitForChild("Killer"):WaitForChild("SpiritFury"))

local Perk_Progress = {}

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local Fill,stayOn = 0,2
	local EquippedSpiritFury, SpiritFuryTier = Data_Module:GetPerk("SpiritFury")


	local Fill = math.clamp(Pallets.Value / SpiritFury_Module.Tiers[SpiritFuryTier] * 100,0,100)

	if Pallets.Value >= SpiritFury_Module.Tiers[SpiritFuryTier] then
		stayOn = 1
	end
	
	return Fill, stayOn -- return filled bar by default
end

return Perk_Progress
