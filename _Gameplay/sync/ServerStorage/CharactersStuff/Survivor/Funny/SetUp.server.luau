repeat task.wait() until (script.Parent.Parent:FindFirstChild("Humanoid") ~= nil) 
local Character = script.Parent.Parent

for _, BodyParts in pairs(Character:GetChildren()) do
	for i, LegacyParts in pairs(script.Parent:GetChildren()) do
		if BodyParts:IsA("BasePart") or BodyParts:IsA("UnionOperation") or BodyParts:IsA("Part") then
			if LegacyParts:IsA("Folder") then
				if LegacyParts.Name == BodyParts.Name then
					LegacyParts.Handler.CFrame = BodyParts.CFrame
					local WeldConstraint = Instance.new("WeldConstraint", BodyParts)
					WeldConstraint.Name = "FunnyLinePart "..BodyParts.Name
					WeldConstraint.Part1 =  BodyParts
					WeldConstraint.Part0 = LegacyParts.Handler
					LegacyParts.Handler.Anchored = false
					LegacyParts.Handler.Transparency = 1
					LegacyParts.Union.Anchored = false
				end
			end
		end
	end
end