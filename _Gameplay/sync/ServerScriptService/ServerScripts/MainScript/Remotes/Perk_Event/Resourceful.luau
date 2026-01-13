local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Resourceful'))

local module = {
	SavedData = {}
}

local Range = 15

function CraftData(Character : Model)
	if module.SavedData[Character.Name] then return end
	
	module.SavedData[Character.Name] = {}
	module.SavedData[Character.Name].Animations = {
		Craft = Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(script:WaitForChild('Animation'):WaitForChild('Rebuild'));
	}
	module.SavedData[Character.Name].State = "Nothing"
	module.SavedData[Character.Name].Hammer = nil
	
	local function PlaySound(sound) : "play sound from root part"
		local s = sound:Clone()
		s.Parent = Character:WaitForChild('HumanoidRootPart')
		s:Remove()
	end
	
	local function RemoveHammer() : "No 2 hammers at same time"
		if not module.SavedData[Character.Name].Hammer then return end
		module.SavedData[Character.Name].Hammer:Remove()
		module.SavedData[Character.Name].Hammer = nil
	end
	
	module.SavedData[Character.Name].Animations.Craft.KeyframeReached:Connect(function(frame)
		
		if frame == "Plank_Pull" then
			PlaySound(script:WaitForChild('Sounds'):WaitForChild('Plank'))
		elseif frame == "Hammer_Bang" then
			PlaySound(script:WaitForChild('Sounds'):WaitForChild('Hammer'))
		elseif frame == "Hammer_Pull" then
			RemoveHammer()
			
			module.SavedData[Character.Name].Hammer = script:WaitForChild('Model'):WaitForChild('Hammer'):Clone()
			module.SavedData[Character.Name].Hammer.Parent = Character
			
			local W = Instance.new('Weld', module.SavedData[Character.Name].Hammer)
			W.Part0 = Character:WaitForChild('RightHand')
			W.Part1 = module.SavedData[Character.Name].Hammer:WaitForChild('Grip')
			
			W.C0 *= module.SavedData[Character.Name].Hammer:GetAttribute("Offset")
		end
	end)
	
	module.SavedData[Character.Name].Animations.Craft.Stopped:Connect(function(frame)
		RemoveHammer()
	end)
end

function HideTool(Character : Model, Hide : boolean) : "Hides/Reveals Tools"
	local tool
	
	for _, part in pairs(Character:GetChildren()) do
		if not part:IsA('Model') then continue end
		
		if part:GetAttribute("Tool") then
			tool = part
			break
		end
	end
	
	if tool then
		
		for _, part in pairs(tool:GetDescendants()) do
			if not part:IsA('BasePart') then continue end
			if part.Name == "Cone" or part.Name == "LightStart" or part.Name == "Grip" then continue end
			
			part.Transparency = if Hide then 1 else 0
		end
	end
end

function module:Activate(player, ...)
	local args = {...}
	local HasPerk, PerkTier = Data_Module:GetPerk("Resourceful", player)

	print('remote activated by', player)
	
	if not HasPerk then return warn("They do not really have perk!") end
	if not module.SavedData[player.Character.Name] then CraftData(player.Character) end
	local Charges = player.Character:GetAttribute("Resourceful")
	local Pallet, Side = args[3], args[4]
	
	if not Charges then
		player.Character:SetAttribute("Resourceful", 0)
		Charges = player.Character:GetAttribute("Resourceful")
	end
	
	if not string.match(string.lower(Pallet.Name), 'pallet') then return warn("Not a real pallet prolly exploits") end
	if player:DistanceFromCharacter(Pallet:GetPivot().Position) > Range then return warn("Anti-Cheat for distance") end
	
	if args[2] and Pallet and (Pallet.Panel.State.Value == 2) and not Pallet:GetAttribute("Resource") then -- attempting to gain charge from args3
		print('want charge from', args[3])

		player.Character:SetAttribute("Resourceful", Charges + 1)
		Pallet:SetAttribute("Resource", true) -- deny using pallet 2x as a resource
	elseif not args[2] and Pallet and (Pallet.Panel.State.Value == 2) and args[4] and args[4].Parent == args[3] then -- attempting to use charges on arg3
		print('went to restore', args[3])
		
		local Connections = {}
		
		player.Character.Humanoid.WalkSpeed = 0
		player.Character.HumanoidRootPart.Anchored = true
		player.Backpack.Scripts.values.Action.Value = "Restore" -- doing restore action
		
		local tween = game:GetService("TweenService"):Create(player.Character.HumanoidRootPart, TweenInfo.new(1/10, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = args[4].CFrame * CFrame.new(0, 0.25, -.8)
		})
		tween:Play()
		tween.Completed:Wait()
		
		local Completed = false
		module.SavedData[player.Character.Name].State = "Building"
		
		HideTool(player.Character, true)
		module.SavedData[player.Character.Name].Animations.Craft:Play() -- does sounds and hammer anim automatically
		
		module.SavedData[player.Character.Name].Animations.Craft.Stopped:Once(function()
			Completed = true
		end)

		Connections.Hit = player.Character:GetAttributeChangedSignal("LastHit"):Connect(function(test)
			module.SavedData[player.Character.Name].State = "ATTACKED"
			Completed = true
		end)
		
		Connections.HealthState = player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState').Changed:Connect(function()
			module.SavedData[player.Character.Name].State = "ATTACKED"
			Completed = true
		end)
		
		repeat task.wait()
		until Completed
		
		HideTool(player.Character, false)
		
		if module.SavedData[player.Character.Name].State == "Building" then -- did the animation fully/successfully
			player.Character:SetAttribute("Resourceful", 0)
			Pallet.Panel.State.Value = 0 -- restore the pallet
			Pallet:SetAttribute("Resource", false) -- to allow for resource grabbing from this pallet again
		else
			if Connections.Hit then Connections.Hit:Disconnect() Connections.Hit = nil end
			if Connections.HealthState then Connections.HealthState:Disconnect() Connections.HealthState = nil end
			module.SavedData[player.Character.Name].Animations.Craft:Stop() -- stop animation early
		end
		
		player.Character.HumanoidRootPart.Anchored = false
		player.Backpack.Scripts.values.Action.Value = "Nothing" -- doing restore action
	end
end

return module
