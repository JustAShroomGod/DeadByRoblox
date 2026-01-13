local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer
local Humanoid = Player.Character.Humanoid
local Backpack = Player.Backpack
local Scripts = Backpack:WaitForChild("Scripts")

local PowerModel = Player.Character:WaitForChild("Blink")

local fatigueTween = nil
local prefix = "rbxassetid://"
InTeleport = false

local animationIds = {
	["Teleport"] = 79434666183823, --15071967320 old
	["Fatigue"] = 15071974883, -- 15071974883
	["Charge"] = 129545894601453,  -- 15071978470
	["OverCharge"] = 136980343086211 -- 15071981714
}

for wAction, animationId in pairs (animationIds) do
	local animation = Instance.new("Animation", Humanoid)
	animation.AnimationId = prefix.. tostring(animationId)
	animationIds[wAction] = animation
end

local Animations = {
	Charge = Humanoid:LoadAnimation(animationIds["Charge"])
	,Fatigue = Humanoid:LoadAnimation(animationIds["Fatigue"])
	,Teleport = Humanoid:LoadAnimation(animationIds["Teleport"])
}

RunService.Heartbeat:Connect(function()
	if (Animations.Charge.TimePosition >= 1.2) then
		Animations.Charge.TimePosition = 1.2
		Animations.Charge:AdjustSpeed(0)
	end
	
	local timelimit = if (InTeleport) then 0.85 else Animations.Teleport.Length
	local speed = if (InTeleport) then 0 else 1
	
	if (Animations.Teleport.TimePosition >= timelimit) then
		Animations.Teleport.TimePosition = timelimit
		Animations.Teleport:AdjustSpeed(speed)
	end
	
end)

local Visual = {}


function Visual.Init()
	local FatigueEffect = PowerModel.FatigueEffect
	FatigueEffect.Parent = game.Lighting
end

function Visual.StartCharge()
	if (not Animations.Charge.isPlaying) then
		Animations.Charge:Play()
	end
end

function Visual.StopCharge()
	if (Animations.Charge.isPlaying) then
		Animations.Charge:Stop()
	end
end

function Visual.StartTeleport()
	if (not Animations.Teleport.isPlaying) then
		InTeleport = false
		Animations.Teleport:Play()
	end
end

function Visual.StopTeleport()
	InTeleport = false
end

function Visual.IsInTeleport() : boolean
	return Visual.IsInTeleport()
end

Visual.Init()

return Visual
