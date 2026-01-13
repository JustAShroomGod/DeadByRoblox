local Players, ReplicatedStorage, ServerScriptService = game:GetService('Players'), game:GetService('ReplicatedStorage'), game:GetService('ServerScriptService')
local RunService, TweenService = game:GetService('RunService'), game:GetService('TweenService')

local RemoteStorage : Folder = ReplicatedStorage:WaitForChild('RemoteEvents')
local ModuleStorage : Folder = ReplicatedStorage:WaitForChild('Modules')

local Settings = {
	Speeds = {
		Base = 17;
		Uncloak = 1.5;
		Invisible = 1.3;
	},
	Transparency = {
		Invisible = 0.9;
	},
	AnimationModifiers = {
		Cloak = 1;
		Uncloak = .7;
	},
	Addons = {
		WindStormMud = {
			Type = "Speed";
			Value = 0.03;
		},
		WindStormWhite = {
			Type = "Speed";
			Value = 0.06;
		},
		WindStormBlood = {
			Type = "Speed";
			Value = 0.09;
		},
		Serpent = {
			Type = "Uncloak";
			Value = 0.0;
			RefreshValue = 0.65;
		},
	}
}

local Modules = {
	Events = require(ServerScriptService:WaitForChild('Event System'):WaitForChild('Events'));
	Data = require(ModuleStorage:WaitForChild('Data'));
}

local Remotes = {
	
}

local inRecovery : boolean = game.ServerStorage:WaitForChild('SharedKiller'):WaitForChild('AttackAction'):WaitForChild('inRecovery') -- outdated and not used anymore
local Bell = script.Parent
local Bell_Part = Bell:WaitForChild('Handle')

-- grab character + player --
local Character, Player
repeat task.wait(.35)
	Character = script.Parent.Parent
	Player = Players:FindFirstChild(Character.Name)
until Player
-- grab character + player --

local Killer_Pack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
local Killer_Perks = Killer_Pack:WaitForChild('PerksBase')
local Killer_Values = Killer_Pack:WaitForChild('values')

local BodyColors = Character:FindFirstChild("Body Colors")

local Connections = {}
local Tweens = {}

local Clothing = {
	Shirt = {
		Source = nil;
		Id = nil;
	},
	Pants = {
		Source = nil;
		Id = nil;
	},
}

function UpdateCloths() : "Update Clothing Table"
	
	for _, object : Instance in pairs(Character:GetChildren()) do
		
		if object.Name == "Shirt" then
			Clothing.Shirt.Source = object
			Clothing.Shirt.Id = object.ShirtTemplate
		elseif object.Name == "Pants" then
			Clothing.Pants.Source = object
			Clothing.Pants.Id = object.PantsTemplate
		end
	end
end

Character.ChildAdded:Connect(function()
	UpdateCloths()
end)

UpdateCloths()


local bellsOnAnim = script:WaitForChild('BellOn')
local bellsOnAnimTrack = Character:WaitForChild("Humanoid"):LoadAnimation(bellsOnAnim)

local state = script.Parent:WaitForChild("State")
local turningOn = script.Parent:WaitForChild("TurningOn")

local weapon = Character:WaitForChild("Wraith")
local weaponH = weapon:WaitForChild("Handle")

local invisibleTransparency = script.Parent:GetAttribute("invisibleTransparency")
local invisibleSpeedIncrease = script.Parent:GetAttribute("invisibleSpeedIncrease")
local cloakSpeed = script.Parent:GetAttribute("cloakSpeed")
local uncloakSpeed = script.Parent:GetAttribute("uncloakSpeed")
local dashSpeedIncrease = script.Parent:GetAttribute("dashSpeedIncrease")
local initialWeaponMaterial = weapon:WaitForChild("Handle").Material
local initialWeaponColor = weapon:WaitForChild("Handle").Color
local initialUsePartColor = weapon:WaitForChild("Handle").UsePartColor


local dashActive = false
local burn = false

