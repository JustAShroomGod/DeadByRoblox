local AddonValues = game:GetService("ReplicatedStorage"):WaitForChild("Game_Data"):WaitForChild("Addons"):WaitForChild("Killer")

local Addons = {
	WindStormMud = {
		Type = "MOVESPEED_CLOAK"; -- move speed upgrade for cloaked
		Value = require(AddonValues:WaitForChild("WindStormMud")).Cloak_Boost; 
	},
	WindStormWhite = {
		Type = "MOVESPEED_CLOAK"; -- move speed upgrade for cloaked
		Value = require(AddonValues:WaitForChild("WindStormWhite")).Cloak_Boost; 
	},
	WindStormBlood = {
		Type = "MOVESPEED_CLOAK"; -- move speed upgrade for cloaked
		Value = require(AddonValues:WaitForChild("WindStormBlood")).Cloak_Boost; 
	},
	['True Ghost'] = {
		Type = "MOVESPEED_CLOAK"; -- move speed upgrade for cloaked
		Value = require(AddonValues:WaitForChild("True Ghost")).Cloak_Boost; 
	},
	Serpent = {
		Type = "ANIMATIONSPEED_UNCLOAK"; -- custom for breaking stuff / will need to code manually | uncloak during breaking/kicking
		Value = require(AddonValues:WaitForChild("Serpent")).Uncloak_Boost
	},
}

return Addons