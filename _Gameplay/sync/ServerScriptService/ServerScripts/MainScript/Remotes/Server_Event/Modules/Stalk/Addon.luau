local AddonStorage = game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')

local Addons = {
	MemorialFlower = {
		Effects = {
			Positive = {
				Type = "SPEED_STALK"; -- move speed upgrade for cloaked
				Value = require(AddonStorage:WaitForChild("MemorialFlower")).Stalk_Boost; -- 30 percent increase
			}
		}
	},
	HeartLocket = {
		Effects = {
			Positive = {
				Type = "SPEED_STALK"; -- move speed upgrade for cloaked
				Value = require(AddonStorage:WaitForChild("Heart Locket")).Stalk_Boost; -- 30 percent increase
			}
		}	
	},
	
	ClownMask = {
		Effects = {
			Positive = {
				Type = "DURATION_STALK"; -- can only change size of it
				Value = require(AddonStorage:WaitForChild("ClownMask")).Duration_Boost; -- 30 percent increase
			}
		}
	},
}

return Addons
