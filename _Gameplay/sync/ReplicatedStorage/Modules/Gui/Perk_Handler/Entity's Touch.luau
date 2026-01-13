local Player : Player = game:GetService("Players").LocalPlayer
local PerksBase : Folder = Player:WaitForChild("Backpack"):WaitForChild("Scripts"):WaitForChild("PerksBase")

local Perk_Progress = {}

local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local perk_folder = PerksBase:WaitForChild("Entity's Touch")

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local Time, Max, Active = perk_folder:GetAttribute("Timer"), perk_folder:GetAttribute("Max"), perk_folder:GetAttribute("Active")
	
	local Percent, override = 0, 0
	
	if Active then
		Percent = (100 / Max) * Time
		Percent = math.clamp(Percent, 0, 100)
		override = if (Percent > 0) then 1 else 0
	else
		Percent = (100 / Max) * Time
		Percent = math.clamp(Percent, 0, 100)
		override = if (Percent >= 100) then 1 else 0
	end
	
	return Percent, override
end

return Perk_Progress