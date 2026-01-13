local Player = game:GetService("Players"):WaitForChild(script.Parent.Parent.Name)
local Character = Player.Character

local Weapon = script.Parent
local Weld = Instance.new('Motor6D', Weapon)
Weld.Parent = Weapon
Weld.Part1 = Weapon:WaitForChild('Handle')

local Weld_Settings = {
	Hand = CFrame.new(0, -0.5, 0.35) * CFrame.Angles(math.rad(35), math.rad(-180), math.rad(90));
	Torso = CFrame.new(-0.85, -0.5, -0.35) * CFrame.Angles(0, 0, math.rad(-90));
}

function State_Change()
	local State = Weapon:GetAttribute("State")

	if State == "IDLE" then
		Weld.Part0 = Character:WaitForChild('LowerTorso')
		Weld.C0 = Weld_Settings.Torso
	elseif State == "AIM" then
		Weld.Part0 = Character:WaitForChild('LeftHand')
		Weld.C0 = Weld_Settings.Hand
	end
end

State_Change()

Weapon:GetAttributeChangedSignal('State'):Connect(State_Change)
