local Player : Player = game:GetService("Players").LocalPlayer
local PerksBase : Folder = Player:WaitForChild("Backpack"):WaitForChild("Scripts"):WaitForChild("PerksBase")

local Perk_Progress = {}

local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local perk_module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Pop Goes The Weasel'))

local perk_folder = PerksBase:WaitForChild("Pop Goes The Weasel")

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local Time, Max = perk_folder:GetAttribute("Timer"), perk_folder:GetAttribute("MaxCooldown")
	local Percent = (Time/Max) * 100 --(100 / Max) * Time
	Percent = math.clamp(Percent, 0, 100)
	local override = if (Percent > 0) then 1 else 0
	
	return Percent, override
end

return Perk_Progress
