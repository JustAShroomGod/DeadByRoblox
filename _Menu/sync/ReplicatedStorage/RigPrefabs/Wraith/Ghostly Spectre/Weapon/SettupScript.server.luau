local char = script.Parent.Parent
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")
local rightHand = char:WaitForChild("RightHand")
local handle = script.Parent:WaitForChild("Handle")
handle.CFrame = rightHand.CFrame * CFrame.new(0,0,-.5) * CFrame.Angles(math.rad(180),math.rad(15),math.rad(0))

local weld = Instance.new("WeldConstraint",handle)
weld.Part0 = rightHand
weld.Part1 = handle
weld.Name = "HandleWeld" 

local prefix = "rbxassetid://"
local sounds = {
	["Lunge"] = {2912992829, 70, 1.5},
	["Swing"] = {2631249359, 70, 1.5},
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