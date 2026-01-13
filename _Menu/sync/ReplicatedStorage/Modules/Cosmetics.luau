local RigPrefabs = script.Parent.Parent:WaitForChild("RigPrefabs")

local module = {}

local function LoadSurvivor(Humanoid : Humanoid, Cosmetic)
	local SurvivorFolder = RigPrefabs:FindFirstChild("Survivor")
	local Character = Humanoid.Parent

	--HEAD
	Humanoid:ReplaceBodyPartR15(Enum.BodyPartR15.Head, SurvivorFolder:FindFirstChild(Cosmetic):FindFirstChild("Head"):Clone())
	
	--TORSO
	for _, BasePart : BasePart in pairs(SurvivorFolder:FindFirstChild(Cosmetic):GetChildren()) do
		if not BasePart:IsA("MeshPart")  or not (string.match(BasePart.Name,"Torso")) or not (string.match(BasePart.Name,"Hand")) or not (string.match(BasePart.Name,"Arm"))  then
			if BasePart:IsA("Pants") or BasePart:IsA("Shirt") then
				BasePart:Clone().Parent = Humanoid.Parent
			end

			continue 
		end

		Humanoid:ReplaceBodyPartR15(Enum.BodyPartR15[BasePart.Name], BasePart:Clone())

	end

	--LEGS
	for _, BasePart : BasePart in pairs(SurvivorFolder:FindFirstChild(Cosmetic):GetChildren()) do
		if not BasePart:IsA("MeshPart") or not (string.match(BasePart.Name,"Foot")) or not (string.match(BasePart.Name,"Leg")) then

			if BasePart:IsA("Pants") or BasePart:IsA("Shirt") then
				BasePart:Clone().Parent = Humanoid.Parent
			end

			continue 
		end

		Humanoid:ReplaceBodyPartR15(Enum.BodyPartR15[BasePart.Name], BasePart:Clone())
	end

	--NECK
	if SurvivorFolder:FindFirstChild(Cosmetic):FindFirstChild("Neck") then
		Character:FindFirstChild("Neck"):FindFirstChild("Handle").Color = SurvivorFolder:FindFirstChild(Cosmetic):FindFirstChild("Neck"):FindFirstChild("Handle").Color
	end
end

local function SetWeapon(Character, DesiredModel : Model, SelectedKiller : string)
	local Weapon : Model = DesiredModel
	Weapon.Name = SelectedKiller
	Weapon:Clone().Parent = Character
end

local function LoadKiller(Humanoid : Humanoid, Cosmetic, SelectedKiller)
	local KillerFolder = RigPrefabs:FindFirstChild(SelectedKiller)
	local Character = Humanoid.Parent

	--HEAD
	Humanoid:ReplaceBodyPartR15(Enum.BodyPartR15.Head, KillerFolder:FindFirstChild(Cosmetic):FindFirstChild("Head"):Clone())

	--TORSO AND LEGS
	for _, BasePart : BasePart in pairs(KillerFolder:FindFirstChild(Cosmetic):GetChildren()) do
		if not BasePart:IsA("MeshPart") then
			if BasePart:IsA("Pants") or BasePart:IsA("Shirt") then
				BasePart:Clone().Parent = Humanoid.Parent
			end

			continue 
		end

		Humanoid:ReplaceBodyPartR15(Enum.BodyPartR15[BasePart.Name], BasePart:Clone())
	end

	--WEAPON
	SetWeapon(Character, KillerFolder:FindFirstChild(Cosmetic):FindFirstChild("Weapon"):Clone(), SelectedKiller)

	--NECK
	Character:FindFirstChild("Neck"):FindFirstChild("Handle").Color = KillerFolder:FindFirstChild(Cosmetic):FindFirstChild("Neck"):FindFirstChild("Handle").Color
end

function module.RemoveScripts()

	for _,Script in pairs(RigPrefabs:GetDescendants()) do
		if Script:IsA("LocalScript")  then
			Script:Destroy()
		end
	end
end

function module.ApplyCosmetic(Rig : Model, Cosmetic : string, Side : string, SelectedKiller : string)
	if Side == "Survivor" then
		LoadSurvivor(Rig.Humanoid, Cosmetic)
	else
		LoadKiller(Rig.Humanoid, Cosmetic, SelectedKiller)
	end
	
end

return module
