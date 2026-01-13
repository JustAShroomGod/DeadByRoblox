local InsertService : InsertService, Players : Players, ServerStorage : ServerStorage, ReplicatedStorage :ReplicatedStorage = game:GetService('InsertService'), game:GetService("Players"), game:GetService("ServerStorage"), game:GetService("ReplicatedStorage")

local RigPrefabs = ServerStorage:FindFirstChild("RigPrefabs")

local module = {}

local function LoadAccessories(Character : Model, Cosmetics : table, Userid : number) --this is JUST for the default cosmetic set pieces for survivor.
	local Appearance = Players:GetCharacterAppearanceInfoAsync(Userid)
	local SurvivorFolder = RigPrefabs:FindFirstChild("Survivor")

	for _, Original in pairs(Appearance.assets) do
		local Asset = Original.assetType.name
		local Import = InsertService:LoadAsset(Original.id):GetChildren()[1]

		if (Cosmetics.Head == "Default" or SurvivorFolder:FindFirstChild(Cosmetics.Head):GetAttribute("DecalsOnly")) and (Asset == "Hat" or Asset == "HairAccessory" or Asset == "FaceAccessory" or Asset == "NeckAccessory") then
			Character.Humanoid:AddAccessory(Import)
		elseif (Cosmetics.Head == "Default" or SurvivorFolder:FindFirstChild(Cosmetics.Head):GetAttribute("DecalsOnly")) and Asset == "Face" then
			if Character.Head:FindFirstChild("face") then
				Character.Head:FindFirstChild("face"):Destroy()
			end

			Import.Parent = Character.Head
		elseif (Cosmetics.Torso == "Default" or SurvivorFolder:FindFirstChild(Cosmetics.Torso):GetAttribute("DecalsOnly")) and (Asset == "Shirt" or Asset == "TShirt") then
			Import.Parent = Character
		elseif (Cosmetics.Legs == "Default" or SurvivorFolder:FindFirstChild(Cosmetics.Legs):GetAttribute("DecalsOnly")) and Asset == "Pants" then
			Import.Parent = Character
		else
			Import:Destroy()
		end
	end	
end

local function ApplyDecals(Character, CosmeticModel : Model, Type : string, Userid : number) --devotion, legacy, prestige
	local Appearance = Players:GetCharacterAppearanceInfoAsync(Userid)

	local function GetDecalsAndApply(Part)
		for _, Decal in pairs(Part:GetChildren()) do
			if not Decal:IsA("Decal") then
				continue
			else
				local Clone = Decal:Clone()
				Clone.Parent = Character:FindFirstChild(Part.Name)
			end
		end
	end

	if Type == "Head" then
		GetDecalsAndApply(CosmeticModel:FindFirstChild("Head"))

		if CosmeticModel:GetAttribute("DecalsOnly") then
			Character:FindFirstChild("Head").Color = Appearance.bodyColor3s.headColor3
		end

		Character:FindFirstChild("Neck"):FindFirstChild("Handle").Color = Appearance.bodyColor3s.headColor3
	elseif Type == "Torso" then
		for _, BasePart : BasePart in pairs(CosmeticModel:GetChildren()) do
			if not BasePart:IsA("MeshPart") then
				continue 
			end

			if (string.match(BasePart.Name,"Torso")) or (string.match(BasePart.Name,"Hand")) or (string.match(BasePart.Name,"Arm")) then
				GetDecalsAndApply(BasePart)

				if CosmeticModel:GetAttribute("DecalsOnly") then
					if (string.match(BasePart.Name,"Torso")) then
						Character[BasePart.Name].Color = Appearance.bodyColor3s.torsoColor3
					elseif (string.match(BasePart.Name,"Left")) then
						Character[BasePart.Name].Color = Appearance.bodyColor3s.leftArmColor3
					else
						Character[BasePart.Name].Color = Appearance.bodyColor3s.rightArmColor3
					end
				end
			end
		end
	elseif Type == "Legs" then
		for _, BasePart : BasePart in pairs(CosmeticModel:GetChildren()) do
			if not BasePart:IsA("MeshPart") then
				continue 
			end

			if (string.match(BasePart.Name,"Foot")) or (string.match(BasePart.Name,"Leg")) then
				GetDecalsAndApply(BasePart)

				if CosmeticModel:GetAttribute("DecalsOnly") then
					if (string.match(BasePart.Name,"Left")) then
						Character[BasePart.Name].Color = Appearance.bodyColor3s.leftLegColor3
					else
						Character[BasePart.Name].Color = Appearance.bodyColor3s.rightLegColor3
					end
				end
			end
		end
	end
