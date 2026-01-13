--!nocheck
--!nolint

local ReplicatedStorage, tweenService, runService = game:GetService('ReplicatedStorage'), game:GetService("TweenService"), game:GetService('RunService')

local moduleStorage = ReplicatedStorage:WaitForChild('Modules')

local code_module = require(moduleStorage:WaitForChild('Code'))
local Testing = false

local Player = game.Players.LocalPlayer
local Character = workspace:WaitForChild(Player.Name)
local humanoid = Character:WaitForChild("Humanoid")
local rootPart = Character:WaitForChild("HumanoidRootPart")

local ScratchRange, ScratchTime, ScratchFreq = 21, 5, .5
local MinSize = 10;

local scratchesFolder = Instance.new("Folder", workspace.CurrentCamera)
scratchesFolder.Name = "ScratchesFolder"

local Backpack = Player:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")

local killer = Scripts:WaitForChild("Killer")
local HasFixated, FixatedTier = require(moduleStorage:WaitForChild('Data')):GetPerk("Fixated")

local directionsTable = { -- the way rays shoot out?
	Straight = {
		Direction = CFrame.Angles(0,0,0); -- direction we shoot out
		Amount = 3; -- amount to spawn here
		Range = 400; -- amount to branch out
		MaxSize = 35; -- biggest scratch
	};
	Down = {
		Direction = CFrame.Angles(math.rad(-90),0,0); -- straight foward
		Amount = 5; -- amount to spawn here
		Range = 420; -- amount to branch out
		MaxSize = 50; -- biggest scratch
	};
	Right = {
		Direction = CFrame.Angles(0,math.rad(90),0); -- right angle
		Amount = 1; -- amount to spawn here
		Range = 400; -- amount to branch out
		MaxSize = 35; -- biggest scratch
	};
	Back = {
		Direction = CFrame.Angles(0,math.rad(180),0); -- straight down
		Amount = 1; -- amount to spawn here
		Range = 400; -- amount to branch out
		MaxSize = 35; -- biggest scratch
	};
	Left = {
		Direction = CFrame.Angles(0,math.rad(-90),0); -- left angle
		Amount = 2; -- amount to spawn here
		Range = 400; -- amount to branch out
		MaxSize = 35; -- biggest scratch
	};
	Up = {
		Direction = CFrame.Angles(math.rad(90),0,0); -- straight back
		Amount = 1; -- amount to spawn here
		Range = 400; -- amount to branch out
		MaxSize = 55; -- biggest scratch
	};
}

local ScratchTicks = {} -- gonna store scratch mark creations here

local Connections = {}

local function PlayMarks(Survivor_Player : Player) : "Does Scratch Marks Loop for this user"
	local Survivor_Character = Survivor_Player.Character

	if not Survivor_Character then return end
	if code_module:GetEffect("Hidden", Survivor_Player) then return end -- hidden no scrach marks
	if code_module:GetEffect("Cloaked", Survivor_Player) then return end
	if code_module:GetEffect("Ghost", Survivor_Player) then return end

	local survivorHumanoid, survivorRootPart = Survivor_Character:WaitForChild("Humanoid"), Survivor_Character:WaitForChild("HumanoidRootPart")
	local Survivor_Scripts = Survivor_Player:WaitForChild("Backpack"):WaitForChild('Scripts')
	local Survivor_Values = Survivor_Scripts:WaitForChild('values')
	local healthState, hooked, shift = Survivor_Values:WaitForChild('HealthState'), Survivor_Values:WaitForChild('Hooked'), Survivor_Scripts:WaitForChild('MovementSpeedScript'):WaitForChild('Shift')

	if not ScratchTicks[Player.Name] then
		ScratchTicks[Player.Name] = tick()
	end

	if (tick() - ScratchTicks[Player.Name]) >= ScratchFreq
		and survivorHumanoid.MoveDirection ~= Vector3.new(0,0,0)
		and not hooked.Value
		and healthState.Value > 0
		and shift.Value
		and survivorHumanoid.WalkSpeed ~= 0
		and Survivor_Character.PrimaryPart.Anchored ~= true
		and healthState.Parent.Action.Value == "Nothing"
		and survivorHumanoid.Parent.Parent == workspace
		and survivorHumanoid:GetMoveVelocity() ~= Vector3.new(0,0,0) then
		local Base_Frame = CFrame.new(Survivor_Character:GetPivot().Position)

		ScratchTicks[Player.Name] = tick()

		for _,DirectionTable in pairs(directionsTable) do
			local ray = Ray.new(Base_Frame.Position, (Base_Frame * DirectionTable.Direction).LookVector * ScratchRange)
			local part, position = workspace:FindPartOnRayWithIgnoreList(ray, {scratchesFolder, Character, Survivor_Character}, true, true)

			if part then
				local Angles = {0, 90, 180, 270, 360}

				for i = 1, DirectionTable.Amount do
					local newPositionY =  math.random(-DirectionTable.Range, DirectionTable.Range)/100
					newPositionY -= (newPositionY * math.random(0,1)) * 2

					local newPositionS = math.random(-DirectionTable.Range, DirectionTable.Range)/100
					newPositionS -= (newPositionS * math.random(0,1)) * 2

					local thisCFrame = CFrame.new(Base_Frame.Position, position)
					local tweenTime = 0
					local agreed = false


					thisCFrame *= CFrame.new(0, 0, -(Base_Frame.Position - position).magnitude) * CFrame.new(newPositionS, newPositionY, 0) * CFrame.Angles(0, 0, math.rad(math.random(0, 360)))
					tweenTime = 3

					local scratchPart = Instance.new("Part", scratchesFolder)
					scratchPart.Anchored = true
					scratchPart.CanCollide = false
					scratchPart.CanQuery = false
					scratchPart.Transparency = 1
					scratchPart.Material = "Neon"
					scratchPart.Color = Color3.fromRGB(0,0,0)
					scratchPart.Name = "Scratch"
					scratchPart.Size = Vector3.new(math.random(MinSize, DirectionTable.MaxSize)/10, 0.1, 0.1)
					scratchPart.CFrame = thisCFrame

					local tween = tweenService:Create(scratchPart, TweenInfo.new(tweenTime), {Transparency = 0, Color = Color3.fromRGB(208, 23, 6)})
					tween:Play()

					local con con = tween.Completed:Connect(function()
						con:Disconnect()
						task.wait(ScratchTime)

						tween = tweenService:Create(scratchPart, TweenInfo.new(3), {Color = Color3.fromRGB(), Transparency = 1})
						tween:Play()
						tween.Completed:Wait()

						scratchPart:Destroy() -- remove part!
					end)
				end
			end
		end
	end
end

while task.wait() do -- scratch mark loop

	if killer.Value or Testing or HasFixated then -- We have fixated or we are a killer

		for _, Survivor_Player in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do
			if Connections[Survivor_Player.Name] then continue end

			if not killer.Value then
				if Survivor_Player ~= game.Players.LocalPlayer then
				else
					Connections[Survivor_Player.Name] = runService.Heartbeat:Connect(function()
						PlayMarks(Survivor_Player)
					end)
				end
			else
				Connections[Survivor_Player.Name] = runService.Heartbeat:Connect(function()
					PlayMarks(Survivor_Player)
				end)
			end
		end

		for Player, Connection in pairs(Connections) do -- unplug players no longer here

			if not game:GetService('Players'):FindFirstChild(Player) then
				Connection:Disconnect() Connection = nil
			end
		end
	end
end