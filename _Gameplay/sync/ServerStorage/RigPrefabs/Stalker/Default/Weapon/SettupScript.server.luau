local char = script.Parent.Parent
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")
local rightHand = char:WaitForChild("RightHand")
local handle = script.Parent:WaitForChild("Handle")


handle.CFrame = rightHand.CFrame * CFrame.new(0,-0.355,-0.94) * CFrame.Angles(math.rad(-90),math.rad(-90),math.rad(0))

local weld = Instance.new("WeldConstraint",handle)
weld.Part0 = rightHand
weld.Part1 = handle
weld.Name = "HandleWeld"

local prefix = "rbxassetid://"
local sounds = {
	["Lunge"] = {6819424086, 70, 1.5},
	["Swing"] = {6819422295, 70, 1.18},
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

require(game.ReplicatedStorage.Modules.Code["Status-Handler"]):Set(script.Parent.Parent,"Hidden",-1,"Power_Tier") 
local Hasdone = false
script.Parent.Parent:GetAttributeChangedSignal("Power_Tier"):Connect(function()
	if script.Parent.Parent:GetAttribute("Power_Tier") ~= 1 then
		if Hasdone == false then Hasdone = true else return end
		require(game.ReplicatedStorage.Modules.Code["Status-Handler"]):Set(script.Parent.Parent,"Hidden",nil,"Power_Tier") 
	end
end)

repeat task.wait() until (script.Parent.Parent:FindFirstChild("Humanoid") ~= nil)
local Audio = Instance.new("Sound", workspace)
Audio.Changed:Connect(function()
	Audio.Parent = workspace
end)
Audio.Name = "MYERS_GLOBAL_STALK_SOUND"
Audio.SoundId = "rbxassetid://4307069862"
local Character = script.Parent.Parent
local Settings = 
	{
		[1] = 
		{
			Volume = 0.25,
			Octave = 1.25,
		},
		[2] = 
		{
			Volume = 0.5,
			Octave = 0.5
		},
		[3] = 
		{
			Volume = 0.5,
			Octave = 1
		}
	}
local PreviousTier = 1
local PitchShift = script:WaitForChild("PitchShiftSoundEffect")
PitchShift.Changed:Connect(function()
	PitchShift.Parent = Audio
end)
PitchShift.Parent = Audio
repeat task.wait() until (Character:GetAttribute("Power_Tier") and Character:GetAttribute("Power_Tier") == 1)
Character:GetAttributeChangedSignal("Power_Tier"):Connect(function()
	local Tier = Character:GetAttribute("Power_Tier")
	if PreviousTier == 1 then
		Audio.Volume = Settings[1].Volume
		PitchShift.Octave = Settings[1].Octave
	else
		Audio.Volume = Settings[Tier].Volume
		PitchShift.Octave = Settings[Tier].Octave
	end
	print("Playing Server Audio")
	Audio:Play()
	PreviousTier = Tier
end)
	