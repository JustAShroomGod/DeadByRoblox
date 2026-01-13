local Players : Players, UserInputService : UserInputService, TweenService = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("TweenService")

local Focus = workspace:WaitForChild('UI'):WaitForChild('MainMenu'):WaitForChild('Camera')
local Camera = workspace.CurrentCamera

local LocalPlayer : Player = Players.LocalPlayer
local PlayerGui : PlayerGui = LocalPlayer.PlayerGui

script.Parent.Parent = PlayerGui

local InputConnection = nil

function SetCamera(Camera_Type)
	
	repeat Camera.CameraType = Camera_Type
		task.wait()
	until Camera.CameraType == Camera_Type
end

script.Parent.Enabled = true

SetCamera(Enum.CameraType.Scriptable)

Camera.CFrame = Focus:GetPivot() * CFrame.new(0, 0, 40)

script.Parent:WaitForChild("mainarea"):WaitForChild("version").Text = string.format("VERSION %s", game.PlaceVersion)

local TweenIn = TweenService:Create(script.Parent:WaitForChild('BlackOut'), TweenInfo.new(0.8), {Transparency = 0})
local TweenOut = TweenService:Create(script.Parent:WaitForChild('BlackOut'), TweenInfo.new(0.8), {Transparency = 1})

local function Init()	
	script.Parent:WaitForChild("mainarea"):WaitForChild("TextPrompt").Text = "LOADING DATA"

	for i = 1,15 do --15 is just a fail safe if user for whatever reason takes longer for data to load
		if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Character then
			break 
		else 
			task.wait(1)
		end
	end
	
	TweenIn:Play()
	TweenIn.Completed:Wait()
	
	script.Parent:WaitForChild('mainarea').Visible = false
	script.Parent:WaitForChild('Background').Visible = false
	
	TweenOut:Play()
	TweenOut.Completed:Wait()
	
	SetCamera(Enum.CameraType.Custom)
	
	LocalPlayer.CharacterAdded:Once(function()
		Camera.CameraSubject = LocalPlayer.Character.Humanoid
	end)

	script.Parent.Enabled = false
	PlayerGui:WaitForChild('ChooseBand').Enabled = true
	PlayerGui:WaitForChild('HUD').Enabled = true
end

InputConnection = UserInputService.InputBegan:Connect(function(InputObject, GameProcessedEvent)
	if GameProcessedEvent then return end

	Init()
	if InputConnection then
		InputConnection:Disconnect()
		InputConnection = nil
	end
end)