--variables
local Saw = script.Parent
local Controller = Saw:WaitForChild('BodyParts'):WaitForChild('AnimationController'):WaitForChild('Animator')

local Character = Saw.Parent
local Humanoid = Character:WaitForChild('Humanoid')

-- Welding --
Saw:WaitForChild("Handle").CFrame = Character:WaitForChild("LeftHand").CFrame * CFrame.new(0,-0.5,-0.35) * CFrame.Angles(math.rad(90),math.rad(180),math.rad(180))

local GripWeld = Instance.new('WeldConstraint', Saw)
GripWeld.Name = 'HandleWeld'
GripWeld.Part0 = Character:WaitForChild('LeftHand')
GripWeld.Part1 = Saw:WaitForChild('Handle')

--[[Saw:WaitForChild('Trigger').CFrame = Character:WaitForChild('HumanoidRootPart').CFrame * CFrame.new(0, 0.2, -0.4)

local Tracks = {
	Move = Controller:LoadAnimation(script:WaitForChild('Jiggle'));
}


2536552930
2536555339
2536641208
2536554622
]]

--[[while task.wait() do
	local Goal = Saw:GetAttribute("Anim_Speed")
	
	if Goal > 0 and not Tracks.Move.IsPlaying then
		Tracks.Move:Play()
		Tracks.Move:AdjustSpeed(2)
	elseif Goal <= 0 and Tracks.Move.IsPlaying then
		Tracks.Move:Stop()
	end
end]]