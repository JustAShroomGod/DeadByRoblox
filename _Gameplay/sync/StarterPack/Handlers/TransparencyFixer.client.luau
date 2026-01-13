local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

function onUpdate()

	for i, Player in pairs(Players:GetPlayers()) do
		if not Player.Character or not workspace:FindFirstChild(Player.Name) then return end
		if not Player.Character:FindFirstChild("HumanoidRootPart") then return end

		Player.Character.PrimaryPart.Hitbox.LocalTransparencyModifier = 1
		Player.Character.PrimaryPart.Hitbox.Transparency = 1

		--Player.Character.Player_Collider.LocalTransparencyModifier = 1
		--Player.Character.Player_Collider.Transparency = 1

		coroutine.resume(coroutine.create(function()
			for i, g in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
				if (g:IsA("Decal") or g:IsA("Texture")) and (string.match(g.Parent.Name , "Torso") or string.match(g.Parent.Name, "Arm") or string.match(g.Parent.Name, "Leg") or string.match(g.Parent.Name, "Hand") or string.match(g.Parent.Name, "Foot") or string.match(g.Parent.Name, "Handle")) then
					if (game.Players.LocalPlayer.Character:FindFirstChild("Content Creator") ~= nil) then
						if not (g:IsDescendantOf(game.Players.LocalPlayer.Character['Content Creator'])) then
							g.LocalTransparencyModifier = 0
						end
					else
						g.LocalTransparencyModifier = 0
					end
				end
			end
		end))

		for _, body_part in pairs(workspace:WaitForChild(Player.Name):GetChildren()) do

			if ((body_part:IsA("MeshPart") or body_part:IsA("BasePart"))
				and body_part.Name ~= "HumanoidRootPart"
				and body_part.Name ~= "Hitbox"
				and body_part.Name ~= "DarknessTrail"
				--and body_part.Name ~= "Player_Collider"
				)
					and body_part.LocalTransparencyModifier >= 1 then

				body_part.LocalTransparencyModifier = body_part.Transparency
			end
		end
	end
end

RunService.Heartbeat:Connect(onUpdate)