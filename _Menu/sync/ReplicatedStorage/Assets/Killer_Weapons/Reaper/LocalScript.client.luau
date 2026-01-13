local Character = script.Parent.Parent
local Mask = script.Parent:WaitForChild('Reaper_Mask')
local Weapon = script.Parent:WaitForChild('Reaper_Weapon')

local Settings = {
	MaskFrame = CFrame.new(0, 0, -.75) * CFrame.Angles(math.rad(0), math.rad(-90), 0);
	WeaponFrame = CFrame.new(0, .25, 1.825) * CFrame.Angles(math.rad(-90), math.rad(180), 0);
}

local WeaponWeld, MaskWeld = Instance.new('Weld', Weapon), Instance.new('Weld', Mask)

Weapon:PivotTo(Character:WaitForChild('RightHand').CFrame * Settings.WeaponFrame)
WeaponWeld.Part0 = Character:WaitForChild('RightHand')
WeaponWeld.Part1 = Weapon:WaitForChild('Handle')
WeaponWeld.C0 = Settings.WeaponFrame

Mask:PivotTo(Character:WaitForChild('Head').CFrame * Settings.MaskFrame)
MaskWeld.Part0 = Character:WaitForChild('Head')
MaskWeld.Part1 = Mask
MaskWeld.C0 = Settings.MaskFrame