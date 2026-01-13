--!nocheck
--!nolint

local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Player = game.Players.LocalPlayer
local Detection = {
	LagCompensation = {
		Distance = 20; -- distance where it will outright deny hits | tested at 50 ms on full compensation was between 4 and 7
		CompensationFactor = .1; -- 1 is full lag compensation / will completely punish for bad ping
	}
}

local function Raycast(Part,PartTo, Survivor)
	local TableCharacter = {Part.Parent}
	local BrickTouched, ray = workspace:FindPartOnRayWithIgnoreList(Ray.new(Part.CFrame.p,PartTo.CFrame.p - Part.CFrame.p),TableCharacter, false, true)
	if BrickTouched then else return false end
	if (BrickTouched.CanTouch) and not BrickTouched:IsDescendantOf(Survivor) then return true else return false end
end

--
function GetBreakable(Object : BasePart) : Instance | nil

	if string.match(string.lower(Object.Parent.Name), "pallet") or string.match(string.lower(Object.Parent.Name), "breakablewall") then
		return Object.Parent
	elseif string.match(string.lower(Object.Parent.Parent.Name), "pallet") or string.match(string.lower(Object.Parent.Parent.Name), "breakablewall") then
		return Object.Parent.Parent
	end

	return nil
end

function IsBreakable(Object : BasePart) : boolean
	local source_breakable = GetBreakable(Object)

	local function Valid(parent)

		if string.match(string.lower(parent.Name), "pallet") then
			return (parent.Panel.State.Value == 1) -- will return true if state is in 1
		elseif string.match(string.lower(parent.Name), "breakablewall") then
			return (not parent.Panel.Broken.Value) -- will return true if not broken
		end
	end

	if source_breakable then
		return Valid(source_breakable)
	end

	return false
end

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

	local ray = workspace:Spherecast((Player.Character:GetPivot() * CFrame.new(0, 0, Hitbox_Settings.Radius)).Position, Hitbox_Settings.Radius, Player.Character:GetPivot().LookVector * (Hitbox_Settings.Range + Hitbox_Settings.Radius), raycastParam)

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
		i.Shape = Enum.PartType.Ball
		i.Size = Vector3.new(Hitbox_Settings.Radius * 2, Hitbox_Settings.Radius * 2, Hitbox_Settings.Radius * 2)
		i.Transparency = .5
		i.CanCollide = false
		i.Position = raycast.Position

		game:GetService('Debris'):AddItem(i, 1)
	end

	if IsPlayer(raycast.Instance) then
		local lagCompensation : number = game.Players.LocalPlayer:GetAttribute("PING")/10000
		local distance : number = (game.Players.LocalPlayer.Character:WaitForChild('HumanoidRootPart').Position - (raycast.Position + ((Detection.LagCompensation.CompensationFactor * lagCompensation) * (Vector3.new(1, 0, 1) * raycast.Instance.Velocity)))).Magnitude
		local Survivor = game:GetService('Players'):WaitForChild(GetPlayer(raycast.Instance).Name)
		local Health = Survivor:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState')
		local AFrame = Code_Module:GetEffect("AFrame", Survivor)
		local IFrame = Code_Module:GetEffect("IFrame", Survivor)

		if Health.Value <= 0 then
			return "Ignore", GetPlayer(raycast.Instance)
		elseif (distance > Detection.LagCompensation.Distance) or (IFrame and IFrame.Active) or (AFrame and AFrame.Active) then
			return nil
		elseif Raycast(game.Players.LocalPlayer.Character:WaitForChild('HumanoidRootPart'),raycast.Instance,Survivor) == true then
			return "Wall In Between"
		end

		return 'Player', GetPlayer(raycast.Instance)
	elseif IsBreakable(raycast.Instance) then
		return 'Breakable', GetBreakable(raycast.Instance)
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