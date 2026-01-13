local module = {}

local humanoid_settings =   {
	BodyDepthScale = 0.9;
	BodyHeightScale = 1.2;
	BodyProportionScale = 0;
	BodyTypeScale = 0;
	BodyWidthScale = 0.73;
	HeadScale = 0.99;
}

function module.load(char, user_id, settings)
	spawn(function()
		if not settings then
			settings = humanoid_settings
		end
		
		char:WaitForChild("Neck"):WaitForChild("Handle")
		
		for name, value in pairs(settings) do
			local object = char.Humanoid:FindFirstChild(name) or Instance.new("NumberValue", char.Humanoid)
			object.Name = name
			object.Value = value
		end
		
		local faceFound = false
		local asset_info = game.Players:GetCharacterAppearanceInfoAsync(user_id)

		for _, my_asset in pairs(asset_info.assets) do
			if my_asset.assetType.name == "Hat" 
			or my_asset.assetType.name == "Shirt" 
			or my_asset.assetType.name == "Pants"
			or my_asset.assetType.name == "TShirt" 
			or my_asset.assetType.name == "Face" 
			or (my_asset.assetType.name:lower():find("accessory")  
				and (
					my_asset.assetType.name:find("Hair")
					or my_asset.assetType.name:find("Face")
					or my_asset.assetType.name:find("Neck")
				)
			)
			then
				
				local my_accessory = game:GetService("InsertService"):LoadAsset(my_asset.id):GetChildren()[1]

				if my_asset.assetType.name:lower():find("accessory") then
					char.Humanoid:AddAccessory(my_accessory)
				elseif my_asset.assetType.name == "Face" then
					faceFound = true
					my_accessory.Parent = char.Head
				else
					my_accessory.Parent = char
				end	
			end
		end
		
		if not faceFound then
			Instance.new("Decal", char.Head).Texture = "rbxasset://textures/face.png"
		end
		
		local bodyColor = char:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors", char)

		for name, id in pairs(asset_info.bodyColors) do
			bodyColor[name:sub(1, 1):upper().. name:sub(2, name:len()):gsub("Id", "")] = BrickColor.new(id)
		end 
		
		
		char.Neck.Handle.BrickColor = bodyColor.HeadColor
		
		local original_size = char.Neck.Handle.OriginalSize.Value
		
		for _, child in pairs (char.Neck.Handle:GetChildren()) do
			if child.Name == "OriginalSize" then
				child:Destroy()
			end
		end
		
		
		char.Neck.Handle.Size = original_size*settings.HeadScale
	end)
end



return module