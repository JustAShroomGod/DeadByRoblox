local char = script.Parent.Parent
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")
local rightHand = char:WaitForChild("RightHand")
local handle = script.Parent:WaitForChild("Handle")

local weld = handle.Weld
weld.Part0 = rightHand 
weld.Part1 = handle
weld.Name = "HandleWeld"

--weld.C1 = CFrame.new(0, -1.1, 0) * CFrame.Angles(math.rad(90),math.rad(75),math.rad(0))
 
local prefix = "rbxassetid://"
local sounds = {
	["Lunge"] = {2398722505, 70, 1.65},
	["Swing"] = {2398715900, 70, 1.65},
	["Block"] = {5501600429, 70, 1.5}
}

for wAction, soundSettings in pairs(sounds) do
	local sound = Instance.new("Sound", handle)
	sound.SoundId = prefix.. tostring(soundSettings[1])
	sound.RollOffMaxDistance = soundSettings[2]
	sound.Volume = soundSettings[3]
	sound.Name = wAction.. "Sound"
	sounds[wAction] = sound
end
