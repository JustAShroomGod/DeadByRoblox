local TweenService : TweenService = game:GetService('TweenService')

local Backup_Length = 2

local Bell_Animation = script.Parent.Parent.Parent:WaitForChild('Animations'):WaitForChild('Wraith_Bell')
local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local AddonValues = {
	Serpent = require(script.Parent:WaitForChild("Addon")).Serpent
}

local Wraith = {
	Visual = {
		Transparency = 0.93;
		ColorShift = Color3.fromRGB(255, 80, 0);
	},
	Settings = {
		AnimationSpeeds = {
			Cloak = 1.67; -- 2 second animation = 1.5 second cloak time
			Uncloak = 0.67; -- 2 second animation = 3 second toal
			Serpent = 0.67 --gets modified later on with addon --1.2;
		},
	},
	Characters = {}
}

local function FindWeapon(Character : Model)
	for _,Weapon in pairs(Character:GetChildren()) do
		if Weapon:GetAttribute("Type") == "Weapon" then
			return Weapon
		end
	end
end

function GenerateData(Character : Model) : "Create Tweening Data"
	if Wraith.Characters[Character.Name] then return end

	Wraith.Characters[Character.Name] = {} -- create character/tween data for this character

	Wraith.Characters[Character.Name].State = "Nothing"

	Wraith.Characters[Character.Name].Weapon = {
		Bell = Character:WaitForChild('Bell');
		Skull = FindWeapon(Character)
	}

	Wraith.Characters[Character.Name].AnimationSpeeds = {
		Cloak = Wraith.Settings.AnimationSpeeds.Cloak;
		Uncloak = Wraith.Settings.AnimationSpeeds.Uncloak;
		Serpent = Wraith.Settings.AnimationSpeeds.Serpent;
	}

	Wraith.Characters[Character.Name].AnimationSpeeds.Serpent *= (1 + AddonValues.Serpent.Value/100) --adjusts according to the addon

	Wraith.Characters[Character.Name].Decals = {}
	Wraith.Characters[Character.Name].Accessories = {}

	Wraith.Characters[Character.Name].TweenOrder = {
		{Character:WaitForChild('Head')},
		{Character:WaitForChild('RightHand'), Character:WaitForChild('LeftHand')},
		{Character:WaitForChild('RightLowerArm'), Character:WaitForChild('LeftLowerArm')},
		{Character:WaitForChild('RightUpperArm'), Character:WaitForChild('LeftUpperArm')},
		{Character:WaitForChild('UpperTorso')},
		{Character:WaitForChild('LowerTorso')},
		{Character:WaitForChild('RightUpperLeg'), Character:WaitForChild('LeftUpperLeg')},
		{Character:WaitForChild('RightLowerLeg'), Character:WaitForChild('LeftLowerLeg')},
		{Character:WaitForChild('RightFoot'), Character:WaitForChild('LeftFoot')}
	}

	Wraith.Characters[Character.Name].Cloth = {
		Shirt = {},
		Pants = {},
	}

	for _, part in pairs(Character:GetChildren()) do

		if part.Name == "Shirt" then
			Wraith.Characters[Character.Name].Cloth.Shirt.Source = part
			Wraith.Characters[Character.Name].Cloth.Shirt.Id = part.ShirtTemplate
		elseif part.Name == "Pants" then
			Wraith.Characters[Character.Name].Cloth.Pants.Source = part
			Wraith.Characters[Character.Name].Cloth.Pants.Id = part.PantsTemplate
		end
	end

	Wraith.Characters[Character.Name].Colors = {}

	for _, tbl in pairs(Wraith.Characters[Character.Name].TweenOrder) do

		for index, part in pairs(tbl) do
			Wraith.Characters[Character.Name].Colors[part.Name] = part.Color
		end
	end

	for _, descendant in pairs(Character:GetDescendants()) do

		if descendant:IsA('Decal') then
			table.insert(Wraith.Characters[Character.Name].Decals, descendant)
		elseif descendant:IsA('Accessory') then
			table.insert(Wraith.Characters[Character.Name].Accessories, descendant)
		end
	end

	Wraith.Characters[Character.Name].Tweens = {
		Cloak = {},
		Uncloak = {},
		Serpent = {},
	}

	Wraith.Characters[Character.Name].AnimationTrack = Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(Bell_Animation)

	Wraith.Characters[Character.Name].Cancel = Instance.new('BindableEvent')

	-- Adding Sound Effects --
	local function PlaySound(id : number, volume : number, pitch : number) : "Play Sound"
		local Sound = Instance.new('Sound', Wraith.Characters[Character.Name].Weapon.Bell:WaitForChild('Handle'))
		Sound.PlayOnRemove = true
		Sound.Volume = if volume then volume else 1
		Sound.SoundId = "http://www.roblox.com/Asset?ID="..tostring(id)
		Sound:Remove()
	end

	local function playSoundEffect(name : string) : "Plays sound based on cue"
		if name == "BellHitOne" then
			PlaySound(2631174539)
		elseif name == "BellHitTwo" then
			PlaySound(2631175305)
		elseif name == "Transition" then
			PlaySound(2631174234)
		elseif name == "TurnedVisible" then
			PlaySound(2631175881)
		elseif name == "TurnedInvisible" then
			PlaySound(2631177191)
		end
	end

	Wraith.Characters[Character.Name].AnimationTrack.KeyframeReached:Connect(playSoundEffect)

	if Wraith.Characters[Character.Name].AnimationTrack.Length > 0 then
		Wraith.Characters[Character.Name].AnimationLength = Wraith.Characters[Character.Name].AnimationTrack.Length
	else
		game:GetService('ContentProvider'):PreloadAsync({Bell_Animation})
		Wraith.Characters[Character.Name].AnimationLength = Wraith.Characters[Character.Name].AnimationTrack.Length
	end

	local Times = {
		Cloak_Time = Wraith.Characters[Character.Name].AnimationLength * (1/Wraith.Characters[Character.Name].AnimationSpeeds.Cloak),
		Uncloak_Time = Wraith.Characters[Character.Name].AnimationLength * (1/Wraith.Characters[Character.Name].AnimationSpeeds.Uncloak),
		Serpent_Time = Wraith.Characters[Character.Name].AnimationLength * (1/Wraith.Characters[Character.Name].AnimationSpeeds.Serpent)
	}

	local Categories = {"Cloak", "Uncloak", "Serpent"}

	-- pre-render tweens --

	for index, key in ipairs(Categories) do

		for order, bodytable in pairs(Wraith.Characters[Character.Name].TweenOrder) do	
			for _, bodypart in pairs(bodytable) do
				if (Wraith.Characters[Character.Name].Tweens[key][order] == nil) then
					Wraith.Characters[Character.Name].Tweens[key][order] = {}
				end

				local Tween = TweenService:Create(bodypart, TweenInfo.new(Times[key .. "_Time"] - .1), {Transparency = 0, Color = Wraith.Visual.ColorShift})

				Wraith.Characters[Character.Name].Cancel.Event:Connect(function()
					Tween:Cancel()
				end)

				table.insert(Wraith.Characters[Character.Name].Tweens[key][order], Tween)
			end
		end

		for _, weapon in pairs(Wraith.Characters[Character.Name].Weapon) do
			local Handle = weapon:FindFirstChild("Handle")

			if Handle then
				local Tween = TweenService:Create(Handle, TweenInfo.new(Times[key .. "_Time"] - .1), {Transparency = 0, Color = Wraith.Visual.ColorShift})

				Wraith.Characters[Character.Name].Cancel.Event:Connect(function()
					Tween:Cancel()
				end)

				table.insert(Wraith.Characters[Character.Name].Tweens[key][1], Tween)
			end
		end
	end
