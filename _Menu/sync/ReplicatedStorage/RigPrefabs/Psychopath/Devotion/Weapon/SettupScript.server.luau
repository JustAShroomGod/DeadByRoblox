local char = script.Parent.Parent
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")
local rightHand = char:WaitForChild("RightHand")
local handle = script.Parent:WaitForChild("Handle")

handle.CFrame = rightHand.CFrame * CFrame.new(0,-0.355,-0.94) * CFrame.Angles(math.rad(-90),math.rad(-90),math.rad(0))
local weld = Instance.new("WeldConstraint",handle)  
weld.Part0 = rightHand weld.Part1 = handle weld.Name = "HandleWeld" 
local prefix = "rbxassetid://"

local sounds = {
	Lunge = {6819424086, 70, 1.92}
	,Swing = {6819422295, 70, 3}
	,SwingVoice = {6817553539, 70, 3}
	,Block = {5501600429, 70, 1.5}
}

for wAction, soundSettings in pairs (sounds) do 
	local sound = Instance.new("Sound", handle) sound.SoundId = prefix.. tostring(soundSettings[1])
	sound.RollOffMaxDistance = soundSettings[2] sound.Volume = soundSettings[3] sound.Name = wAction.. "Sound"
	sounds[wAction] = sound
end

sounds.SwingVoice.Parent = char.Head

local function instantiate_sound(id, parent)
	local sound = Instance.new("Sound", parent)
	sound.Volume = 4
	sound.SoundId = prefix.. tostring(id)
	sound:Play()

	return sound
end

local ids = {
	frenzy_stop1 = 6817549581
	,frenzy_stop2 = 6817627246
}

local u = 1
