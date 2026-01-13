local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local Animations = {
	["SurvivorIdle"] = "rbxassetid://10226404089"
	,["TrapperIdle"] = "rbxassetid://10233839517"
	,["WraithIdle"] = "rbxassetid://10241624100"
	,["HillbillyIdle"] = "rbxassetid://10251709633"
	,["NurseIdle"] = "rbxassetid://10249247266"
	,["StalkerIdle"] = "rbxassetid://10236323722"
	,["HuntressIdle"] = "rbxassetid://10250582891"
	,["DoctorIdle"] = "rbxassetid://10240356735"
	,["PsychopathIdle"] = "rbxassetid://10233839517" --temp until new anim
	,["PriestIdle"] = "rbxassetid://10233839517" -- temp
	,["ReaperIdle"] = "rbxassetid://14817901823"
	,["MainMenuIdle"] = "rbxassetid://8805962958" --is used for all killers --8805962958
}

local module = {}

for i,v in pairs(Animations) do
	local new_animation = Instance.new("Animation")
	new_animation.Name = i
	new_animation.AnimationId = v
	new_animation.Parent = script
end

module.AnimationTracks = {
	["Survivor"] = {
		["Idle"] = humanoid:LoadAnimation(script:WaitForChild("SurvivorIdle"))
	}
	,["Killer"] = {
		["TrapperIdle"] = humanoid:LoadAnimation(script:WaitForChild("TrapperIdle"))
		,["WraithIdle"] = humanoid:LoadAnimation(script:WaitForChild("WraithIdle"))
		,["HillbillyIdle"] = humanoid:LoadAnimation(script:WaitForChild("HillbillyIdle"))
		,["NurseIdle"] = humanoid:LoadAnimation(script:WaitForChild("NurseIdle"))
		,["StalkerIdle"] = humanoid:LoadAnimation(script:WaitForChild("StalkerIdle"))
		,["HuntressIdle"] = humanoid:LoadAnimation(script:WaitForChild("HuntressIdle"))
		,["DoctorIdle"] = humanoid:LoadAnimation(script:WaitForChild("DoctorIdle"))
		,["PsychopathIdle"] = humanoid:LoadAnimation(script:WaitForChild("PsychopathIdle"))
		,["PriestIdle"] = humanoid:LoadAnimation(script:WaitForChild("PriestIdle"))
		,["ReaperIdle"] = humanoid:LoadAnimation(script:WaitForChild('ReaperIdle'))
		,["MainMenuIdle"] = humanoid:LoadAnimation(script:WaitForChild("MainMenuIdle"))
	}
}

local function stop_all()
	for _,side in pairs(module.AnimationTracks) do
		for _,animation_track in pairs(side) do
			if animation_track.IsPlaying then
				animation_track:Stop()
			end
		end
	end
end

function module.PlayAnimation(context,killer_character)
	if context == "Survivor" then
		stop_all()
		
		module.AnimationTracks.Survivor.Idle.Priority = Enum.AnimationPriority.Idle
		module.AnimationTracks.Survivor.Idle.Looped = true
		module.AnimationTracks.Survivor.Idle:Play()
	elseif context == "Killer" then
		stop_all()
		
		if module.AnimationTracks.Killer[tostring(killer_character).."Idle"] then
			module.AnimationTracks.Killer[tostring(killer_character .."Idle")].Priority = Enum.AnimationPriority.Idle
			module.AnimationTracks.Killer[tostring(killer_character .."Idle")].Looped = true
			module.AnimationTracks.Killer[tostring(killer_character .."Idle")]:Play()
		else
			module.PlayAnimation("Menu", killer_character)
		end
	elseif context == "Menu" then
		stop_all()
		
		module.AnimationTracks.Killer.MainMenuIdle.Priority = Enum.AnimationPriority.Idle
		module.AnimationTracks.Killer.MainMenuIdle.Looped = true
		module.AnimationTracks.Killer.MainMenuIdle:Play()
	end
end

return module