end

function SetTransparency(Character : Model, Transparency : number) : "Set Transparency of Decals + Hats"
	if not Wraith.Characters[Character.Name] then return warn("No table") end

	local Rigged_Character = workspace.RigStorage:FindFirstChild(Character.Name)

	if Rigged_Character then
		for _, part in pairs(Rigged_Character:GetDescendants()) do

			if part:IsA('Decal') then
				part.Transparency = Transparency
			end
		end
	end

	for _, part in pairs(Character:GetDescendants()) do

		if part:IsA('Decal') then
			part.Transparency = Transparency
		end
	end

	for _, decal in pairs(Wraith.Characters[Character.Name].Decals) do
		decal.Transparency = Transparency
	end

	for _, accessory in pairs(Wraith.Characters[Character.Name].Accessories) do
		local handle = accessory:FindFirstChild('Handle')

		if handle then
			handle.Transparency = Transparency
		end
	end
end

function SetProperties(Character : Model, Transparency : number, Color : "Normal" | "Neon" | "Black", Material : Enum.Material) : "Quick set Look of body parts + weapon"
	if not Wraith.Characters[Character.Name] then return warn("No table") end

	for order, bodytable in pairs(Wraith.Characters[Character.Name].TweenOrder) do

		for _, bodypart in pairs(bodytable) do
			bodypart.Transparency = Transparency

			if Color then

				if Color == "Neon" then
					bodypart.Color = Wraith.Visual.ColorShift
				elseif Color == "Black" then
					bodypart.Color = Color3.fromRGB()
				elseif Color == "Normal" then
					bodypart.Color = Wraith.Characters[Character.Name].Colors[bodypart.Name] or Color3.fromRGB(1, 37, 109)
				end
			end

			if Material then
				bodypart.Material = Material
			end
		end
	end

	for _, weapon in pairs(Wraith.Characters[Character.Name].Weapon) do
		local Handle = weapon:FindFirstChildWhichIsA("UnionOperation")
		if Handle then
			Handle.Transparency = Transparency

			if Color then

				if Color == "Normal" then
					Handle.UsePartColor = false
					Handle.Color = Wraith.Visual.ColorShift
				elseif Color == "Black" then
					Handle.UsePartColor = true
					Handle.Color = Color3.fromRGB()
				elseif Color == "Neon" then
					Handle.UsePartColor = true
					Handle.Color = Wraith.Visual.ColorShift
				end
			end

			if Material then

				if Material == Enum.Material.SmoothPlastic or Material == Enum.Material.Plastic then
					if (Handle.Parent:FindFirstChild("Blade") ~= nil) then
						Handle.Material = Enum.Material.Slate
					else
						Handle.Material = Enum.Material.Metal
					end
				else
					Handle.Material = Material
				end
			end
		end
	end
