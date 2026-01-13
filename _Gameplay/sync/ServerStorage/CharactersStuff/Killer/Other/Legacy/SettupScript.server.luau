local legacy = script.Parent
char = legacy.Parent

for v0, index in pairs(legacy:GetChildren()) do

	local bodyPart = char:FindFirstChild(index.Name)
	local handler = index:FindFirstChild("Handler")
	local union = index:FindFirstChildOfClass("UnionOperation")

	if bodyPart and handler and union then

		handler.CFrame = bodyPart.CFrame
		handler.Transparency = 1

		local weld = Instance.new("WeldConstraint")
		weld.Parent = handler
		weld.Part0 = bodyPart
		weld.Part1 = handler

		union.UsePartColor = true
		union.Material = "Neon"
		union.Color = Color3.fromRGB(255, 82, 0)

		if char.name == "Dinvin11" then
			union.Color = Color3.fromRGB(60, 255, 60)
		end
		if char.name == "vx5patryk109" then
			union.color = Color3.fromRGB(255,255,255)
		end
	end
end

--print("A")