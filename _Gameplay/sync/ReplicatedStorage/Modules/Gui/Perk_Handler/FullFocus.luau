local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('GrowingFixation'))
local Perk_Progress = {}
local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild("Data"))

function Perk_Progress:GetInfo(perkData, playerData) -- used to get percentage we are at or value
	local PerksBase = game.Players.LocalPlayer.Backpack.Scripts.PerksBase
	local has, Tier = Data_Module:GetPerk("FullFocus")
	local Perk = PerksBase.FullFocus
	
	local active = (workspace:GetServerTimeNow() - Perk:GetAttribute("timestamp") <= Perk_Module.Aura_Duration)
	script:SetAttribute("Stacks", Perk:GetAttribute("token"))
	
	return (if (active) then 100 else 0), 1
end

return Perk_Progress