end

function SetCloth(Character, bool : boolean) : "Set Clothes"
	if not Wraith.Characters[Character.Name] then return warn("No Table") end

	if Wraith.Characters[Character.Name].Cloth.Shirt.Source then
		Wraith.Characters[Character.Name].Cloth.Shirt.Source.ShirtTemplate = if bool then Wraith.Characters[Character.Name].Cloth.Shirt.Id else ""
	end

	if Wraith.Characters[Character.Name].Cloth.Pants.Source then
		Wraith.Characters[Character.Name].Cloth.Pants.Source.PantsTemplate = if bool then Wraith.Characters[Character.Name].Cloth.Pants.Id else ""
	end
end

--

function Wraith:Cloak(Character, IsStart) : "Does Cloaking Animation"
	if not Wraith.Characters[Character.Name] then GenerateData(Character) end
	local Cloak_Time = Wraith.Characters[Character.Name].AnimationLength * (1/Wraith.Characters[Character.Name].AnimationSpeeds.Cloak)

	Wraith.Characters[Character.Name].State = "Cloaking"
	if IsStart then
	else
		Wraith.Characters[Character.Name].AnimationTrack:Play(nil, nil, Wraith.Characters[Character.Name].AnimationSpeeds.Cloak)
	end

	SetTransparency(Character, 1)

	local timestamp = workspace:GetServerTimeNow()
	coroutine.wrap(function()

		for order, tweentbl in pairs(Wraith.Characters[Character.Name].Tweens.Cloak) do

			for _, tween in pairs(tweentbl) do
				tween:Play()
			end
		end

		repeat task.wait()
		until (workspace:GetServerTimeNow() - timestamp) > Cloak_Time or Wraith.Characters[Character.Name].State == "Cancel" or IsStart

		if Wraith.Characters[Character.Name].State == "Cloaking" or IsStart then
			if IsStart then
				for order, tweentbl in pairs(Wraith.Characters[Character.Name].Tweens.Cloak) do

					for _, tween in pairs(tweentbl) do
						tween:Pause()
					end
				end
				SetCloth(Character, false)

				if Data_Module:GetAddon("Killer", game.Players:GetPlayerFromCharacter(Character), "True Ghost") then
					SetProperties(Character, 1, "Black", Enum.Material.Glass)
				else
					SetProperties(Character, 0.93, "Black", Enum.Material.Glass)
				end

				Wraith.Characters[Character.Name].Weapon.Bell:WaitForChild('State').Value = "Invisible"
			else
				SetCloth(Character, false)

				if Data_Module:GetAddon("Killer", game.Players:GetPlayerFromCharacter(Character), "True Ghost") then
					SetProperties(Character, 1, "Black", Enum.Material.Glass)
				else
					SetProperties(Character, 0.93, "Black", Enum.Material.Glass)
				end

				Wraith.Characters[Character.Name].Weapon.Bell:WaitForChild('State').Value = "Invisible"
			end
		elseif Wraith.Characters[Character.Name].State == "Force_Uncloaking" then
			-- do nothing
		else
			Wraith.Characters[Character.Name].Cancel:Fire()
			Wraith.Characters[Character.Name].AnimationTrack:Stop()
			SetTransparency(Character, 0)
			SetProperties(Character, 0, "Normal", Enum.Material.SmoothPlastic)
			SetCloth(Character, true)
			Wraith.Characters[Character.Name].Weapon.Bell:WaitForChild('State').Value = "Visible"
		end
	end)()

	return timestamp, Cloak_Time
