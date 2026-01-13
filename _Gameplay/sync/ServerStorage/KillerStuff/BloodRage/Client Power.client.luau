local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer
local Humanoid = Player.Character.Humanoid
local Backpack = Player.Backpack
local Scripts = Backpack:WaitForChild("Scripts")

local PowerModel = script.Parent
local PowerRemote = PowerModel:WaitForChild("PowerValues"):WaitForChild("PowerRemote")

local animTrack
local prefix = "rbxassetid://"

local animations = {
	["Rage"] = 13459009530
	,["Fatigue"] = 13459012389
}

for wAction, animationId in pairs (animations) do
	local animation = Instance.new("Animation", Humanoid)
	animation.AnimationId = prefix.. tostring(animationId)
	animations[wAction] = animation
end

local Animations = {
	Rage = Humanoid:LoadAnimation(animations["Rage"])
	,Fatigue = Humanoid:LoadAnimation(animations["Fatigue"])
}

function startFatigue()
	if (not Animations.Fatigue.isPlaying) then

		Animations.Fatigue:Play()
		local CameraController = require(Scripts:WaitForChild('GlobalKiller').Camera)
		CameraController.Camera.HeadLocked = true

		local rbxconFatigueStopped 
		rbxconFatigueStopped = Animations.Fatigue.Stopped:Connect(function ()
			rbxconFatigueStopped:Disconnect()
			CameraController.Camera.HeadLocked = false
			PowerRemote:FireServer("FatigueEnd")
		end)
	end
end

function stopFatigue()
	if (Animations.Fatigue.isPlaying) then
		Animations.Fatigue:Stop()
	end
end

function startRage()
	if (not Animations.Rage.isPlaying) then
		Animations.Rage:Play()
	end
end

function stopRage()
	if (Animations.Rage.isPlaying) then
		Animations.Rage:Stop()
	end
end

PowerRemote.OnClientEvent:Connect(function(Command)

	if (Command == "stopFatigue") then
		stopFatigue()
	elseif (Command == "startFatigue") then
		startFatigue()
	elseif (Command == "startRage") then
		startRage()
	elseif (Command == "stopRage") then
		stopRage()
	end
end)