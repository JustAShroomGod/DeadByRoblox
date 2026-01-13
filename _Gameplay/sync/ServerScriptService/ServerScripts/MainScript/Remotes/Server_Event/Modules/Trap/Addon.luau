local AddonValues = game:GetService("ReplicatedStorage"):WaitForChild("Game_Data"):WaitForChild("Addons"):WaitForChild("Killer")

local Addons = {
	TrappingGauntlets = {
		Effects = {
			Positive = {
				Type = "SPEED_ANIMATION"; -- move speed upgrade for cloaked
				Value = require(AddonValues:WaitForChild("TrappingGauntlets")).Trap_Boost;
			}
		}
	},
	FasteningTools = {
		Effects = {
			Positive = {
				Type = "SPEED_ANIMATION"; -- move speed upgrade for cloaked
				Value = require(AddonValues:WaitForChild("FasteningTools")).Trap_Boost;
			}
		}
	},
}

return Addons
