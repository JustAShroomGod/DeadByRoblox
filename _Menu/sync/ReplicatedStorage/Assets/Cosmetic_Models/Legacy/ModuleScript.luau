local module = {}

function module.apply()
	local self = {}
	
	local legacy = script.Parent
	local char = legacy.Parent
	
	local folder = Instance.new("Folder", workspace)
	folder.Name = "welds"
	
	for v0, index in pairs(legacy:GetChildren()) do

		local bodyPart = char:FindFirstChild(index.Name)
		local handler = index:FindFirstChild("Handler")
		local union = index:FindFirstChildOfClass("UnionOperation")

		if bodyPart and handler and union then
			--print("legacy script executed")
			handler.CFrame = bodyPart.CFrame
			handler.Transparency = 1

			local weld = Instance.new("WeldConstraint")
			weld.Parent = folder
			weld.Part0 = bodyPart
			weld.Part1 = handler

			union.UsePartColor = true
			union.Material = "Neon"
			union.Color = Color3.fromRGB(184, 149, 10) 
			
			local list2 = {
				function (copy)
					local unit = 0.3
					
					copy.Color3 = Color3.fromRGB(134, 110, 12)
					copy.StudsPerTileU = unit
					copy.StudsPerTileV = unit
					
					--copy.Transparency = 0.4
				end
				--[[
				,function (copy)
					local unit = 0.4

					copy.StudsPerTileU = unit
					copy.StudsPerTileV = unit

					copy.Transparency = 0.5
				end]]
			}
			
			local list = {
				Back = true
				,Bottom = true
				,Front = true
				,Left = true
				,Top = true
				,Right = true
			}
			list2 = {}
			for _, my_function in pairs (list2) do
				for face, _ in pairs(list) do
					local copy = script.Texture:Clone()
					copy.Face = face
					copy.Parent = union
					
					my_function(copy)
				end
			end
		end
	end
	
	folder.Parent = legacy
	
	self.object = legacy
	
	if false then
		char.Head.Transparency = 1/10
		
		char.UpperTorso.Transparency = 2/10
		char.LowerTorso.Transparency = 2/10
		char.LeftUpperArm.Transparency = 2/10
		char.LeftLowerArm.Transparency = 2/10
		char.RightUpperArm.Transparency = 2/10
		char.RightLowerArm.Transparency = 6/10
		char.LeftUpperLeg.Transparency = 3/10
		char.LeftLowerLeg.Transparency = 7/10
		char.RightUpperLeg.Transparency = 3/10
		char.RightLowerLeg.Transparency = 7/10
	end
	
	script.Parent.Part:Destroy()
	
	return self
end

return module
