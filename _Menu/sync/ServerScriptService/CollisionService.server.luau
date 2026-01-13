local Players, Physics = game:GetService("Players"), game:GetService("PhysicsService")

Physics:RegisterCollisionGroup("Player_Collision")
Physics:CollisionGroupSetCollidable("Player_Collision", "Player_Collision", false)

local function DisableCollision(Location : CharacterMesh)
	for _, BodyPart in pairs(Location:GetDescendants()) do
		if BodyPart:IsA("Part") or BodyPart:IsA("BasePart") or BodyPart:IsA("MeshPart") or BodyPart:IsA("UnionOperation") then
			BodyPart.CollisionGroup = "Player_Collision"
		end
	end
end

Players.PlayerAdded:Connect(function(Player)
	local Character = Player.Character or Player.CharacterAdded:Wait()

	DisableCollision(Character)
end)