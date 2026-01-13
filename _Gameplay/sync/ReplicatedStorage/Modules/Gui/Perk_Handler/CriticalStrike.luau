local Player : Player = game:GetService("Players").LocalPlayer
local PerksBase : Folder = Player:WaitForChild("Backpack"):WaitForChild("Scripts"):WaitForChild("PerksBase")

local Perk_Progress = {}

local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local perk_folder = PerksBase:WaitForChild("CriticalStrike")

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local Timer, MaxTimer = perk_folder:GetAttribute("Timer"), perk_folder:GetAttribute("MaxTimer")
	
	local Percent, override = 0, 0
	
	Percent = 100 / MaxTimer * Timer
	override = if (Percent > 0) then 1 else 0
	
	return Percent, override
end

return Perk_Progress
