local Debounce = false
local Reset_Point = script.Parent.Parent:WaitForChild('Reset')

local Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))

local Reward_Amount = 75000
local Reward_Cooldown = 15 -- minutes

script.Parent.Touched:Connect(function(part)
	if Debounce then return end
	Debounce = true
	
	local Humanoid = part.Parent:FindFirstChildOfClass('Humanoid')
	
	if Humanoid then
		Humanoid.Parent:PivotTo(Reset_Point:GetPivot())
		
		local Player = game.Players:GetPlayerFromCharacter(Humanoid.Parent)
		
		if Player and Module then
			local Player_Data = Module:GetRaw(Player)

			if Player and Player_Data and Player_Data.Main then
				Player_Data = Player_Data.Main

				if not Player_Data.Misc.Obby then
					Player_Data.Misc.Obby = 0
				end

				if Player and (workspace:GetServerTimeNow() - Player_Data.Misc.Obby) >= (Reward_Cooldown * 60) then
					Player_Data.Misc.Obby = workspace:GetServerTimeNow()
					Module:SetCurrency(Reward_Amount, Player)
				end
			end
		end
	end
	
	task.wait(1)
	
	Debounce = false
end)