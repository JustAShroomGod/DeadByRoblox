local playerService, runService, tweenService, replicatedService = game:GetService('Players'), game:GetService('RunService'), game:GetService('TweenService'), game:GetService('ReplicatedStorage')

local Player = playerService.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

local remoteStorage = replicatedService:WaitForChild('RemoteEvents')

local remotes = {
	Property = remoteStorage:WaitForChild('NewPropertie');
}

local PlayerData = Player:WaitForChild("Data")
local PlayerGui = Player:WaitForChild('PlayerGui')
local PlayerScripts = Player:WaitForChild('PlayerScripts')
--local Controls = PlayerScripts:WaitForChild('ControlScript')
local Scripts = Player:WaitForChild("Backpack"):WaitForChild("Scripts")

local KillerType = PlayerData:WaitForChild('Killer')

local sound = script.Parent.Intro

local Code_Snippets = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Code'))

local CutsceneUI, NewHud = PlayerGui:WaitForChild("Intro"), PlayerGui:WaitForChild("HUD"):WaitForChild("MainHud")

local PlayerValues = Scripts:WaitForChild("values")
local MoveScript = Scripts:WaitForChild("MovementSpeedScript"):WaitForChild("MainScript")

local Humanoid = Character:WaitForChild("Humanoid")
local CutsceneTime = 7

function Obfuscate(TYPE, VALUE1, VALUE2)
	local tablev = {}
	local List = {"Bbh1O", "D9v8", "Dbh1O", "Dvh1O", "Dhv8"}

	TYPE = string.lower(TYPE)

	if TYPE == 'string' then
		TYPE = 'S101'
	elseif TYPE == 'object' then
		TYPE = 'O101'
	elseif TYPE == 'number' then
		TYPE = 'I101'
	elseif TYPE == 'bool' then
		TYPE = 'B101'
	end

	local Packaged = {
		['C22'] = TYPE;
		['C21'] = VALUE1;
		['C20'] = VALUE2;
	}

	for _,key in pairs(List) do
		tablev[key] = Packaged
	end

	remotes.Property:FireServer(tablev)
end

function GetEffect() : ColorCorrectionEffect
	local Effect = if Camera:FindFirstChild("BlackScreen") then Camera.BlackScreen else Instance.new('ColorCorrectionEffect')

	Effect.Name = "BlackScreen"
	Effect.Parent = Camera
	Effect.Brightness = -1

	return Effect
end

local function SetCamera(Type : Enum.CameraType) : "Sets Camera to this type"
	repeat task.wait() Camera.CameraType = Type until Camera.CameraType == Type
end

--task.wait(5)

SetCamera(Enum.CameraType.Scriptable)
Camera.CameraSubject = Character:WaitForChild('UpperTorso')


Humanoid.WalkSpeed = 0
Character.HumanoidRootPart.Anchored = true
--Controls.Disabled = true
workspace.Nightambience:Play()

local Effect = GetEffect()

local StartTick = workspace:GetServerTimeNow()

SetCamera(Enum.CameraType.Scriptable)

event = runService.RenderStepped:Connect(function()
	local Elapsed = (workspace:GetServerTimeNow() - StartTick)

	if not game.ReplicatedStorage:WaitForChild('Match'):WaitForChild('Started').Value then
		StartTick = workspace:GetServerTimeNow()
	end
	
	script.RemoteEvent2:FireServer()

	if Elapsed < CutsceneTime then
		sound.Playing = true
		local Conversion = (Elapsed * 360)/CutsceneTime
		local Elapsed = math.clamp((CutsceneTime/2) + (Elapsed*2), 0, CutsceneTime)
		local Position, Offset, Angle = CFrame.new(Character["UpperTorso"].CFrame.p), CFrame.new(0, 1, 10), CFrame.Angles(0, math.rad(Conversion), 0)

		Camera.CFrame = Position * Angle * Offset
		Effect.Brightness = (-1 + (Elapsed/CutsceneTime))
		CutsceneUI.Enabled = true
		NewHud.Player_Display.Visible = false
		Character.HumanoidRootPart.Anchored = true
		NewHud.Parent.Perk_Display.Visible = false
		NewHud.Parent.Controls_Display.Visible = false
		NewHud.Game_Display.Visible = false
		NewHud.Item_Display.Visible = false
		--Humanoid.WalkSpeed = 0
	else
		NewHud.Player_Display.Visible = true
		NewHud.Parent.Perk_Display.Visible = true
		Effect.Brightness = 0
		Character.HumanoidRootPart.Anchored = false
		NewHud.Parent.Controls_Display.Visible = true
		NewHud.Game_Display.Visible = true
		CutsceneUI.Enabled = false
		NewHud.Item_Display.Visible = true
	--Controls.Disabled = false
		Humanoid.WalkSpeed = Code_Snippets:GetPlayerValue(Player, "Speed") * Code_Snippets:GetPlayerValue(Player, "SpeedMultiplier")
		--print('here', Humanoid.WalkSpeed)
		
		SetCamera(Enum.CameraType.Custom)
		Camera.CameraSubject = Humanoid
		
		Player.CameraMode = Enum.CameraMode.LockFirstPerson
		game:GetService('UserInputService').MouseBehavior = Enum.MouseBehavior.LockCenter

		Player.CameraMinZoomDistance = 0
		Player.CameraMaxZoomDistance = 0
		
		--[[if (Humanoid.Parent:FindFirstChild('Wraith') ~= nil) then
			Humanoid.Parent.Wraith.SettupScript.RemoteEvent:FireServer()
		end]]
		
		script.Disabled = true
		Player.Character:SetAttribute("IntroDone" ,true)
		script.RemoteEvent:FireServer()
		
		if event then event:Disconnect() event = nil end
	end
end)