end

function Wraith:Uncloak(Character) : "Does uncloaking Animation"
	if not Wraith.Characters[Character.Name] then GenerateData(Character) end
	local Uncloak_Time = Wraith.Characters[Character.Name].AnimationLength * (1/Wraith.Characters[Character.Name].AnimationSpeeds.Uncloak)

	Wraith.Characters[Character.Name].State = "Uncloaking"

	Wraith.Characters[Character.Name].AnimationTrack:Play(nil, nil, Wraith.Characters[Character.Name].AnimationSpeeds.Uncloak)

	local timestamp = workspace:GetServerTimeNow()
	coroutine.wrap(function()
		--[[ player transition tweens
		animation.TimePosition > ((animation.Length/#bodyParts) * index) then -- OLD CODE FOR TWEENING PARTS IN ORDER
		]]

		if Data_Module:GetAddon("Killer", game.Players:GetPlayerFromCharacter(Character), "True Ghost") then
			SetProperties(Character, 1, "Black", Enum.Material.Glass)
		else
			SetProperties(Character, 0.93, "Black", Enum.Material.Glass)
		end

		for order, tweentbl in pairs(Wraith.Characters[Character.Name].Tweens.Uncloak) do

			for _, tween in pairs(tweentbl) do
				tween:Play()
			end
		end

		repeat task.wait()
		until (workspace:GetServerTimeNow() - timestamp) > Uncloak_Time or Wraith.Characters[Character.Name].State == "Force_Uncloaking" or Wraith.Characters[Character.Name].State == "Cancel"

		if Wraith.Characters[Character.Name].State == "Uncloaking" then
			task.spawn(function()
				if Wraith.Characters[Character.Name].Stunned then
					Wraith.Characters[Character.Name].Stunned:Disconnect()
				end
				
				if Wraith.Characters[Character.Name].Carrying then
					Wraith.Characters[Character.Name].Carrying:Disconnect()
				end
			end)
			SetTransparency(Character, 0)
			SetProperties(Character, 0, "Normal", Enum.Material.SmoothPlastic)
			SetCloth(Character, true)
			Wraith.Characters[Character.Name].Weapon.Bell:WaitForChild('State').Value = "Visible"
		elseif Wraith.Characters[Character.Name].State == "Force_Uncloaking" then
			-- do nothing
		else
			Wraith.Characters[Character.Name].Cancel:Fire()
			Wraith.Characters[Character.Name].AnimationTrack:Stop()

			if Data_Module:GetAddon("Killer", game.Players:GetPlayerFromCharacter(Character), "True Ghost") then
				SetProperties(Character, 1, "Black", Enum.Material.Glass)
			else
				SetProperties(Character, 0.93, "Black", Enum.Material.Glass)
			end

			Wraith.Characters[Character.Name].Weapon.Bell:WaitForChild('State').Value = "Invisible"
		end
	end)()

	return timestamp, Uncloak_Time
end

function Wraith:ForceUncloak(Character, Cause: string) : "Forces the uncloak for stun / no animation will play besides tweens"
	if not Wraith.Characters[Character.Name] then GenerateData(Character) end

	local AnimationTween = "Uncloak"

	if (Cause == "Serpent") then
		AnimationTween = "Serpent"
	end

	local Uncloak_Time = Wraith.Characters[Character.Name].AnimationLength * (1/Wraith.Characters[Character.Name].AnimationSpeeds[AnimationTween])
	task.spawn(function()
		if Wraith.Characters[Character.Name].Stunned then
			Wraith.Characters[Character.Name].Stunned:Disconnect()
		end

		if Wraith.Characters[Character.Name].Carrying then
			Wraith.Characters[Character.Name].Carrying:Disconnect()
		end
	end)

	-- if was doing something cancel it --
	Wraith.Characters[Character.Name].Cancel:Fire()
	Wraith.Characters[Character.Name].AnimationTrack:Stop()

	Wraith.Characters[Character.Name].State = "Force_Uncloaking"

	local timestamp = workspace:GetServerTimeNow()
	coroutine.wrap(function()

		if Data_Module:GetAddon("Killer", game.Players:GetPlayerFromCharacter(Character), "True Ghost") then
			SetProperties(Character, 1, "Black", Enum.Material.Glass)
		else
			SetProperties(Character, 0.93, "Black", Enum.Material.Glass)
		end

		for order, tweentbl in pairs(Wraith.Characters[Character.Name].Tweens[AnimationTween]) do

			for _, tween in pairs(tweentbl) do
				tween:Play()
			end
		end

		repeat task.wait()
		until (workspace:GetServerTimeNow() - timestamp) > Uncloak_Time

		if Wraith.Characters[Character.Name].State == "Force_Uncloaking" then
			SetTransparency(Character, 0)
			SetProperties(Character, 0, "Normal", Enum.Material.SmoothPlastic)
			SetCloth(Character, true)
			Wraith.Characters[Character.Name].Weapon.Bell:WaitForChild('State').Value = "Visible"

			if Cause == "Serpent" then -- band-aid fix ig
				Character.Humanoid.WalkSpeed = require(game.ReplicatedStorage.Modules:WaitForChild('Code')):GetSpeed('Movement', game.Players:WaitForChild(Character.Name))
			end
		end
	end)()

	return timestamp, Uncloak_Time
end


function Wraith:Cancel(Character)
	if not Wraith.Characters[Character.Name] then
		repeat task.wait()
		until Wraith.Characters[Character.Name]
	end

	if Wraith.Characters[Character.Name].State == "Force_Uncloaking" then return end

	Wraith.Characters[Character.Name].State = "Cancel"

	if Character:GetAttribute("Cloaked") then
		Wraith.Characters[Character.Name].Cancel:Fire()
		Wraith.Characters[Character.Name].AnimationTrack:Stop()
		if Data_Module:GetAddon("Killer", game.Players:GetPlayerFromCharacter(Character), "True Ghost") then
			SetProperties(Character, 1, "Black", Enum.Material.Glass)
		else
			SetProperties(Character, 0.93, "Black", Enum.Material.Glass)
		end
	else
		SetTransparency(Character, 0)
		SetProperties(Character, 0, "Normal", Enum.Material.SmoothPlastic)
		SetCloth(Character, true)
	end
end

return Wraith