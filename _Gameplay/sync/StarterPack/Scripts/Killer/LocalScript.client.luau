repeat task.wait() until script.Parent.Value == true
-- Allows for easier looping
-- Makes seeing through walls easier
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
task.wait(6) -- Give time to load code
-- Every frame this will run
game:GetService("RunService").RenderStepped:Connect(function()
	for i, Objects in pairs(Character:GetChildren()) do -- Objects gotten
		if Objects:IsA("Part") or Objects:IsA("BasePart") or Objects:IsA("MeshPart") then
			if string.match(Objects.Name, "Torso") then
			else
				Objects.CanCollide = false
			end
		end
	end
end)