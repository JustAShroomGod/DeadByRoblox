local Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))
local Rain = {
	IsRaining = false
}

function SpawnOrb(Reward_Amount, Character)
	if not Character and not Character.Parent then return end
	
	local Debounce, Touched = false, 0

	local Orb = Instance.new("Part", workspace)
	--Orb.Anchored = true
	Orb.Shape = Enum.PartType.Ball
	Orb.Size = Vector3.new(7.5, 7.5, 7.5)
	Orb.CanCollide = false
	Orb.Material = Enum.Material.Neon
	Orb.Color = Color3.fromRGB(255, 0, 4)

	Orb:PivotTo(Character:GetPivot() * CFrame.new(math.random(-20, 20), math.random(100, 1000), math.random(-20, 20)))

	Orb.Touched:Connect(function(part)
		if Debounce or not part.Parent then return end
		Debounce = true

		Touched += 1

		local Humanoid = part.Parent:FindFirstChildOfClass('Humanoid')

		if Humanoid then
			local Player = game.Players:GetPlayerFromCharacter(Humanoid.Parent)

			if Player and Module then
				local Player_Data = Module:GetRaw(Player)

				if Player and Player_Data and Player_Data.Main then
					Player_Data = Player_Data.Main

					Module:SetCurrency(Reward_Amount, Player)
					Orb:Remove()
				end
			end
		end

		if Orb and Orb.Parent and Touched >= 3 then
			Orb:Remove()
		end

		Debounce = false
	end)
end

function Rain:Cast(User : Player, Reward_Amount)
	if Rain.IsRaining then return end
	Rain.IsRaining = true
	
	--local Reward_Amount = 3000
	local amount = 100

	while amount > 0 do
		amount -= 1
		task.wait(0.5)

		for i = 1, math.random(2, 10), 1 do
			SpawnOrb(Reward_Amount, User.Character)
		end
	end
	
	Rain.IsRaining = false
end

return Rain
