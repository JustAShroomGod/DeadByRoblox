local UserInputService = game:GetService('UserInputService')
local Game_Pad_Dependent = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1) -- gets first gamepad/only gamepad

local Data = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))

local Player = game.Players.LocalPlayer
local PlayerUI = Player:WaitForChild('PlayerGui')
local UI_MOBILE_DEADZONE : Frame = PlayerUI:WaitForChild('Mobile_Dead'):WaitForChild('Deadzone')

local Settings = Data:GetSettings()

local Handler = {
	Sensitivity = {
		X = Settings.CAMERA.Sensitivity.X;
		Y = Settings.CAMERA.Sensitivity.Y;
		Modification = nil;
	};
	Camera = {
		Origin = CFrame.new();
		Visual_Offset = CFrame.new(0, 0.5, -.8);
		Offset = Vector2.zero;
		HeadLocked = false;
		SnapTo = false;
		Ignore = false;
	};
	Mouse = {
		Position = Vector2.zero;
	};
	Gamepad = {
		Dead_Zone = 35;
		States = {};
	};
	Touch = {
		Start = Vector3.zero;
		Position = Vector2.zero;
		Update = Vector3.zero;
		Dragging = false;
		Mode = 2; -- 1/2 continous vs tracking
		Moving_Finger = nil;
	}
}

-- GAMEPAD CONTROLS --
for _, Object in pairs(Game_Pad_Dependent) do
	Handler.Gamepad.States[Object.KeyCode] = Object
end

-- TOUCH CONTROLS --
local Dead_Zones = Settings.KEYBINDS['Killer'].Mobile.Deadzones

for Zone_Name, Zone_Data in pairs(Dead_Zones) do
	local Zone = Instance.new('Frame', UI_MOBILE_DEADZONE)
	Zone.AnchorPoint = Vector2.new(0.5, 0.5)
	Zone.Size = UDim2.new(Zone_Data.Size[1], 0, Zone_Data.Size[2], 0)
	Zone.Position = UDim2.new(Zone_Data.Position[1], 0, Zone_Data.Position[2], 0)
	Zone.BackgroundTransparency = 0.5
	Zone.Name = Zone_Name
end

function WasDead(position : Vector2) : boolean | "Return if tap started in dead zone"

	local function WithinBounds(LowerCorner, UpperCorner)

		if LowerCorner.X <= position.X and LowerCorner.Y <= position.Y -- below lower corner (upper left) then
			and UpperCorner.X >= position.X and UpperCorner.Y >= position.Y then -- above upper corner (bottom left)

			return true
		end
	end

	for _, zone in pairs(UI_MOBILE_DEADZONE:GetChildren()) do
		local TopLeft = zone.AbsolutePosition
		local BottomRight = zone.AbsolutePosition + zone.AbsoluteSize

		if WithinBounds(TopLeft, BottomRight) then
			return true
		end
	end

	return false
end

UserInputService.TouchStarted:Connect(function(input)
	if Handler.Touch.Moving_Finger then return end -- do not allow 2 readings if we are currently tracking a finger
	local Valid_Finger = not WasDead(Vector2.new(input.Position.X, input.Position.Y)) -- lets u move and turn at same time

	if not Valid_Finger then return end
	Handler.Touch.Moving_Finger = input

	Handler.Touch.Update = input.Position
	Handler.Touch.Start = input.Position
	Handler.Touch.Dragging = true
end)

UserInputService.TouchMoved:Connect(function(input)
	if not Handler.Touch.Dragging or input ~= Handler.Touch.Moving_Finger then return end
	local Result = (Handler.Touch.Start - input.Position)

	Handler.Touch.Position = Vector2.new(Result.X, Result.Y)
	Handler.Touch.Update = input.Position
end)

UserInputService.TouchEnded:Connect(function(input)
	if Handler.Touch.Moving_Finger ~= input then return end

	Handler.Touch.Start = if Handler.Touch.Mode == 1 then Vector3.zero else input.Position
	Handler.Touch.Position = Vector2.zero;
	Handler.Touch.Moving_Finger = nil -- removed finger
end)

function Handler:GetTouchVector() : Vector2
	local Return_Vector = Vector2.zero

	if Handler.Touch.Mode == 1 then
		Return_Vector = Handler.Touch.Position
		Return_Vector *= 1.3
	else
		Return_Vector = Handler.Touch.Position

		Handler.Touch.Start = Handler.Touch.Update
		Handler.Touch.Position = Vector2.zero

		Return_Vector *= 4
	end

	return Return_Vector
end

function Handler:GetMouseVector() : Vector2
	local Mouse_Return = UserInputService:GetMouseDelta()

	if Mouse_Return.Magnitude <= 0 and Mouse_Return ~= Vector3.zero then
		Mouse_Return = Vector3.zero
	end

	return Vector2.new(-Mouse_Return.X, -Mouse_Return.Y)
end

function Handler:GetGamepadVector() : Vector2
	local Pad_Return = Handler.Gamepad.States[Enum.KeyCode.Thumbstick2].Position

	Pad_Return *= 100

	if math.abs(Pad_Return.X) < Handler.Gamepad.Dead_Zone then
		Pad_Return = Vector2.new(0, Pad_Return.Y)
	end

	if math.abs(Pad_Return.Y) < Handler.Gamepad.Dead_Zone then
		Pad_Return = Vector2.new(Pad_Return.X, 0)
	end

	--print(Pad_Return)

	return Vector2.new(-Pad_Return.X, Pad_Return.Y)
