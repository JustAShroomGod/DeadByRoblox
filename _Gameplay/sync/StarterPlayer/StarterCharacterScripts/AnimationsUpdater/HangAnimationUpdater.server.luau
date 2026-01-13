local plr = game.Players:WaitForChild(script.Parent.Parent.Name)
local char = workspace:WaitForChild(plr.Name)
local humanoid = char:WaitForChild("Humanoid")

local Backpack = plr:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")
local values = Scripts:WaitForChild("values")

local action = values:WaitForChild("Action")
local hooked = values:WaitForChild("Hooked")

local hook = nil

local Animations = game:GetService("ReplicatedStorage"):WaitForChild("Game_Assets"):WaitForChild("Animations"):WaitForChild("Hook"):WaitForChild("Survivor")

local CheckAnimationStage = function()
	local Character = char
	local HookCount = if Character:GetAttribute("Hook_Stage") then string.split(Character:GetAttribute("Hook_Stage"), ':') else {0, 2}
	return tonumber(HookCount[1])
end

local hangAnim = Animations:WaitForChild("Hook_Hang"):Clone()
local hangedAnim = Animations:WaitForChild("Hook_Hang_Idle"):Clone()
local StrugglingAnimation = Instance.new("Animation", script)
StrugglingAnimation.Name = "Struggling_Survivor"
StrugglingAnimation.AnimationId = "rbxassetid://80757971559919"
hangAnim.Parent = script
hangedAnim.Parent = script
local CurrentAnimation = nil
local EntityObjectAnimation = nil
local EntityAnimation = nil
local CurrentAnimationObject = nil
local StrugglingEntityAnimation = Instance.new("Animation", script)
StrugglingEntityAnimation.Name = "Struggling_Entity"
StrugglingEntityAnimation.AnimationId = "rbxassetid://135295449015453"

-- this entire script was supposed to be a place holder until you guys finally got around to adding the hook animations use "HOOK_FIX" to change where the survivor is on the hook

local Anim = 
	{
		["Hanged"] = hangAnim,
		["FirstStage"] = hangedAnim,
		["SecondStage"] = StrugglingAnimation,
		["EntitySecondStage"] = StrugglingEntityAnimation
	}

hooked.Changed:Connect(function()
	if hooked.Value then
		CurrentAnimationObject = Anim.Hanged:Clone()
		CurrentAnimationObject.Parent = workspace
		CurrentAnimation = char.Humanoid.Animator:LoadAnimation(CurrentAnimationObject)
		CurrentAnimation:Play()
		repeat task.wait() until CurrentAnimation.IsPlaying == false or hooked.Value == false
		if hooked.Value then
			if CheckAnimationStage() >= 2 then
				CurrentAnimationObject:Destroy()
				CurrentAnimation:Stop()
				CurrentAnimation = nil
				CurrentAnimationObject = Anim.SecondStage:Clone()
				CurrentAnimationObject.Parent = workspace
				CurrentAnimation = char.Humanoid.Animator:LoadAnimation(CurrentAnimationObject)
				CurrentAnimation:Play()
			else
				CurrentAnimationObject = Anim.FirstStage:Clone()
				CurrentAnimationObject.Parent = workspace
				CurrentAnimation = char.Humanoid.Animator:LoadAnimation(CurrentAnimationObject)
				CurrentAnimation:Play()
			end
		else
			CurrentAnimationObject:Destroy()
			CurrentAnimation:Stop()
			CurrentAnimation = nil
		end
	else
		if CurrentAnimationObject then
			CurrentAnimationObject:Destroy()
			CurrentAnimation:Stop()
			CurrentAnimation = nil
		end
		if EntityObjectAnimation then
			EntityObjectAnimation:Destroy()
			EntityAnimation:Stop()
			EntityAnimation = nil
		end
	end
end)

local Stage = 0

local maxHooks = 24

while task.wait(0.2) do
	for i = 1, maxHooks do
		local targetHook = workspace:FindFirstChild("Hook".. tostring(i))

		if targetHook then
			local trigger = targetHook:FindFirstChild("Trigger")

			if trigger then
				if (char:WaitForChild("LowerTorso").CFrame.p - trigger.CFrame.p).magnitude < 7 then
					if hook then
						if hook.Name ~= targetHook.Name then
							hook = targetHook
						end
					else
						hook = targetHook
					end
				end
			end
		end
	end

	if hooked.Value then
		if CheckAnimationStage() ~= Stage then
			if CheckAnimationStage() >= 2 then
				CurrentAnimationObject:Destroy()
				CurrentAnimation:Stop()
				CurrentAnimation = nil
				CurrentAnimationObject = Anim.SecondStage:Clone()
				CurrentAnimationObject.Parent = workspace
				CurrentAnimation = char.Humanoid.Animator:LoadAnimation(CurrentAnimationObject)
				CurrentAnimation:Play()
				if not EntityObjectAnimation then
					EntityObjectAnimation = Anim.EntitySecondStage:Clone()
					EntityObjectAnimation.Parent = workspace
					EntityAnimation = hook["hookentity"].AnimationController:LoadAnimation(EntityObjectAnimation)
					EntityAnimation:Play()
				end
			end
		end
		--[[Stage = CheckAnimationStage()
		if Stage >= 2 then
			char.HumanoidRootPart.CFrame = hook["Trigger"].CFrame * CFrame.new(0,2.65,0)
			char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.Angles(0,135,0)
		else
			char.HumanoidRootPart.CFrame = hook["Trigger"].CFrame * CFrame.new(0,2.65,0)
			char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.Angles(0,135,0)
		end]]
	end
end