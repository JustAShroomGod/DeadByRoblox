local Missing_Texture = "rbxassetid://13911732202"
local Perk_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Perks')

local Tier_Image = {
	"rbxassetid://9498500529";
	"rbxassetid://9498500370";
	"rbxassetid://9498500167";
}

local warned = {}

local PerkFrame = {
	Modules = {}
}
PerkFrame.__index = PerkFrame

local RadialModule = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Circle_Dependency')) -- used to fill radials

for _,module in pairs(script:GetChildren())do
	PerkFrame.Modules[module.Name] = require(module)
end

function PerkFrame:Update(...) -- recieve perkframe, perkname
	local args = {...}
	local Frame, PerkData, playerValues = args[1], args[2], args[3]
	local Percent, LightOverride, Stacks = 0, 0, 0

	if PerkFrame.Modules[PerkData.Name] then
		Percent, LightOverride = PerkFrame.Modules[PerkData.Name]:GetInfo(PerkData, playerValues)
	else
		Percent, LightOverride = PerkFrame.Modules["Template"]:GetInfo(nil)
	end

	local Background = RadialModule.new(Frame.Background, Percent)

	if (script:FindFirstChild(PerkData.Name) ~= nil) then
		if (script[PerkData.Name]:GetAttribute("Stacks")) then
			Stacks = script[PerkData.Name]:GetAttribute("Stacks")
		end
	end

	if Stacks == 0 then
		Frame.Stacks.Text = ""
	else
		Frame.Stacks.Text = tostring(Stacks)
		Frame.Stacks.ZIndex = 23
	end

	if (Percent >= 100 and LightOverride == 0) or LightOverride == 1 then
		Frame.PerkImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
	else
		Frame.PerkImage.ImageColor3 = Color3.fromRGB(0, 0, 0)
	end

	local Perk_Module = Perk_Data:WaitForChild('Survivor'):FindFirstChild(PerkData.Name)-- Perk_Images:FindFirstChild(PerkData.Name)

	if not Perk_Module then
		Perk_Module = Perk_Data:WaitForChild('Killer'):FindFirstChild(PerkData.Name)
	end

	if Perk_Module then
		Perk_Module = require(Perk_Module)

		Frame.PerkImage.Image = Perk_Module.Image
		Background:SetColor(Perk_Module.Colors[PerkData.Tier])
	else
		if not table.find(warned, PerkData.Name) then
			table.insert(warned, PerkData.Name)
			warn('No Source for', PerkData.Name, '!')
			print(PerkData)
		end

		Frame.PerkImage.Image = Missing_Texture
		Background:SetColor(Color3.fromRGB(255, 255, 255))
	end

	Frame.PerkTier.Image = Tier_Image[PerkData.Tier] or ""
end

return PerkFrame