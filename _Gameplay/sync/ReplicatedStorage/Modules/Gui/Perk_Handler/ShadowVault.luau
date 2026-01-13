local Perk_Progress = {}
local Shadow_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('ShadowVault'))

local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

function Perk_Progress:GetInfo(perkData) -- used to get percentage we are at or value
	local lastShadow = game.Players.LocalPlayer.Character:GetAttribute("Shadow_Vaulted")
	local EquippedShadow, ShadowTier = data_module:GetPerk("ShadowVault")
	local TimeLeft = 100
	
	if lastShadow then
		local TimeElapsed = workspace:GetServerTimeNow() - tonumber(lastShadow)
		
		TimeLeft = math.clamp(TimeElapsed, 0, Shadow_Module.Tiers[ShadowTier])/Shadow_Module.Tiers[ShadowTier] * 100
	end
	
	return TimeLeft, 1 -- return filled bar by default | make it stay over-ride when active
end

return Perk_Progress
