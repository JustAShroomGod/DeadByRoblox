local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Detection = {}

--
function GetPlayer(Object : BasePart) : "Character"
	local Humanoid = Object.Parent:FindFirstChildOfClass("Humanoid")

	if not Humanoid then
		Humanoid = Object.Parent.Parent:FindFirstChildOfClass("Humanoid")
	end

	if Humanoid then
		return Humanoid.Parent
	end

	return nil
end

function IsPlayer(Object : BasePart) : boolean
	local Character = GetPlayer(Object)

	if Character and game.Players:FindFirstChild(Character.Name) then
		return true
	end

	return false
end

--

local raycastParam = RaycastParams.new()
raycastParam.FilterType = Enum.RaycastFilterType.Exclude

function Detection:Cast(exclusions, Hitbox_Settings) : "Cast Ray for Hammer Detection"
	raycastParam.FilterDescendantsInstances = exclusions
	
	local ray = workspace:Spherecast((Hitbox_Settings.Origin * CFrame.new(0, 0, Hitbox_Settings.Radius)).Position, Hitbox_Settings.Radius, Hitbox_Settings.Origin.LookVector * (Hitbox_Settings.Range + Hitbox_Settings.Radius), raycastParam)

	if ray then
		return ray
	end

	return nil
end

function Detection:Type(raycast : Instance, Hitbox_Settings, Testing)

	if Testing then
		local i = Instance.new('Part', workspace)
		i.Anchored = true
		i.CastShadow = false
		i.CanQuery = false
		i.Color = Color3.fromRGB(255, 0, 0)
		i.Shape = Enum.PartType.Ball
		i.Size = Vector3.new(Hitbox_Settings.Radius * 2, Hitbox_Settings.Radius * 2, Hitbox_Settings.Radius * 2)
		i.Transparency = .5
		i.CanCollide = false
		i.Position = raycast.Position
		
		game:GetService('Debris'):AddItem(i, 1)
	end
	
	if IsPlayer(raycast.Instance) then
		local Survivor = game:GetService('Players'):WaitForChild(GetPlayer(raycast.Instance).Name)
		local Health = Survivor:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState')
		local AFrame = Code_Module:GetEffect("AFrame", Survivor)
		
		if Health.Value <= 0 then
			return "Ignore", GetPlayer(raycast.Instance)
		elseif (AFrame and AFrame.Active) then
			return nil
		end

		return 'Player', GetPlayer(raycast.Instance)
	else
		
		
		if raycast.Instance.Transparency == 1 then
			--print(raycast.Instance)
			return "Ignore", raycast.Instance
		else
			return 'Object', raycast.Instance
		end
	end
end

return Detection
