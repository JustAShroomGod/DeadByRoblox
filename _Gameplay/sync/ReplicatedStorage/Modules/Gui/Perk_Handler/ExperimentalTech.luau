local Player : Player = game:GetService("Players").LocalPlayer
local PerksBase : Folder = Player:WaitForChild("Backpack"):WaitForChild("Scripts"):WaitForChild("PerksBase")

local Perk_Progress = {}

local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local perk_folder = PerksBase:WaitForChild("ExperimentalTech")

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local Cooldown, MaxCooldown = perk_folder:GetAttribute("Cooldown"), perk_folder:GetAttribute("MaxCooldown")
	local Duration, MaxDuration = perk_folder:GetAttribute("Duration"), perk_folder:GetAttribute("MaxDuration")
	local IsOffCooldown = Cooldown >= MaxCooldown
	
	local Percent, override = 0, 0
	
	if (IsOffCooldown) then
		Percent = (100 / MaxDuration) * Duration
		Percent = math.clamp(Percent, 0, 100)
		override = if (Percent > 0) then 1 else 0
	else
		Percent = (100 / MaxCooldown) * Cooldown
		Percent = math.clamp(Percent, 0, 100)
		override = if (Percent >= 100) then 1 else 0
	end
	
	return Percent, override
end

return Perk_Progress
