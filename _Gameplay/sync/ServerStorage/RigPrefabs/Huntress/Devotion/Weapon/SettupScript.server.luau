local char = script.Parent.Parent
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")
local rightHand = char:WaitForChild("RightHand")
local handle = script.Parent:WaitForChild("Handle")



weld = nil
function UpdateCFrame()
	if weld then weld:Destroy() end

	local AngleOffset = script.Parent:GetAttribute("AngleOffset")
	script.Parent:WaitForChild("Handle").CFrame = char:WaitForChild("RightHand").CFrame
		*CFrame.new(script.Parent:GetAttribute("PositionOffset"))
		*CFrame.Angles(math.rad(AngleOffset.X), math.rad(AngleOffset.Y), math.rad(AngleOffset.Z))

	weld = Instance.new("WeldConstraint", script.Parent:WaitForChild("Handle"))
	weld.Name = "HandleWeld"
	weld.Part0 = char:WaitForChild("RightHand")
	weld.Part1 = script.Parent:WaitForChild("Handle")
end
UpdateCFrame()
script.Parent:GetAttributeChangedSignal("AngleOffset"):Connect(function ()
	UpdateCFrame()
end)
script.Parent:GetAttributeChangedSignal("PositionOffset"):Connect(function ()
	UpdateCFrame()
end)






local prefix = "rbxassetid://"
local sounds = {
	["Lunge"] = {6819424086, 70, 1.5},
	["Swing"] = {6819422295, 70, 1.5},
	["Block"] = {5501600429, 70, 1.5}
}

for wAction, soundSettings in pairs(sounds) do
	local sound = Instance.new("Sound", script.Parent:WaitForChild("Handle"))
	sound.SoundId = prefix.. tostring(soundSettings[1])
	sound.RollOffMaxDistance = soundSettings[2]
	sound.Volume = soundSettings[3]
	sound.Name = wAction.. "Sound"
	sounds[wAction] = sound
end