end

local function LoadSurvivor(Humanoid : Humanoid, Data, Userid : number)
	local SurvivorFolder = RigPrefabs:FindFirstChild("Survivor")
	local Character = Humanoid.Parent

	local Cosmetics = {
		Head = 	Data.Loadout.Cosmetic.Head or "Default";
		Torso = Data.Loadout.Cosmetic.Torso or "Default";
		Legs = Data.Loadout.Cosmetic.Legs or "Default";
	}

	if not SurvivorFolder:FindFirstChild(Cosmetics.Head) then Cosmetics.Head = "Default" end
	if not SurvivorFolder:FindFirstChild(Cosmetics.Torso) then Cosmetics.Torso = "Default" end
	if not SurvivorFolder:FindFirstChild(Cosmetics.Legs) then Cosmetics.Legs = "Default" end

	--HEAD
	Humanoid:ReplaceBodyPartR15(Enum.BodyPartR15.Head, SurvivorFolder:FindFirstChild(Cosmetics.Head):FindFirstChild("Head"):Clone())
	ApplyDecals(Character, SurvivorFolder:FindFirstChild(Cosmetics.Head), "Head", Userid)

	--TORSO
	for _, BasePart : BasePart in pairs(SurvivorFolder:FindFirstChild(Cosmetics.Torso):GetChildren()) do
		if not BasePart:IsA("MeshPart")  or not (string.match(BasePart.Name,"Torso")) or not (string.match(BasePart.Name,"Hand")) or not (string.match(BasePart.Name,"Arm"))  then
			if BasePart:IsA("Shirt") then
				BasePart:Clone().Parent = Humanoid.Parent
			end

			continue 
		end

		Humanoid:ReplaceBodyPartR15(Enum.BodyPartR15[BasePart.Name], BasePart:Clone())
	end

	ApplyDecals(Character, SurvivorFolder:FindFirstChild(Cosmetics.Torso), "Torso", Userid)

	--LEGS
	for _, BasePart : BasePart in pairs(SurvivorFolder:FindFirstChild(Cosmetics.Legs):GetChildren()) do
		if not BasePart:IsA("MeshPart") or not (string.match(BasePart.Name,"Foot")) or not (string.match(BasePart.Name,"Leg")) then

			if BasePart:IsA("Pants") then
				BasePart:Clone().Parent = Humanoid.Parent
			end

			continue 
		end

		Humanoid:ReplaceBodyPartR15(Enum.BodyPartR15[BasePart.Name], BasePart:Clone())
	end

	ApplyDecals(Character, SurvivorFolder:FindFirstChild(Cosmetics.Legs), "Legs", Userid)

	--NECK
	if SurvivorFolder:FindFirstChild(Cosmetics.Head):FindFirstChild("Neck") and not SurvivorFolder:FindFirstChild(Cosmetics.Head):GetAttribute("DecalsOnly")  then
		Character:FindFirstChild("Neck"):FindFirstChild("Handle").Color = SurvivorFolder:FindFirstChild(Cosmetics.Head):FindFirstChild("Neck"):FindFirstChild("Handle").Color
	end

	LoadAccessories(Character, Cosmetics, Userid)
end

local function SetWeapon(Character, DesiredModel : Model, SelectedKiller : string)
	local Weapon : Model = DesiredModel
	Weapon.Name = SelectedKiller
	Weapon:Clone().Parent = Character

	local Power : Model = Weapon:GetAttribute("Power")
	Power = if Power == "Hatchet" then ReplicatedStorage.KillerStuff:WaitForChild('Hatchet') elseif Power then ServerStorage:WaitForChild('KillerStuff'):FindFirstChild(Power) else nil

	if Power then
		Power:Clone().Parent = Character
	end

	local Weld = Instance.new('Motor6D', Character.Head)
	Weld.Part0 = Character.Head

	local FlashClone = ReplicatedStorage:WaitForChild('Flash_Zone'):Clone()
	FlashClone.Parent = Character
	Weld.Part1 = FlashClone

	Weld.C1 = CFrame.new(0,0,.65)
