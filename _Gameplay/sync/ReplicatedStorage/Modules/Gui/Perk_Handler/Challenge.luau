local Player : Player = game:GetService("Players").LocalPlayer
local PerksBase : Folder = Player:WaitForChild("Backpack"):WaitForChild("Scripts"):WaitForChild("PerksBase")

local Perk_Progress = {}

local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local perk_folder = PerksBase:WaitForChild("Challenge")

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local Time, Max = perk_folder:GetAttribute("Cooldown"), perk_folder:GetAttribute("MaxCooldown")
	local Percent = (100 / Max) * (Max - Time)
	Percent = math.clamp(Percent, 0, 100)
	local override = if (Percent >= 100) then 1 else 0
	
	return Percent, override
end

return Perk_Progress
