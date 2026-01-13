local Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))

local Reward_Amount = 1000

local function SpawnOrb()
	local Debounce, Touched = false, 0

	local Orb = Instance.new("Part", workspace)
	--Orb.Anchored = true
	Orb.Shape = Enum.PartType.Ball
	Orb.Size = Vector3.new(50, 50, 50)
	Orb.CanCollide = false
	Orb.Material = Enum.Material.Neon
	Orb.Color = Color3.fromRGB(255, 0, 4)

	Orb:PivotTo(workspace.cheetamcu:GetPivot() * CFrame.new(math.random(-70, 70), math.random(800, 1000), math.random(-70, 70)))


	Orb.Touched:Connect(function(part)
		if Debounce then return end
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

local amount = 10

while amount > 0 do
	amount -= 1
	task.wait(0.5)

	for i = 1, math.random(2, 3), 1 do
		SpawnOrb()
	end
end