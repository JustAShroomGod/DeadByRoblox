local legacy = script.Parent
char = legacy.Parent

for v0, index in pairs(legacy:GetChildren()) do
	
	local bodyPart = char:FindFirstChild(index.Name)
	local handler = index:FindFirstChild("Handler")
	local union = index:FindFirstChildOfClass("UnionOperation")
	
	if bodyPart and handler and union then
		
		print ("legacy ")
		
		handler.CFrame = bodyPart.CFrame
		union.Size = Vector3.new(union.Size.X * 1.05,union.Size.Y,union.Size.X * 1.05)
		handler.Transparency = 1
		
		local weld = Instance.new("WeldConstraint")
		weld.Parent = handler
		weld.Part0 = bodyPart
		weld.Part1 = handler
		
		union.UsePartColor = true
		union.Material = "Neon"
		union.Color = Color3.fromRGB(194, 87, 0) 
		
		if char.name == "Caloday1" then
		union.Color = Color3.fromRGB(255,192,203)
		end
		if char.name == "vx5patryk109" then
		union.Color = Color3.fromRGB(0, 196, 255)
		end
		if char.name == "Gamerforyou12" then
		union.Color = Color3.fromRGB(0,0,255)
		end
		if char.name == "Buble2014" then
		union.Color = Color3.fromRGB(0,0,0)
		end
		if char.name == "mauroponce2007" then
		union.Color = Color3.fromRGB(0,0,0)
		end
		if char.name == "AerooDev" then
		union.Color = Color3.fromRGB(0,255,255)
		end

	end
	
end