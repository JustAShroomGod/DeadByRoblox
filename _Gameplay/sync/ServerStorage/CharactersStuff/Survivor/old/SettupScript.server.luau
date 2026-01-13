local char = script.Parent.Parent
local faces = {"Right", "Left", "Front", "Back"}
local limits = {"Head", "HumanoidRootPart", "LeftHand",
	["UpperTorso"] = {"Left", "Right"},
	 ["LowerTorso"] = {"Left", "Right"},
	["LeftLowerArm"] = {"Left", "Right", "Front"},
	["RightUpperArm"] = {"Right"},
	["RightLowerArm"] = {"Left", "Right", "Front"},
	["RightHand"] = {"Back", "Left", "Front"},  
	}

local prefix = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId="
local assetId = prefix.. tostring(3077966956)
for v0, child in pairs (char:GetChildren()) do
	if child.ClassName == "Part" or child.ClassName == "MeshPart" then
		local skip = false
		for v1, limit0 in pairs (limits) do
			if type(limit0) ~= "table" then if child.Name == limit0 then skip = true end end  
		end
		if skip == false then
			for v2, face in pairs (faces) do
				local skip = false
				for v1, limit0 in pairs (limits) do
					if type(limit0) == "table" then
						if child.Name == v1 then
							for v2, limit1 in pairs (limit0) do
								if face == limit1 then skip = true end
							end
						end
					end
				end
				if skip == false then
					local surfaceGui = Instance.new("SurfaceGui", script.Parent) surfaceGui.Face = face
					surfaceGui.LightInfluence = 0 surfaceGui.Adornee = child
					local imageLabel = Instance.new("ImageLabel", surfaceGui) 
					imageLabel.BackgroundTransparency = 1 imageLabel.Size = UDim2.new(0.6, 0, 0.6, 0)
					imageLabel.Position = UDim2.new(0.2, 0, 0.2, 0) imageLabel.Image = assetId imageLabel.Rotation = 0
					local imageLabel = Instance.new("ImageLabel", surfaceGui) 
					imageLabel.BackgroundTransparency = 1 imageLabel.Size = UDim2.new(0.3, 0, 0.3, 0)
					imageLabel.Position = UDim2.new(0.2, 0, 0.2, 0) imageLabel.Image = assetId imageLabel.Rotation = 180
				end
			end
		end
	end
end