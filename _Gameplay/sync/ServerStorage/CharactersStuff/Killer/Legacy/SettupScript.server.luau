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
		
		union.UsePartColor = true
		union.Material = "Neon"
		union.Color = Color3.fromRGB(255, 144, 88) 
		
		local iso = (function ()
			if true then return end
			
			if char.name == "Caloday1" then
			union.Color = Color3.fromRGB(255,192,203)
			end
			if char.name == "Dinvin11" then
			union.Color = Color3.fromRGB(60, 255, 60)
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
		end)()
	end
end