end

local Rayparms = RaycastParams.new()
Rayparms.FilterDescendantsInstances = {}
Rayparms.FilterType = Enum.RaycastFilterType.Exclude

function Handler:GetCamera(Character : Model, Delta : Vector2, Step) : CFrame
	local Root = Character:WaitForChild('HumanoidRootPart')
	local Head_Position : CFrame = Character:WaitForChild('Head'):GetPivot()
	local Current_Position : Vector3 = CFrame.new(Head_Position.Position)

	coroutine.resume(coroutine.create(function()
		for i, g in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
			if (g:IsA("Decal") or g:IsA("Texture")) and (string.match(g.Parent.Name , "Torso") or string.match(g.Parent.Name, "Arm") or string.match(g.Parent.Name, "Leg") or string.match(g.Parent.Name, "Hand") or string.match(g.Parent.Name, "Foot") or string.match(g.Parent.Name, "Handle")) then
				if (game.Players.LocalPlayer.Character:FindFirstChild("Content Creator") ~= nil) then
					if not (g:IsDescendantOf(game.Players.LocalPlayer.Character['Content Creator'])) then
						g.LocalTransparencyModifier = 0
					end
				else
					g.LocalTransparencyModifier = 0
				end
			end
		end
	end))


	-- Process Delta --
	Delta *= Vector2.new(Handler.Sensitivity.X, Handler.Sensitivity.Y)

	if Handler.Sensitivity.Modification then

		if Handler.Sensitivity.Modification.Multiplier then
			Delta *= Handler.Sensitivity.Modification.Multiplier -- get raise/reduced by delta
		end

		if Handler.Sensitivity.Modification.Clamp then
			Delta = Vector2.new(math.clamp(Delta.X, -Handler.Sensitivity.Modification.Clamp.X * Step, Handler.Sensitivity.Modification.Clamp.X * Step), math.clamp(Delta.Y, -Handler.Sensitivity.Modification.Clamp.Y * Step, Handler.Sensitivity.Modification.Clamp.Y * Step))
		end
	end

	Handler.Camera.Offset += Delta
	Handler.Camera.Offset = Vector2.new(Handler.Camera.Offset.X, math.clamp(Handler.Camera.Offset.Y, -89, 89))

	if Handler.Camera.Disable then
		--Do Nothing
	elseif Handler.Camera.HeadLocked then
		local _, Head, _ = (Character:GetPivot() * CFrame.new(Vector3.new(0, math.abs(Character:GetPivot().Position.Y - Head_Position.Position.Y), 0))):ToOrientation()

		Handler.Camera.SnapTo = Head
		Handler.Camera.Offset = Vector2.zero

		Current_Position = Head_Position
	elseif Handler.Camera.SnapTo then
		Handler.Camera.Origin = CFrame.new() * CFrame.Angles(0, Handler.Camera.SnapTo, 0)
		Handler.Camera.SnapTo = false

		Current_Position = Head_Position
	else
		Rayparms.FilterDescendantsInstances = {Character}

		local Origin, Goal = Current_Position * Handler.Camera.Origin * CFrame.Angles(0, math.rad(Handler.Camera.Offset.X), 0) * CFrame.Angles(math.rad(Handler.Camera.Offset.Y), 0, 0), Current_Position * Handler.Camera.Origin * CFrame.Angles(0, math.rad(Handler.Camera.Offset.X), 0) * Handler.Camera.Visual_Offset * CFrame.Angles(math.rad(Handler.Camera.Offset.Y), 0, 0)
		local Cast = workspace:Raycast(Origin.Position, (Goal.Position - Origin.Position).Unit * (Goal.Position - Origin.Position).Magnitude, Rayparms)

		if Cast then
			Current_Position *= Handler.Camera.Origin * CFrame.Angles(0, math.rad(Handler.Camera.Offset.X), 0) * CFrame.new(0, 0, -(Cast.Distance/2)) * CFrame.Angles(math.rad(Handler.Camera.Offset.Y), 0, 0)
		else
			Current_Position = Goal
		end

		--Current_Position *= Handler.Camera.Origin * CFrame.Angles(0, math.rad(Handler.Camera.Offset.X), 0) * Handler.Camera.Visual_Offset * CFrame.Angles(math.rad(Handler.Camera.Offset.Y), 0, 0)-- apply mouse x/y

		local _, X, _ = CFrame.new(Root.Position, Vector3.new(Current_Position.LookVector.X * 900000, Root.Position.Y, Current_Position.LookVector.Z * 900000)):ToOrientation()
		local _, X_2, _ = Root.CFrame:ToOrientation()

		Root.CFrame = CFrame.new(Root.Position, Vector3.new(Current_Position.LookVector.X * 900000, Root.Position.Y, Current_Position.LookVector.Z * 900000))

		--if math.abs(X - X_2) > 0.05 then -- First Set, 2nd Set
		--Root.CFrame = CFrame.new(Root.Position, Vector3.new(Current_Position.LookVector.X * 900000, Root.Position.Y, Current_Position.LookVector.Z * 900000))
		--end

	end

	return Current_Position
end

return Handler