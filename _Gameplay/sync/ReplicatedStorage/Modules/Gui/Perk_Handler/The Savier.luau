local Perk_Progress = {
	Percent = 0;
	Mode = 0; --[[
	0 = Default
	1 = Forced Light
	2 = Forced Dark
	]]--
}

local Game_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Perks')
local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local Perk_Module = require(Game_Data:WaitForChild('Survivor'):WaitForChild('The Savier'))

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local Savier_Attribute = game.Players.LocalPlayer.Character:GetAttribute("Savier_Tokens")
	
	if Savier_Attribute then
		Perk_Progress.Mode = 0
		Perk_Progress.Percent = (tonumber(Savier_Attribute)/Perk_Module.Token_Limit) * 100
	else
		Perk_Progress.Mode = 2
	end
	
	return Perk_Progress.Percent, Perk_Progress.Mode -- return filled bar by default | make it stay over-ride when active
end

return Perk_Progress