local partsOrderToVisible = {
	{"RightFoot", "LeftFoot"},
	{"RightLowerLeg", "LeftLowerLeg"},
	{"RightUpperLeg", "LeftUpperLeg"},
	"LowerTorso",
	"UpperTorso",
	{"RightUpperArm", "LeftUpperArm"},
	{"RightLowerArm", "LeftLowerArm"},
	{"RightHand", "LeftHand"},
	"Head"
}
local partsOrderToInvisible = {
	"Head",
	{"RightHand","LeftHand"},
	{"RightLowerArm", "LeftLowerArm"},
	{"RightUpperArm","LeftUpperArm"},
	"UpperTorso",
	"LowerTorso",
	{"RightUpperLeg", "LeftUpperLeg"},
	{"RightLowerLeg","LeftLowerLeg"},
	{"RightFoot", "LeftFoot"}
}

local cancelActions = {"BreakingPallet", "WeaponAttack", "WindowVault"}

local bodyColorParts = {"Head","LeftArm", "RightArm", "LeftLeg", "RightLeg", "Torso"}

--

function PlaySound(id : number, volume : number, pitch : number) : "Play Sound"
	local Sound = Instance.new('Sound', Bell_Part)
	Sound.PlayOnRemove = true
	Sound.Volume = if volume then volume else 1
	Sound.SoundId = "http://www.roblox.com/Asset?ID="..tostring(id)
	Sound:Remove()
end

function playSoundEffect(name : string) : "Plays sound based on cue"
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

function Burn(kind : "Stun" | "Flashlight") : "Burn Wraith"
	if kind ~= "Stun" and kind ~= "Flashlight" then return end
	
	if state.Value == "Invisible" then
		burn = true
		turningOn.Value = true
	else
		turningOn.Value = false
	end
end

function getPowerValues() : "Return Values"
	local Addon = Modules.Data:GetAddons("Killer", Player)

	local Speeds = {
		Invisible = Settings.Speeds.Base * Settings.Speeds.Invisible;
		Dash = Settings.Speeds.Base * Settings.Speeds.Uncloak;
		Cloak = Settings.AnimationModifiers.Cloak;
		Uncloak = Settings.AnimationModifiers.Uncloak;
	}

	if Settings.Addons[Addon] then -- addon exists
		local UpgradeType = Settings.Addons[Addon].Type

		if UpgradeType == "Speed" then
			Speeds.Invisible = Settings.Speeds.Base * (Settings.Speeds.Invisible + UpgradeType.Value)
		elseif UpgradeType == "Dash" then
			Speeds.Dash = Settings.Speeds.Base * (Settings.Speeds.Uncloak + UpgradeType.Value)
		elseif UpgradeType == "Cloak" then
			Speeds.Cloak = Settings.AnimationModifiers.Cloak + (Settings.AnimationModifiers.Uncloak * UpgradeType.Value)
		elseif UpgradeType == "Uncloak" then
			Speeds.Uncloak = Settings.AnimationModifiers.Uncloak + (Settings.AnimationModifiers.Uncloak * UpgradeType.Value)
		end
	end

	return Speeds
end
--


function disconnectAction()
	if bellsOnAnimTrack ~= nil then
		bellsOnAnimTrack:Stop()

		if state.Value == "Invisible" then
			dashActive = false 
			state.Value = "Visible"
		end

		return
	else 
		dashActive = false 
		return
	end
end


local bellTween
local weaponTween

-- Assemble partodertovisible with indexes set to nil in partsTweens--
local partsTweens = {}
for _, bodyParts in pairs(partsOrderToVisible) do
	
	if type(bodyParts) == "table" then
		
		for _, bodypart in pairs(bodyParts) do
			table.insert(partsTweens, {[bodypart] = {nil}})
		end
	else
		table.insert(partsTweens, {[bodyParts] = {nil}})
	end
end

