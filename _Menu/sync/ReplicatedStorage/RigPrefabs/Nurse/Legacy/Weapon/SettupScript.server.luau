local char = script.Parent.Parent
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")
local rightHand = char:WaitForChild("RightHand")
local handle = script.Parent:WaitForChild("Handle")

handle.CFrame = rightHand.CFrame * CFrame.new(0,-0.355,-0.94) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(90))
local weld = Instance.new("WeldConstraint",handle)
weld.Part0 = rightHand weld.Part1 = handle
weld.Name = "HandleWeld"


local prefix = "rbxassetid://"
local sounds = {
	["Lunge"] = {6819424086, 70, 1.65},
	["Swing"] = {2778868681, 70, 1.18},
	["Block"] = {5501600429, 70, 1.5},
	["Teleport"] = {9125991715, 120, 1.36},
	["Fatigue"] = {9113587898, 50, 1.2},
	["CryOne"] = {9114569607, 250, 2},
	["CryTwo"] = {9114569442, 250, 2}
}

for wAction, soundSettings in pairs (sounds) do
	local sound = Instance.new("Sound", handle)
	sound.SoundId = prefix.. tostring(soundSettings[1])
	sound.RollOffMaxDistance = soundSettings[2]
	sound.Volume = soundSettings[3]
	sound.Name = wAction.. "Sound"
	sounds[wAction] = sound
end

local crySounds = {
	sounds["CryOne"],
	sounds["CryTwo"]
}

local currentCry = 1
local lastAction = "Nothing"

local plr = game.Players:WaitForChild(char.Name)
local Backpack = plr:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")
local values = Scripts:WaitForChild("values") 
local killerAction = values:WaitForChild("KillerAction")

killerAction.Changed:Connect(function()
	if killerAction.Value == "Nothing" and lastAction == "NurseTeleport" then
		local thisCrySound = crySounds[currentCry]
		
		currentCry += 1
		
		if currentCry > 2 then
			currentCry = 1
		end
		
		thisCrySound.TimePosition = 0
		thisCrySound.Playing = true
	end
	
	if killerAction.Value == "NurseTeleport" then
		sounds["Teleport"].Playing = true
		sounds["Teleport"].TimePosition = 0
	end
	
	if killerAction.Value == "NurseFatigue" then
		currentCry = 1
		sounds["Fatigue"].TimePosition = 0
		sounds["Fatigue"].Playing = true
	end
	
	lastAction = killerAction.Value
end)