local char = script.Parent.Parent
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")
local rightHand = char:WaitForChild("RightHand")
local handle = script.Parent:WaitForChild("Handle")

metaOffset= CFrame.new(0,-0.1,-0.5) * CFrame.Angles(math.rad(0),math.rad(-90),math.rad(25))
--handle.CFrame = metaCFrame
local weld = Instance.new("Weld", handle)
weld.C0 = metaOffset
weld.Part0 = rightHand 
weld.Part1 = handle 
weld.Name = "HandleWeld" 

local prefix = "rbxassetid://"
local sounds = {
	["Lunge"] = {2808418773, 70, 1.5},
	["Swing"] = {2536554902, 70, 1.18},
	["Block"] = {5501600429, 70, 1.5}
}


for wAction, soundSettings in pairs (sounds) do 
	local sound = Instance.new("Sound", handle)
	sound.SoundId = prefix.. tostring(soundSettings[1])
	sound.RollOffMaxDistance = soundSettings[2]
	sound.Volume = soundSettings[3]
	sound.Name = wAction.. "Sound"
	sounds[wAction] = sound
end