function getBodyColor(name)
	local side, partIndex, returnString

	if string.match(string.lower(name),"left",1) then
		side = "Left"
	end

	if string.match(string.lower(name),"right",1) then
		side = "Right"
	end

	if side then
		if string.match(string.lower(name),"arm",1) then
			partIndex = "Arm" else partIndex = "Leg"
		end
	else
		if string.match(string.lower(name), "torso", 1) then
			partIndex = "Torso" 
		else 
			partIndex = "Head"
		end
	end

	if side == nil then
		side = ""
	end

	returnString = side.. partIndex
	return returnString 
end


bellsOnAnimTrack.KeyframeReached:Connect(playSoundEffect)

turningOn.Changed:Connect(function() -- value initated
	warn("GOT HERE")
	
	local weaponHandle = weapon:FindFirstChild("Handle")
	local PowerValues = getPowerValues()
	
	if turningOn.Value then -- turning on toggled to true
		warn("true! : main")
		
		if burn then
			bellsOnAnimTrack:Play(nil, nil, 4)
			burn = false
		else
			bellsOnAnimTrack:Play(nil, nil, 1)
		end
		
		Connections.Run = RunService.Heartbeat:Connect(function()
			local Head = Character:FindFirstChild("Head")
			local partsOrderTo, toTransparency, toColor

			if Head then
				local face = Head:FindFirstChild("face")
				
				if face then
					face.Transparency = 1
				end
			end


			if state.Value == "Visible" then
				partsOrderTo = partsOrderToInvisible
				toTransparency = invisibleTransparency
				bellsOnAnimTrack:AdjustSpeed(0.7)
			else
				partsOrderTo = partsOrderToVisible
				toTransparency = 0
				toColor = Color3.fromRGB(255, 80, 0)
			end
			
			local function CreateTween(Part : BasePart) : "Create and play the tween"
				local tweenTable
				
				Part.Material = Enum.Material.Neon
				
				for _, partTweenContainer in pairs(partsTweens) do
					
					for partName, partTween in pairs(partTweenContainer) do
						
						if partName == Part.Name then
							tweenTable = partTween
						end
					end
				end
				
				if tweenTable then
					local goal = {}
					local tween = tweenTable[1]

					if tween then tween:Cancel() tween = nil end
					
					if toColor then
						goal.Color = toColor
					end
					
					if Part.Name == "Head" then

						if toTransparency == invisibleTransparency then
							goal.Transparency = 1
						else
							goal.Transparency = toTransparency
						end
					else
						goal.Transparency = toTransparency
					end

					tween = TweenService:Create(Part, TweenInfo.new(bellsOnAnimTrack.Speed), goal)
					tween:Play()
				end
			end
			
			for index, partTable in pairs(partsOrderTo) do
				
				if bellsOnAnimTrack.TimePosition > ((bellsOnAnimTrack.Length/(#partsOrderToVisible)) * index) then
					
					if type(partTable) == "table" then
						
						for _, partName in pairs(partTable) do
							local bodyPart = Character:FindFirstChild(partName)
							
							if bodyPart then
								CreateTween(bodyPart)
							end
						end
					else
						local bodyPart = Character:FindFirstChild(partTable)
						
						if bodyPart then
							CreateTween(bodyPart)
						end
					end
				end
			end

			if Bell_Part and weaponHandle then
				local thisLimit

				if toColor then 
					thisLimit = bellsOnAnimTrack.Length/1.2
				else
					thisLimit = bellsOnAnimTrack.Length/3
				end

				if bellsOnAnimTrack.TimePosition > thisLimit then
					local goal = {}
					
					Bell_Part.Material = Enum.Material.Neon
					Bell_Part.UsePartColor = true
					
					goal.Transparency = toTransparency

					if toColor then
						goal.Color = toColor
					end

					local bellTween = TweenService:Create(Bell_Part, TweenInfo.new(0.4),goal)
					bellTween:Play()

					weaponHandle.Material = Enum.Material.Neon
					weaponHandle.UsePartColor = true

					local goal = {}
					goal.Transparency = toTransparency

					if toColor then 
						goal.Color = toColor
					end

					local weaponTween = TweenService:Create(weaponHandle, TweenInfo.new(0.4),goal)
					weaponTween:Play()
				else
					if toTransparency > 0.9 then
						Bell_Part.Transparency = 0
					end
				end
			end

			if state.Value == "Visible" then
				bellsOnAnimTrack:AdjustSpeed(PowerValues.Cloak)--0.98
			else	
				bellsOnAnimTrack:AdjustSpeed(PowerValues.Uncloak)--0.675
				
				local tween = TweenService:Create(Character:WaitForChild("Humanoid"),TweenInfo.new(0.4), {WalkSpeed = 8})
				tween:Play()

				Killer_Values.KillerAction.Changed:Connect(function()
					if Killer_Values.KillerAction.Value == "WeaponAttack" then
						if tween then
							tween:Cancel()
						end
					end
				end)
			end

			if bellsOnAnimTrack.TimePosition >= bellsOnAnimTrack.Length and bellsOnAnimTrack.Length ~= 0 then
				
				if state.Value == "Visible" then
					state.Value = "Invisible"

					if Clothing.Shirt then
						Clothing.Shirt.ShirtTemplate = ""
					end

					if Clothing.Pants then
						Clothing.Pants.PantsTemplate = ""
					end
					
					for index, partTable in pairs(partsOrderToVisible) do
						
						if type(partTable) == "table" then
							
							for _, partName in pairs(partTable) do -- index2 = v1
								local bodyPart = Character:FindFirstChild(partName)
								
								if bodyPart then
									CreateTween(bodyPart)
								end
							end
						else
							local bodyPart = Character:FindFirstChild(partTable)
							
							if bodyPart then
								CreateTween(bodyPart)
							end
						end
					end
					
					local bellTween = TweenService:Create(Bell_Part, TweenInfo.new(0.4), {Transparency = 1})
					bellTween:Play()
					Bell_Part.Material = Enum.Material.SmoothPlastic
					Bell_Part.UsePartColor = true

					local weaponTween = TweenService:Create(weaponHandle, TweenInfo.new(0.4), {Transparency = 1})
					weaponTween:Play()
					weaponHandle.Material = Enum.Material.SmoothPlastic
					weaponHandle.UsePartColor = true
					
					playSoundEffect("Transition")
					playSoundEffect("TurnedInvisible")
					
					if Character:WaitForChild("Humanoid").WalkSpeed > 0
						and workspace.CurrentCamera.CameraType ~= Enum.CameraType.Scriptable then
						
						Character:WaitForChild("Humanoid").WalkSpeed = PowerValues.Invisible
					end

					turningOn.Value = false
					
					if Connections.Run then Connections.Run:Disconnect() Connections.Run = nil end
					return
				else
					if Connections.Run then Connections.Run:Disconnect() Connections.Run = nil end
					
					playSoundEffect("Transition")
					playSoundEffect("TurnedVisible")

					local head = Character:FindFirstChild("Head")
					
					if head then
						local face = head:FindFirstChild("face")
						
						if face then
							face.Transparency = 0
						end
					end

					if Clothing.Shirt then
						Clothing.Shirt.ShirtTemplate = Clothing.Shirt.Id
					end

					if Clothing.Pants then
						Clothing.Pants.PantsTemplate = Clothing.Pants.Id
					end
					

					local function CreateTween2(Part : BasePart, Shift : boolean) : "Create and play the tween"
						local tweenTable

						Part.Material = Enum.Material.SmoothPlastic

						for _, partTweenContainer in pairs(partsTweens) do

							for partName, partTween in pairs(partTweenContainer) do

								if partName == Part.Name then
									tweenTable = partTween
								end
							end
						end

						if tweenTable then
							local goal = {}
							local tween = tweenTable[1]

							if tween then tween:Cancel() tween = nil end

							if toColor then
								goal.Color = toColor
							end
							
							if Shift then
								goal.Color = Color3.fromRGB(0, 0, 0)
								goal.Transparency = invisibleTransparency
							elseif Part.Name == "Head" then

								if toTransparency == invisibleTransparency then
									goal.Transparency = 1
								else
									goal.Transparency = toTransparency
								end
							else
								goal.Transparency = toTransparency
							end

							tween = TweenService:Create(Part, TweenInfo.new(0.4), goal)
							tween:Play()
						end
					end
					
					for index, partTable in pairs(partsOrderToVisible) do
						if type(partTable) == "table" then
							
							for _, partName in pairs(partTable) do
								local bodyPart = Character:FindFirstChild(partName)
								
								if bodyPart then
									CreateTween2(bodyPart)
								end
							end
						else
							local bodyPart = Character:FindFirstChild(partTable)
							
							if bodyPart then
								CreateTween2(bodyPart)
							end
						end
					end

					if BodyColors then
						
						for _, Table in pairs(partsTweens) do
							for bodyPart, partData in pairs(Table) do
								local bodyColorIndex = getBodyColor(bodyPart)
								local bodyPart = Character:FindFirstChild(bodyPart)
								local thisBodyColor
								
								if bodyPart then
									
									if bodyColorIndex then
										local bodyColor = BodyColors[bodyColorIndex.. "Color3"]
										thisBodyColor = bodyColor
									end
									
									if partData then
										local tween = partData[1]

										if tween then tween:Cancel() tween = nil end

										local goal = {}
										goal.Color = thisBodyColor
										goal.Transparency = 0

										tween = TweenService:Create(bodyPart, TweenInfo.new(0.4), goal)
										tween:Play()
									end
								end
							end
						end
					end


					local bellTween = TweenService:Create(Bell_Part, TweenInfo.new(0.4), {Transparency = 1})
					bellTween:Play()
					Bell_Part.Material = Enum.Material.SmoothPlastic
					Bell_Part.UsePartColor = false

					local weaponTween = TweenService:Create(weaponHandle, TweenInfo.new(0.4), {Transparency = 0})
					weaponTween:Play()
					weaponHandle.Material = initialWeaponMaterial
					weaponHandle.UsePartColor = initialUsePartColor
					weaponHandle.Color = initialWeaponColor


					if Character:WaitForChild("Humanoid").WalkSpeed > 0
						and workspace.CurrentCamera.CameraType ~= Enum.CameraType.Scriptable then
						
						Character:WaitForChild("Humanoid").WalkSpeed = PowerValues.Dash

						local speedgoal = {}
						speedgoal.WalkSpeed = PowerValues.Dash
						
						Settings.Addons.Serpent.Value = 0

						local tween = TweenService:Create(Character:WaitForChild("Humanoid"),TweenInfo.new(1.25),speedgoal)
						
						if (not table.find(cancelActions, Killer_Values.KillerAction.Value) and not inRecovery.Value) then
							dashActive = true
							tween:Play()
						else
							if tween then tween:Cancel() end
						end

						Killer_Values.KillerAction.Changed:Connect(function()
							if Killer_Values.KillerAction.Value == "WeaponAttack" then
								if tween then
									tween:Cancel()
								end
							end
						end)

						tween.Completed:Connect(function()
							if Character:WaitForChild("Humanoid").WalkSpeed > 0 
								and workspace.CurrentCamera.CameraType ~= Enum.CameraType.Scriptable then
								local lastSpeed = Character:WaitForChild("Humanoid").WalkSpeed

								dashActive = false 
								Character:WaitForChild("Humanoid").WalkSpeed = Settings.Speeds.Base
								tween = nil
							end
						end)
					end

					state.Value = "Visible"
					turningOn.Value = false
					
					if bellsOnAnimTrack then
						bellsOnAnimTrack:Stop()
					end
					
					return
				end
			end
		end)
	else -- turning on is false
		if Connections.Run then Connections.Run:Disconnect() Connections.Run = nil end
 
		if BodyColors then
			
			for _, Table in pairs(partsTweens) do
				
				for BodyPart, partData in pairs(Table) do
					local bodyColorIndex = getBodyColor(BodyPart)
					local bodyPart = Character:FindFirstChild(BodyPart)
					local thisBodyColor
					
					if bodyPart then
						if bodyColorIndex then
							local bodyColor = BodyColors[bodyColorIndex.. "Color3"]
							thisBodyColor = bodyColor
						end

						if partData then
							local tween = partData[1]

							if tween then tween:Cancel() tween = nil end

							local goal = {}
							if state.Value == "Invisible" then
								
								if bodyPart.Name == "Head" then
									goal.Transparency = 1 
									goal.Color = Color3.fromRGB(0,0,0)
									bodyPart.Material = "SmoothPlastic"
								else
									goal.Transparency = invisibleTransparency
									goal.Color = Color3.fromRGB(0,0,0)
									bodyPart.Material = "SmoothPlastic"
								end
							else
								goal.Transparency = 0
								goal.Color = thisBodyColor
								bodyPart.Material = "SmoothPlastic"
							end

							tween = TweenService:Create(bodyPart, TweenInfo.new(0.4), goal)
							tween:Play()
						end
					end
				end
			end
		end
	end
end)



--

function updateTransparency(transparency : number) : "Converts Transparency of parts"

	for _, child in pairs(Character:GetDescendants()) do
		if child.Parent.Name == "RedStain" or child.Name == "Hitbox"
			or child.Name == "HumanoidRootPart" or child.Name == "Flash_Zone" then
			continue -- skip this
		end

		local isBasePart : boolean = false

		for _, this in pairs (partsOrderToVisible) do
			if child.Name == this then
				isBasePart = true
				break
			end
		end

		if child.Parent.Parent.Name ~= "Blanket" and not isBasePart then

			if child.ClassName == "Part"
				or child.ClassName == "UnionOperation"
				or child.ClassName == "MeshPart" then

				child.Transparency = transparency
			elseif child.ClassName == "Beam" then
				child.Transparency = NumberSequence.new(transparency)
			end
		end
	end
end

state.Changed:Connect(function()

	if string.Value == "Visible" then

		for _, part in pairs(Character:GetChildren()) do

			if part.ClassName == "Accessory" then
				local Handle = part:FindFirstChild("Handle")

				if Handle then

					if part.Name ~= "RedStain" then
						Handle.Transparency = 0
					else

						for _, RedStain in pairs(Handle:GetChildren()) do

							if RedStain.ClassName == "UnionOperation" then
								RedStain.Transparency = .86
							end
						end
					end
				end
			end
		end

		return -- done
	else
		updateTransparency(1)
		turningOn.Value = false
	end
end)

turningOn.Changed:Connect(function()

	if turningOn.Value then
		updateTransparency(1)
	else
		updateTransparency(if state.Value == "Visible" then 0 else 1)
	end
end)

Killer_Values:WaitForChild('Stunned').Changed:Connect(function()
	
	if Killer_Values.Stunned.Value then
		Burn("Stun")
	end
end)

-- Verox's Stuff --

Modules.Events.Server.Heartbeat.Event:Connect(function()
	local Rigged_Character = workspace.RigStorage:FindFirstChild(Player.Name)

	if Rigged_Character then

		for _, part in pairs(Rigged_Character:GetDescendants()) do

			if part:IsA('Decal') then
				part.Transparency = if state.Value == "Visible" then 0 else 1
			end
		end
	end

	for _, part in pairs(Character:GetDescendants()) do

		if part:IsA('Decal') then
			part.Transparency = if state.Value == "Visible" then 0 else 1
		end
	end
end)

Modules.Events.Killer.onBreak.Event:Connect(function()
	local Addon = Modules.Data:GetAddons("Killer", Player)
	
	if Addon == "Serpent" then
		Settings.Addons.Serpent.Value = Settings.Addons.Serpent.RefreshValue
		turningOn.Value = true
	end
end)