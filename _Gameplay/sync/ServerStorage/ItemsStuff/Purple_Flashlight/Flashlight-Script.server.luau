local Item_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Items')
local Item_Module = require(Item_Data:WaitForChild(script.Parent.Name))

local RunService, Loop = game:GetService('RunService'), nil

local Tool : Model = script.Parent
local Character : Model = Tool.Parent
local Player : Player = game.Players:GetPlayerFromCharacter(Character)

local Turned : BoolValue = Tool:WaitForChild('bool')

local Cone = Tool:WaitForChild('Cone')
local Handle = Tool:WaitForChild('Handle')

local Settings = {
	--[[Sounds = {
		Start = Tool.PrimaryPart:WaitForChild('Active');
		Stop = Tool.PrimaryPart:WaitForChild('Deactive');
	},]]--
	DefaultCFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(90), 0);
}

Tool.PrimaryPart.Anchored = false

local Weld = Instance.new('Weld', Tool)
Weld.Part0 = Character:WaitForChild('RightHand')
Weld.Part1 = Tool.PrimaryPart
Weld.C0 = Settings.DefaultCFrame

local lastOn, BugPrevent = 0, 1

local function Bind(deltatime, step)
	local subAmount, current_progress = 1000/(script.Charges.Value/script.Drain.Value), Tool:GetAttribute("Progress") -- produces incremtal number by seconds
	subAmount *= step -- multiplies by time passed

	Tool:SetAttribute('Progress', math.clamp(current_progress - subAmount, 0, 1000))

	if current_progress <= 0 and (workspace:GetServerTimeNow() - lastOn) >= BugPrevent then
		Turned.Value = false
	end
end

local HasDone = false

Turned.Changed:Connect(function()
	local function disconnect()
		if Loop then Loop:Disconnect() Loop = nil end
	end

	if Turned.Value then
		if HasDone == false then HasDone = true
			local Flashlight = script.Parent
			Flashlight['Flashlight-Script'].Drain.Value = Item_Module.Drain
			local Total_Charges = Item_Module.Charges
			local Addon_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Survivor')
			local addon_1, addon_2 = Flashlight:GetAttribute("Addon_1"), Flashlight:GetAttribute("Addon_2")
			local Range = Item_Module.Range
			if addon_1 and addon_1 ~= "" then
				addon_1 = Addon_Data:FindFirstChild(addon_1)

				if addon_1 then
					addon_1 = require(addon_1)

					if addon_1.Charges then
						Total_Charges += addon_1.Charges
					end

					if addon_1.Range then
						Range += addon_1.Range
					end

				end
			end

			if addon_2 and addon_2 ~= "" then
				addon_2 = Addon_Data:FindFirstChild(addon_2)

				if addon_2 then
					addon_2 = require(addon_2)

					if addon_2.Charges then
						Total_Charges += addon_2.Charges
					end

					if addon_2.Range then
						Range += addon_2.Range
					end

				end
			end
			Flashlight['Flashlight-Script'].Charges.Value = Total_Charges
			Flashlight['Flashlight-Script'].Range.Value = Range
		end
		lastOn = workspace:GetServerTimeNow()
		disconnect()
		--Settings.Sounds.Start:Play()
		require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code')):Remote_Sound(Player, 'Flashlight_On')

		-- Makes cone visible for all --
		Cone.Transparency = .9
		Cone.Highlight.OutlineTransparency = .9
		Handle.SpotLight.Brightness = Item_Module.Brightness * 30
		Cone.ParticleEmitter.Transparency = NumberSequence.new(0, 0)
		--Makes cone visible for all --

		Loop = RunService.Stepped:Connect(Bind)
	else
		disconnect()
		require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code')):Remote_Sound(Player, 'Flashlight_Off')

		-- Removing Visuals --
		Cone.Transparency = 1
		Cone.Highlight.OutlineTransparency = 1
		Handle.SpotLight.Brightness = 0
		Cone.ParticleEmitter.Transparency = NumberSequence.new(1,1)
	end
end)