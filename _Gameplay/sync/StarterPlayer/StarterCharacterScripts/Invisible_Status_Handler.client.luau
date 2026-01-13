local Players = game.Players
local RigStorage = workspace:WaitForChild('RigStorage')
local Characterlist = {}

local do_not_alter = {"Lens", "Grip", "Cone", "LightStart", "PhantasmParticles", "DarknessTrail"} -- list of items to nto change (for exiting locker/entering)

function SetTransparency(Character, Amount : number)
	
	for _, v in pairs(Character:GetDescendants()) do
		if v.Name == "HumanoidRootPart" then continue end
		if table.find(do_not_alter, v.Name) then continue end
		
		if v:IsA('BasePart') or v:IsA('MeshPart') then
			v.Transparency = Amount
		elseif v:IsA('ImageLabel') or v:IsA('Decal') then
			v.Transparency = Amount
		end
	end
	
	if RigStorage:FindFirstChild(Character.Name) then

		for _, v in pairs(RigStorage:FindFirstChild(Character.Name):GetDescendants()) do
			if v.Name == "HumanoidRootPart" then continue end
			if table.find(do_not_alter, v.Name) then continue end

			if v:IsA('ImageLabel') or v:IsA('Decal') then
				v.Transparency = Amount
			end
		end
	end
end

function BindCharacter(Character : Model)
	if Characterlist[Character] then return end
	Characterlist[Character] = true -- insert into table
	
	Character:GetAttributeChangedSignal("Invisible"):Connect(function()

		if Character:GetAttribute("Invisible") then
			SetTransparency(Character, 1)
		else
			SetTransparency(Character, 0)
		end
	end)
end

for _, player in pairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(BindCharacter)
	
	if player.Character then
		BindCharacter(player.Character)
	end
end