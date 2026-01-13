local Game_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Perks')
local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local Perk_Progress = {
	Percent = 100;
	Mode = 0; --[[
	0 = Default
	1 = Forced Light
	2 = Forced Dark
	]]--
}

function Perk_Progress:GetInfo(perkData, playerData) -- used to get percentage we are at or value

	return Perk_Progress.Percent, Perk_Progress.Mode -- return filled bar by default | make it stay over-ride when active
end

return Perk_Progress
