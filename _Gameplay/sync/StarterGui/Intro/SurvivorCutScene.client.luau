local playerService, runService, tweenService, replicatedService = game:GetService('Players'), game:GetService('RunService'), game:GetService('TweenService'), game:GetService('ReplicatedStorage')

local Player : Player = playerService.LocalPlayer
local Camera : Camera = workspace.CurrentCamera

local PlayerGui : PlayerGui = Player:WaitForChild('PlayerGui')
local CutsceneUI, NewHud = PlayerGui:WaitForChild("Intro"), PlayerGui:WaitForChild("HUD"):WaitForChild("MainHud")
local ControlScript = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()

local Character : Model = Player.Character or Player.CharacterAdded:Wait()
local Humanoid : Humanoid = Character:WaitForChild("Humanoid")

local sound = script.Parent.Intro

local remoteStorage : Folder = replicatedService:WaitForChild('RemoteEvents')
local remotes = {
	Property = remoteStorage:WaitForChild('NewPropertie');
}

local Scripts : Model = Player:WaitForChild("Backpack"):WaitForChild("Scripts")
local PlayerValues = Scripts:WaitForChild("values")
local IsKiller = Scripts:WaitForChild("Killer")
local MoveScript = Scripts:WaitForChild("MovementSpeedScript"):WaitForChild("MainScript")
local Code = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local CutsceneTime = 7
local appliedFreeze = false

------

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

SetCamera(Enum.CameraType.Scriptable)
Camera.CameraSubject = Character:WaitForChild("UpperTorso")

Humanoid.WalkSpeed = 0
workspace.Nightambience:Play()
--ControlScript:Disable()

local Effect = GetEffect()
local StartTick = workspace:GetServerTimeNow()

event = runService.RenderStepped:Connect(function()
	if IsKiller.Value then event:Disconnect() event = nil end
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
		NewHud.Parent.Perk_Display.Visible = false
		NewHud.Parent.Controls_Display.Visible = false
		NewHud.Game_Display.Visible = false
		NewHud.Item_Display.Visible = false
		

		if (not appliedFreeze) then
			appliedFreeze = true
			Code.Speeds:addMultiplier(Player, "Intro", 0, CutsceneTime)
		end
	else
		Effect.Brightness = 0
		NewHud.Parent.Controls_Display.Visible = true
		Humanoid.WalkSpeed = 7
		Character.HumanoidRootPart.Anchored = false
		NewHud.Player_Display.Visible = true
		NewHud.Parent.Perk_Display.Visible = true
		--ControlScript:Enable()
		NewHud.Game_Display.Visible = true
		NewHud.Item_Display.Visible = true
		CutsceneUI.Enabled = false
		MoveScript.Disabled = false
		Scripts:WaitForChild("CrouchAction").Disabled = false


		SetCamera(Enum.CameraType.Custom)
		Camera.CameraSubject = Humanoid
		Player.Character:SetAttribute("IntroDone" ,true)
		
		script.RemoteEvent:FireServer()
		
		script.Disabled = true

		if Code:IsObsession(Player) then
			local s = Instance.new("Sound", PlayerGui)
			s.SoundId = "rbxassetid://18493876667"
			s.Volume = 0.4
			s:Play()
			s.Stopped:Connect(function()
				s:Destroy()
			end)
		end
		
		if event then event:Disconnect() event = nil end
	end
end)