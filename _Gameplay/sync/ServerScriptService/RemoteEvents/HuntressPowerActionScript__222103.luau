local ReplicatedStorage = game:GetService('ReplicatedStorage')
local remoteEvent = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Hatchet')

local hatchet_model = ReplicatedStorage:WaitForChild('KillerStuff'):WaitForChild('Current_Throw')

local data_module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))
local code_module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Code'))
local Game_Data = ReplicatedStorage:WaitForChild("Game_Data"):WaitForChild("Addons"):WaitForChild("Killer")

local MultiShot = require(Game_Data:WaitForChild("Multi-Shot"))

local CameraOffset = CFrame.new(0, 0, -3) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-90)) -- offset from camera when throwing

local HitboxSettings = {
	Size = Vector3.new(1.5, .35, 1);
	Offset = CFrame.new(0, 0, 0);
}

local function ReadCurrent(Hatchet : Model, Character)
	local CenterPoint = Hatchet.CFrame * HitboxSettings.Offset
	local FrontEnd = CenterPoint.Position + Vector3.new(HitboxSettings.Size.X/2, HitboxSettings.Size.Y/2, HitboxSettings.Size.Z/2)
	local BackEnd =  CenterPoint.Position + (Vector3.new(HitboxSettings.Size.X/2, HitboxSettings.Size.Y/2, HitboxSettings.Size.Z/2) * -1)

	local GeneratedRegion = Region3.new(BackEnd, FrontEnd)
	local List = workspace:GetPartBoundsInBox(GeneratedRegion, {Hatchet, Character})

	return List
end

local function BugFix(Point, Hatchet, Character)
	local CenterPoint = Point * HitboxSettings.Offset
	local FrontEnd = CenterPoint.Position + Vector3.new(HitboxSettings.Size.X/2, HitboxSettings.Size.Y/2, HitboxSettings.Size.Z/2)
	local BackEnd =  CenterPoint.Position + (Vector3.new(HitboxSettings.Size.X/2, HitboxSettings.Size.Y/2, HitboxSettings.Size.Z/2) * -1)

	local GeneratedRegion = Region3.new(BackEnd, FrontEnd)
	local List = workspace:GetPartBoundsInBox(GeneratedRegion, {Hatchet, Character})

	return List
end

local function RefineList(List) : "Removes Invisible Collisions"
	local list = {}

	for i, part in pairs(List) do

		if part.Transparency == 0 and part.Name ~= 'Corn' and part.Name ~= 'Leaves' then
			table.insert(list, part)
		end
	end

	return list
end

local function CheckForPlayer(List) : "If Hit A Player Return Player"
	local list = {} -- create new list in case we have to remove parts from downed players

	local function PlayerCheck(part : BasePart)
		local Humanoid = part.Parent:FindFirstChild("Humanoid")

		if not Humanoid then
			Humanoid = part.Parent.Parent:FindFirstChild("Humanoid")
		end

		if Humanoid and game:GetService('Players'):FindFirstChild(Humanoid.Parent.Name) then
			local passed, player = false, game:GetService('Players'):WaitForChild(Humanoid.Parent.Name)
			local Scripts = player:WaitForChild('Backpack'):WaitForChild('Scripts')
			local AFrame = code_module:GetEffect("AFrame", player)

			if Scripts.values.HealthState.Value > 0 -- not downed
				and (not AFrame or (AFrame and not AFrame.Active)) then
				
				passed = true -- you can hit this player for real
			end

			return true, passed, player -- automatically return player related at this point
		end

		return false -- not player related
	end

	for _, part in pairs(List) do
		local playerrelated, passed, player = PlayerCheck(part)

		if playerrelated and passed then
			return true, player -- return true to player check + player
		elseif playerrelated and not passed then
			continue -- ignore this part
		else -- was not player related
			table.insert(list, part)
		end
	end

	return false, list
end

local function InjurePlayer(Player : Player)
	local Scripts = Player:WaitForChild('Backpack'):WaitForChild('Scripts')

	Scripts:WaitForChild('values'):WaitForChild('HealthState').Value -= 1
end

function HatchetThrow(Player, Power, Origin)
	local hachetPower, hachetCFrame = Power, Origin

	warn(Power)

	local current_Throw = hatchet_model:Clone()
	current_Throw.Anchored = true
	current_Throw.CFrame = hachetCFrame * CameraOffset
	current_Throw.Parent = workspace
	current_Throw.Transparency = 0

	-- PREVENTS US FROM THROWING THROUGH WALLS --
	local List = BugFix(hachetCFrame, current_Throw, Player.Character)
	List = RefineList(List)

	local valid, result = CheckForPlayer(List)

	if valid then
		ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Event'):Fire("Hit", Player, result, "Hatchet")
		current_Throw:Destroy()
	else
		List = result -- removes downed players if we hit any
	end

	if #List >= 1 then current_Throw:Destroy() end -- Hit a object
	-- PREVENTS US FROM THROWING THROUGH WALLS --

	local lastProjected, originalThrow = current_Throw.CFrame, workspace:GetServerTimeNow()

	while current_Throw.Parent do
		local ProjectUpTime = workspace:GetServerTimeNow() - originalThrow
		local Speed = math.clamp(hachetPower - (ProjectUpTime/4.2), .1, 25) -- removes speed from out hatchet over time takes 1 second for full remove at lowest and 10 seconds at highest
		local CurrentProjected = current_Throw.CFrame * CFrame.Angles(0, math.rad(-(15 * Speed)), 0)
		local Gravity = 0 -- keep gravity global

		Gravity = ProjectUpTime/2.85

		if Speed <= .65 then
			Gravity *= 1.25
		end

		lastProjected *= CFrame.new(0, 0, -Speed)
		lastProjected += Vector3.new(0, -Gravity, 0)

		current_Throw.CFrame = (CurrentProjected.Rotation + lastProjected.Position) -- Gives us projected path's location w/ rotation of spinning hatchet

		local List = ReadCurrent(current_Throw, Player.Character)
		List = RefineList(List)

		local valid, result = CheckForPlayer(List)

		if valid then
			ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Event'):Fire("Hit", Player, result, "Hatchet")
			current_Throw:Destroy()
		else
			List = result -- removes downed players if we hit any
		end

		if #List >= 1 then
			current_Throw:Destroy() -- remove the hatchet
		end

		task.wait()
	end
end

remoteEvent.OnServerEvent:Connect(function(plr, ...)
	local args = {...}
	local hachetPower, hachetCFrame = math.clamp(args[1], .45, 3), args[2]

	hachetCFrame *= CFrame.new(0, -1.5, 0) -- makes it look more center of screen
	hachetPower *= 1.65 -- hatchet buff
	hachetPower = math.clamp(hachetPower, 1, 2.5) -- controls/limits the speed and buffs the lower end

	if data_module:GetAddon("Killer",plr,"Multi-Shot") then
		coroutine.wrap(HatchetThrow)(plr, hachetPower, hachetCFrame * CFrame.Angles(0, math.rad(MultiShot.Hatchet_Angle), 0))
		coroutine.wrap(HatchetThrow)(plr, hachetPower, hachetCFrame)
		coroutine.wrap(HatchetThrow)(plr, hachetPower, hachetCFrame * CFrame.Angles(0, math.rad(-MultiShot.Hatchet_Angle), 0))
	else
		coroutine.wrap(HatchetThrow)(plr, hachetPower, hachetCFrame)
	end
end)