end

local function LoadKiller(Humanoid : Humanoid, Data, SelectedKiller)
	local KillerFolder = if not RigPrefabs:FindFirstChild(SelectedKiller) then RigPrefabs:FindFirstChild("Trapper") else RigPrefabs:FindFirstChild(SelectedKiller)
	local Character = Humanoid.Parent

	local Cosmetics = {
		Head = 	Data.Loadout.Cosmetic.Head or "Default";
		Torso = Data.Loadout.Cosmetic.Torso or "Default";
		Weapon = Data.Loadout.Cosmetic.Weapon or "Default";
	}

	if not KillerFolder:FindFirstChild(Cosmetics.Head) then Cosmetics.Head = "Default" end
	if not KillerFolder:FindFirstChild(Cosmetics.Torso) then Cosmetics.Torso = "Default" end
	if not KillerFolder:FindFirstChild(Cosmetics.Weapon) then Cosmetics.Weapon = "Default" end

	--HEAD
	Humanoid:ReplaceBodyPartR15(Enum.BodyPartR15.Head, KillerFolder:FindFirstChild(Cosmetics.Head):FindFirstChild("Head"):Clone())

	--TORSO AND LEGS
	for _, BasePart : BasePart in pairs(KillerFolder:FindFirstChild(Cosmetics.Torso):GetChildren()) do
		if not BasePart:IsA("MeshPart") then
			if BasePart:IsA("Pants") or BasePart:IsA("Shirt") then
				BasePart:Clone().Parent = Humanoid.Parent
			end

			continue 
		end

		Humanoid:ReplaceBodyPartR15(Enum.BodyPartR15[BasePart.Name], BasePart:Clone())
	end

	--WEAPON
	SetWeapon(Character, KillerFolder:FindFirstChild(Cosmetics.Weapon):FindFirstChild("Weapon"):Clone(), SelectedKiller)

	--NECK

	if KillerFolder:FindFirstChild(Cosmetics.Torso):FindFirstChild("Neck") then
		Character:FindFirstChild("Neck"):FindFirstChild("Handle").Color = KillerFolder:FindFirstChild(Cosmetics.Torso):FindFirstChild("Neck"):FindFirstChild("Handle").Color
	end
end



function module.load(Player : Player, Settings : "Table", Side : "String", Data, SelectedKiller : string) : "loads player appearance"
	local Character, Userid, Humanoid = Player.Character, Player.UserId, Player.Character.Humanoid

	--Load in humanoid description
	if Settings then 
		for name, value in pairs(Settings) do
			local object = Humanoid:FindFirstChild(name) or Instance.new("NumberValue", Character.Humanoid)
			object.Name = name
			object.Value = value
		end	
	end

	Userid = if (not Userid or Userid <= 0) then 1 else Userid

	if Side == "Killer" then
		LoadKiller(Humanoid, Data, SelectedKiller)
	else
		LoadSurvivor(Humanoid, Data, Userid)
	end

	--fix to the missing motor6d
	if not Character:FindFirstChild("LowerTorso"):FindFirstChild("Root") then
		local Motor6D = Instance.new("Motor6D")
		Motor6D.Part0 = Character:FindFirstChild("HumanoidRootPart")
		Motor6D.Part1 = Character:FindFirstChild("LowerTorso")
		Motor6D.C0.Position = CFrame.new(0,-1,0)
		Motor6D.C1.Position = CFrame.new(-0, -0.325, 0)
		Motor6D.Parent = Character:FindFirstChild("LowerTorso")
	end

	if Player.Name == 'KameronLP11' or Player.Name == 'GroznaaGroziepie' --[[or Player.Name == 'DeadinCombat']] or Player.Name == 'listentowaitwhat' then
		game.ServerStorage.CharactersStuff.Survivor.Legacy_Older:Clone().Parent = Character
	end
end


return module
