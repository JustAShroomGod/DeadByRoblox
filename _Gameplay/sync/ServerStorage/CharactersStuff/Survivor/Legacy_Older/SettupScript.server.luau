local legacy = script.Parent
char = legacy.Parent


for v0, index in pairs(legacy:GetChildren()) do

	local bodyPart = char:FindFirstChild(index.Name)
	local handler = index:FindFirstChild("Handler")
	local union = index:FindFirstChildOfClass("UnionOperation")
	--print("looking for", index)
	if bodyPart and handler and union then
		--print("legacy script executed")
		--print(union)
		handler.CFrame = bodyPart.CFrame
		handler.Transparency = 1

		local weld = Instance.new("WeldConstraint")
		weld.Parent = handler
		weld.Part0 = bodyPart
		weld.Part1 = handler

		union.UsePartColor = false
		union.Material = "Neon"
		--union.Color = Color3.fromRGB(255, 144, 88) 


		if char.name == "GroznaaGroziepie" then
			union.UsePartColor = true
			union.Color = Color3.fromRGB(85, 85, 255)
		end
		--[[if char.name == "DeadinCombat" then
			union.UsePartColor = true
			union.Color = Color3.fromRGB(85, 85, 255)
		end]]
		if char.name == "listentowaitwhat" then
			union.UsePartColor = true
			union.Color = Color3.fromRGB(85, 85, 255)
		end
		if char.name == "vx5patryk109" then
			union.UsePartColor = true
			union.Color = Color3.fromRGB(0, 196, 255)
		end
		if char.name == "Gamerforyou12" then
			union.UsePartColor = true
			union.Color = Color3.fromRGB(0,0,255)
		end
		if char.name == "Buble2014" then
			union.UsePartColor = true
			union.Color = Color3.fromRGB(0,0,0)
		end
		if char.name == "mauroponce2007" then
			union.UsePartColor = true
			union.Color = Color3.fromRGB(0,0,0)
		end
		if char.name == "AerooDev" then
			union.UsePartColor = true
			union.Color = Color3.fromRGB(0,255,255)
		end
	end
end