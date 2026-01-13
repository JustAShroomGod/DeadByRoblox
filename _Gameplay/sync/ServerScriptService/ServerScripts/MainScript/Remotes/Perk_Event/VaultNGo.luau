local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Lithe'))
local module = {}

function module:Activate(player, ...)
    local args = {...}
    local hasPerk, perkTier = Data_Module:GetPerk("Lithe", player)
    
    if not hasPerk then return warn("Cheating") end
    if Code_Module:IsExhausted(player) then return warn("Currently Exhausted") end
    
    repeat task.wait() until player.Backpack.Scripts.values.Action.Value == "Nothing"
    Code_Module:Exhaust(player, Perk_Module.Tiers[perkTier])
    Code_Module:SetEffect("Haste", player, {Perk_Module.Duration, Perk_Module.Speed_Boost}, "VaultNGo")
end

return module