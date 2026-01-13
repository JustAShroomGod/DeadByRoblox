local InsertService = game:GetService('InsertService')
local module = {}
local Player = game.Players.LocalPlayer

function module.load(playerNPC, Settings : "Table") : "loads player appearance"
	if not Settings then return end

	local Character, Userid = playerNPC, playerNPC.UserId.Value
	Userid = if (not Userid or Userid <= 0) then 1 else Userid

	local Appearance = game.Players:GetCharacterAppearanceInfoAsync(Userid)

	-- Create Body Shape/Size --
	for name, value in pairs(Settings) do
		local object = Character.Humanoid:FindFirstChild(name) or Instance.new("NumberValue", Character.Humanoid)
		object.Name = name
		object.Value = value
	end

	Character.Neck.Handle.Size = Character.Neck.Handle.OriginalSize.Value * Settings.HeadScale

	-- Add Player's Accessories --\

	for _, Original in pairs(Appearance.assets) do
		local Asset = Original.assetType.name
		local Import = InsertService:LoadAsset(Original.id):GetChildren()[1]

		if Asset == "Hat" or Asset == "HairAccessory" or Asset == "FaceAccessory" then 
			Character.Humanoid:AddAccessory(Import)
		elseif Asset == "Shirt" or Asset == "Pants" then
			Import.Parent = Character
		elseif Asset == "Face" then
			Import.Parent = Character.Head
		else
			--print(Asset, "Rejected!")
			Import:Destroy()
		end
	end

	-- Assigning body colors --
	local bodyColor = Character:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors", Character)

	for bodyPart, Color in pairs(Appearance.bodyColors) do
		bodyColor[bodyPart:sub(1, 1):upper().. bodyPart:sub(2, bodyPart:len()):gsub("Id", "")] = BrickColor.new(Color)
	end

	Character.Neck.Handle.BrickColor = bodyColor.HeadColor

	if Player.Name == 'PlsGiveMe_ATaco' then
		if Character.Head:FindFirstChild('face') then Character.Head.face:Destroy() end
		script:WaitForChild('face').Parent = Character.Head
	end
end



return module