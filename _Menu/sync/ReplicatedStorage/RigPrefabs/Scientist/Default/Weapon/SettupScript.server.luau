local Character = script.Parent.Parent
local Weapon = script.Parent

local Settings = {
	WeaponFrame = CFrame.new(0, 0, -1.325) * CFrame.Angles(math.rad(-90), math.rad(180), 0);
}

local WeaponWeld = Instance.new('Weld', Weapon)

Weapon:PivotTo(Character:WaitForChild('RightHand').CFrame * Settings.WeaponFrame)
WeaponWeld.Part0 = Character:WaitForChild('RightHand')
WeaponWeld.Part1 = Weapon:WaitForChild('Handle')
WeaponWeld.C0 = Settings.WeaponFrame

local handle = Weapon.Handle

local prefix = "rbxassetid://"

local sounds = {
	["Lunge"] = {9113305631, 70, 1.65},
	["Swing"] = {175024455, 70, 1.18},
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
