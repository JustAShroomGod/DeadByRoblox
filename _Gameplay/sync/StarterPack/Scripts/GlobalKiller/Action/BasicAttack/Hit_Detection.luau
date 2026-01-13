local Players = game:GetService("Players")
local DebrisService = game:GetService("Debris")
local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(game.ReplicatedStorage.Modules:WaitForChild("Code"))
local Data = require(game.ReplicatedStorage.Modules:WaitForChild("Data"))
local Player = game.Players.LocalPlayer

local _Visualize = nil

local module = {}

local Detection = {
	LagCompensation = {
		Distance = 7.5; -- distance where it will outright deny hits | tested at 50 ms on full compensation was between 4 and 7
		CompensationFactor = 0.1; -- 1 is full lag compensation / will completely punish for bad ping
	}
}

function module.Cast(Settings)
	
	local ovparams = OverlapParams.new()
	ovparams.FilterType = Enum.RaycastFilterType.Exclude
	ovparams.FilterDescendantsInstances = {Player.Character}
	
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Player.Character}

	local cframe: CFrame = Player.Character.HumanoidRootPart.CFrame-- + (Player.Character.HumanoidRootPart.CFrame.LookVector * Settings.Hitboxes.Normal.Range)
	--local BoxCast = workspace:Blockcast(CFrame.new(cframe.Position - (cframe.LookVector * 1.75), (cframe.Position + (cframe.LookVector * 999))), Settings.Hitboxes.Normal.Size, (cframe.LookVector * Settings.Hitboxes.Normal.Range), params)
	local Bounds = workspace:GetPartBoundsInBox(CFrame.new(cframe.Position + (cframe.LookVector * 1.75), (cframe.Position + (cframe.LookVector * 999))), Settings.Hitboxes.Normal.Size, ovparams)
	local target = RetrieveFromList(Bounds)
	--local valid, target = ValidateResult(BoxCast)
	
	Visualize(cframe, false, Settings) --so you dont get confused if it got green and you didnt hit anyone
	
	if (target) then
		
		local directionBody = CFrame.new(Player.Character.Head.Position, target.Character.PrimaryPart.Position)
		local RaycastBody = workspace:Raycast(Player.Character.Head.Position, directionBody.LookVector.Unit * (Settings.Hitboxes.Normal.Range * 1.1), params)
		local validBody, targetBody = ValidateResult(RaycastBody)
		
		local directionHead = CFrame.new(Player.Character.Head.Position, target.Character.Head.Position)
		local RaycastHead = workspace:Raycast(Player.Character.Head.Position, directionHead.LookVector.Unit * (Settings.Hitboxes.Normal.Range * 1.1), params)
		local validHead, targetHead = ValidateResult(RaycastHead)
		
		local isATarget = ((targetBody == target) or (targetHead == target))
		local isEitherValid = ((validBody == true) or (validHead == true))
		
		--print("Body ", validBody, targetBody)
		--print("Head ", validHead, targetHead)
		
		--print("Validation ", isEitherValid, (validBody == true), (validHead == true))
		--print("Target ", isATarget, (targetBody == target), (targetHead == target))

		if (isATarget and isEitherValid and CanAttack(target)) then
			Visualize(cframe, true, Settings)
			return "Player", target
		end
		
		Visualize(directionBody, false, Settings)
		
		return "None", nil
	end
	
	return "None", nil
end

function RetrieveFromList(Bounds)
	
	local AllChars = {}

	for i, v in pairs(game.Teams.Survivor:GetPlayers()) do
		table.insert(AllChars, v.Character)
	end
	
	for index, obj in pairs(Bounds) do
		
		if (table.find(AllChars, obj.Parent) ~= nil) then
			return game.Players[obj.Parent.Name]
		end
	end
	
	return nil
end

function Visualize(_CFrame: CFrame, CastResult, Settings)
	
	if (_Visualize == nil) then
		local Settings = Data:GetSettings()
		
		if (Settings == nil) then
			return
		end
		
		_Visualize = Settings.VISUALIZE_ATTACKS
	end
	
	if (not _Visualize) then
		return
	end
	
	coroutine.wrap(function()

		local part = Instance.new("Part")
		part.Name = "HIT_RAY"
		part.Transparency = 0.75
		part.Parent = workspace

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false

		part.Material = Enum.Material.SmoothPlastic
		part.Color = if (CastResult) then Color3.new(0.121569, 0.654902, 0.0941176) else Color3.new(0.666667, 0, 0)
		part.Size = Settings.Hitboxes.Normal.Size
		part.CFrame = CFrame.new(_CFrame.Position + (_CFrame.LookVector * 1.75), (_CFrame.Position + (_CFrame.LookVector * 999)))
		task.wait(1)

		local tween = TweenService:Create(part, TweenInfo.new(2.5), {Transparency = 1})
		tween:Play()

		tween.Completed:Connect(function()
			part:Destroy()
		end)
	end)()
end

function CanAttack(Survivor: Player)
	
	if (Survivor.Team == game.Teams.Killer) then
		return
	end
	
	local Health = Survivor:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState')
	local AFrame = Code:GetEffect("AFrame", Survivor)
	local IFrame = Code:GetEffect("IFrame", Survivor)
	
	if Health.Value <= 0 then
		return false
	end
	
	if ((IFrame and IFrame.Active) or (AFrame and AFrame.Active)) then
		return false
	end
		
	return true
end

function ValidateResult(Result: RaycastResult)

	if (Result == nil) then
		return false, nil
	end

	local Character = Players:GetPlayerFromCharacter(Result.Instance.Parent)
	
	if (Character == nil) then
		if (Result.Instance.Transparency >= 1) then
			return false, nil
		end
	end

	return Character ~= nil, Character
end

return module
