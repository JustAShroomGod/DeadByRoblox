local TweenService, PlayerService = game:GetService("TweenService"), game:GetService("Players")

local Prefix = "rbxassetid://"
local HookTallyImages = {0, 6309179649, 6309179649, 0}

local Modules = {
	ProfileDependency = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Profile_Images'));
	ProgressDependency = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Gui'):WaitForChild('Progress'));
	RadialDependency = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Circle_Dependency'));
	Code = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'));
}

local TweenInfo_Claws = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local Module = {}

local function GetState(Values, stringValue : StringValue, Character)

	if stringValue:GetAttribute("Escaped") then
		return "Escaped"
	elseif stringValue:GetAttribute("Dead") then
		return 'Dead'
	elseif Values.Action.Value == "Trapped" then
		return "Trapped"
	elseif Values.Holded.Value == true or Values.Action.Value == "GettingCarried" then
		return "Carried"
	elseif Values.Hooked.Value then
		return "Hooked"
	elseif Values.HealthState.Value <= 0 then
		return "Downed"
	elseif Values.HealthState.Value == 1 then
		return "Injured"
	else
		return "Normal"
	end
end

local function GetProgressType(Values, stringValue : StringValue, Character)
	if not Character then return nil, nil end
	
	local MaxProgress, CurrentMultiplier = 1000, 1

	local HookAmount = if Character:GetAttribute("Hook_Blood") then string.split(Character:GetAttribute("Hook_Blood"), ':') else {1000, 1000}
	local BleedAmount = if Character:GetAttribute("Blood") then Character:GetAttribute("Blood"):split(':') else {1000, 1000}
	local Gash, GashAmount = if Character:GetAttribute("Gash") then Character:GetAttribute("Gash"):split(':') else false, 0
	
	GashAmount = if Gash then math.clamp((tonumber(Gash[1])/tonumber(Gash[2])) * 1000, 0, 1000) else 0
	HookAmount = (tonumber(HookAmount[1]/tonumber(HookAmount[2]))) * 1000
	BleedAmount = (tonumber(BleedAmount[1])/tonumber(BleedAmount[2])) * 1000

	if stringValue:GetAttribute("Dead") then
		return nil, nil
	elseif Values.Hooked.Value then -- hooked progress
		return HookAmount, Color3.fromRGB(255, 5, 5)
	elseif Values.HealthState.Value <= 0 then -- bleed out progress
		return BleedAmount, Color3.fromRGB(255, 10, 10)
	elseif Gash then -- mending progress
		return GashAmount, Color3.fromRGB(255, 164, 16)
	end

	return nil, nil
end

local function IsBroken(Survivor : Player)
	local Broken = Modules.Code:GetEffect("Broken", Survivor)
	
	if Broken and Broken.Active then
		return true
	end

	return false
end

local function IsBound(Character : Model) : "Returns if soul-bound for reaper"
	if not Character then return false end
	local bound_attribute = Character:GetAttribute("Soul_Bound")
	
	if bound_attribute then
		local bound_table = string.split(bound_attribute, ":")
		local TimeElapsed, TotalTime = workspace:GetServerTimeNow() - tonumber(bound_table[2]), tonumber(bound_table[1])
		local TimeLeft = 100 - math.clamp(TimeElapsed, 0, TotalTime)/TotalTime * 100
		
		if TimeLeft > 0 then
			return true, TimeLeft
		else
			return false, 0
		end
	end
	
	return false, 0
end


local function IsDarkness(Character : Model) : "Returns if darkness for phantasm"
	if not Character then return false end
	local darkness_attribute = Character:GetAttribute("DarknessTimer")
	
	if darkness_attribute then
		local darkness_table = string.split(darkness_attribute, ":")
		local TimeElapsed, TotalTime = workspace:GetServerTimeNow() - tonumber(darkness_table[2]), tonumber(darkness_table[1])
		local TimeLeft = 100 - math.clamp(TimeElapsed, 0, TotalTime)/TotalTime * 100

		if TimeLeft > 0 then
			return true, TimeLeft
		else
			return false, 0
		end
	end

	return false, 0
end


function Module:Update(Frame, RawValue, ...) : "Update Survivor Frames" -- frame, player for now
	local args = {...} -- raw_character_stringvalue

	local PlayerImage = Frame:WaitForChild('PictureSection')
	local PlayerName = Frame:WaitForChild('PlayerName')
	local Progress_Bar = Frame:WaitForChild('Progress')
	local Status_Frame = Frame:WaitForChild('Status')

	local our_values = args[1]

	local Raw_Player : Player = game.Players:FindFirstChild(RawValue.Name)

	if RawValue and Raw_Player and Raw_Player.Character then
		local Character = Raw_Player.Character
		local Values = Raw_Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values')
		local HookCount = if Character:GetAttribute("Hook_Stage") then string.split(Character:GetAttribute("Hook_Stage"), ':') else {0, 2}
		local Action = Values:WaitForChild("Action").Value

		local CurrentInteractable = nil
		local RadialAction = Modules.RadialDependency.new(PlayerImage:WaitForChild("Action"):WaitForChild("Timer"), 0)
		
		Frame.Visible = true
		PlayerName.Text = Raw_Player.DisplayName

		Status_Frame.Visible = true

		Status_Frame:WaitForChild('Broken').Visible = IsBroken(Raw_Player)

		PlayerImage:WaitForChild("Action").Visible = (not our_values.IsKiller.Value)
		PlayerImage:WaitForChild("Background"):WaitForChild('BGAction').Visible = (not our_values.IsKiller.Value)

		if our_values.IsKiller.Value then
			Status_Frame:WaitForChild("HookCount1"):WaitForChild("Active").Visible = (tonumber(HookCount[1]) >= 1)
			Status_Frame:WaitForChild("HookCount2"):WaitForChild("Active").Visible = (tonumber(HookCount[1]) >= 2)
		else
			Status_Frame:WaitForChild("HookCount1"):WaitForChild("Active").Visible = (tonumber(HookCount[1]) >= 1)
			Status_Frame:WaitForChild("HookCount2"):WaitForChild("Active").Visible = (tonumber(HookCount[1]) >= 2)
		end

		--[[if Raw_Player:GetAttribute("PLATFORM") then
			local platform = Raw_Player:GetAttribute("PLATFORM")

			if platform == "Keyboard" then
				PlayerImage:WaitForChild('Platform').Image = "rbxassetid://14254707430"
			elseif platform == "Console" then
				PlayerImage:WaitForChild('Platform').Image = "rbxassetid://14254703135"
			elseif platform == "Mobile" then
				PlayerImage:WaitForChild('Platform').Image = "rbxassetid://14254726313"
			end

			PlayerImage:WaitForChild("Platform").Visible = true
		else
			PlayerImage:WaitForChild("Platform").Visible = false
		end]]

		if Character:GetAttribute("CurrentInteractable") then
			if PlayerService:FindFirstChild(Character:GetAttribute("CurrentInteractable")) then
				CurrentInteractable = "Player"
			elseif workspace:FindFirstChild(Character:GetAttribute("CurrentInteractable")) then
				if workspace:FindFirstChild(Character:GetAttribute("CurrentInteractable")):GetAttribute("IsInteractable") then
					CurrentInteractable = workspace:FindFirstChild(Character:GetAttribute("CurrentInteractable"))
				end
			end	
		end


		local prog_type, prog_color = GetProgressType(Values, RawValue, Character)
		local state = GetState(Values, RawValue, Character)

		if prog_type then
			Progress_Bar.Visible = true
			local P = Modules.ProgressDependency.new(Progress_Bar, prog_type)
			P:SetColor(prog_color)
		else
			Progress_Bar.Visible = false
		end

		PlayerImage:WaitForChild('Background'):WaitForChild('Obsession').Visible = RawValue:GetAttribute("Obsession")
		
		local isBound, boundProgress = IsBound(Character)
		local isDarkness, darknessProgress = IsDarkness(Character)
		
		if isBound then
			local bound_image = Modules.RadialDependency.new(PlayerImage:WaitForChild('Background'):WaitForChild('Soul_Bound'), boundProgress)
			PlayerImage:WaitForChild('Background'):WaitForChild('Soul_Bound').Visible = true
		else
			PlayerImage:WaitForChild('Background'):WaitForChild('Soul_Bound').Visible = false
		end
		
		if isDarkness then
			local darkness_image = Modules.RadialDependency.new(PlayerImage:WaitForChild('Background'):WaitForChild('Darkness'), darknessProgress)
			PlayerImage:WaitForChild('Background'):WaitForChild('Darkness').Visible = true
		else
			PlayerImage:WaitForChild('Background'):WaitForChild('Darkness').Visible = false
		end
		
		if Action == "Nothing" then
			PlayerImage:WaitForChild("Action"):WaitForChild("Image").Image = ""
			PlayerImage:WaitForChild("Action"):WaitForChild("Timer").Visible = false
		elseif Action == "Repairing" or Action == "ToolBoxRepair" then
			PlayerImage:WaitForChild("Action"):WaitForChild("Image").Image = Prefix.. 9628972813

			if CurrentInteractable ~= nil then
				local Percent = (CurrentInteractable:FindFirstChild("Panel"):FindFirstChild("Progress").Value / 1000) * 100

				RadialAction:NewPercent(Percent)
				PlayerImage:WaitForChild("Action"):WaitForChild("Timer").Visible = true
			end
		elseif Action == "SelfHealing" then
			PlayerImage:WaitForChild("Action"):WaitForChild("Image").Image = Prefix.. 14019254463

			if CurrentInteractable then
				if CurrentInteractable ~= "Player" then return end

				local Percent = (PlayerService:FindFirstChild(Character:GetAttribute("CurrentInteractable")):FindFirstChild("Backpack"):FindFirstChild("Scripts"):FindFirstChild("values"):FindFirstChild("HealProgress").Value / 1000) * 100 
				RadialAction:NewPercent(Percent)
				PlayerImage:WaitForChild("Action"):WaitForChild("Timer").Visible = true
			end
		elseif Action == "GettingHealing" then
			PlayerImage:WaitForChild("Action"):WaitForChild("Image").Image = Prefix.. 14019254463

			if CurrentInteractable then
				if CurrentInteractable ~= "Player" then return end
				
				local Percent = (PlayerService:FindFirstChild(Character:GetAttribute("CurrentInteractable")):FindFirstChild("Backpack"):FindFirstChild("Scripts"):FindFirstChild("values"):FindFirstChild("HealProgress").Value / 1000) * 100
				RadialAction:NewPercent(Percent)
				PlayerImage:WaitForChild("Action"):WaitForChild("Timer").Visible = true
			end
		elseif Action == "MedkitHeal" then
			PlayerImage:WaitForChild("Action"):WaitForChild("Image").Image = Prefix.. 14019254463

			if CurrentInteractable then
				if CurrentInteractable ~= "Player" then return end
				
				local Percent = (PlayerService:FindFirstChild(Character:GetAttribute("CurrentInteractable")):FindFirstChild("Backpack"):FindFirstChild("Scripts"):FindFirstChild("values"):FindFirstChild("HealProgress").Value / 1000) * 100
				RadialAction:NewPercent(Percent)
				PlayerImage:WaitForChild("Action"):WaitForChild("Timer").Visible = true
			end
		elseif Action == "Mending" then
			PlayerImage:WaitForChild("Action"):WaitForChild("Image").Image = Prefix.. 14019254463

			if CurrentInteractable then
				if CurrentInteractable ~= "Player" then return end
				
				local Percent = (PlayerService:FindFirstChild(Character:GetAttribute("CurrentInteractable")):FindFirstChild("Backpack"):FindFirstChild("Scripts"):FindFirstChild("values"):FindFirstChild("MendProgress").Value / 1000) * 100
				RadialAction:NewPercent(Percent)
				PlayerImage:WaitForChild("Action"):WaitForChild("Timer").Visible = true
			end
		elseif Action == "Recover" then
			PlayerImage:WaitForChild("Action"):WaitForChild("Image").Image = Prefix.. 14019254463

			if CurrentInteractable then
				if CurrentInteractable ~= "Player" then return end
				
				local Percent = (PlayerService:FindFirstChild(Character:GetAttribute("CurrentInteractable")):FindFirstChild("Backpack"):FindFirstChild("Scripts"):FindFirstChild("values"):FindFirstChild("HealProgress").Value / 1000) * 100
				
				RadialAction:NewPercent(Percent)
				PlayerImage:WaitForChild("Action"):WaitForChild("Timer").Visible = true
			end
		elseif Action == "ChestSearch" then
			PlayerImage:WaitForChild("Action"):WaitForChild("Image").Image = Prefix.. 14012770577

			if CurrentInteractable then
				local Percent = (CurrentInteractable:FindFirstChild("Panel"):FindFirstChild("Progress").Value / 1000) * 100

				RadialAction:NewPercent(Percent)
				PlayerImage:WaitForChild("Action"):WaitForChild("Timer").Visible = true
			end
		elseif Action == "BreakingTotem" or Action == "CraftingShard" then
			PlayerImage:WaitForChild("Action"):WaitForChild("Image").Image = Prefix.. 14018134291

			if CurrentInteractable then
				local Percent = (CurrentInteractable:FindFirstChild("Panel"):FindFirstChild("Progress").Value / 1000) * 100

				RadialAction:NewPercent(Percent)
				PlayerImage:WaitForChild("Action"):WaitForChild("Timer").Visible = true
			end
		elseif Action == "OpeningGate" then
			PlayerImage:WaitForChild("Action"):WaitForChild("Image").Image = Prefix.. 18656546798

			if CurrentInteractable then
				if not string.match(tostring(CurrentInteractable), "ExitGate") then return end
				
				local Percent = (CurrentInteractable:FindFirstChild("Panel"):FindFirstChild("Progress").Value / 1000) * 100

				RadialAction:NewPercent(Percent)
				PlayerImage:WaitForChild("Action"):WaitForChild("Timer").Visible = true
			end
		else
			PlayerImage:WaitForChild("Action"):WaitForChild("Timer").Visible = false
		end

		if state == 'Injured' or state == 'Downed' then
			PlayerImage:WaitForChild('Splash').Visible = true
			PlayerImage:WaitForChild("Hooked").Visible = false
			PlayerImage:WaitForChild("Dying").Visible = false
		else
			PlayerImage:WaitForChild('Splash').Visible = false
		end

		if state == "Normal" or state == "Injured" then
			Modules.ProfileDependency.new(PlayerImage:WaitForChild('Picture'), Raw_Player.UserId) -- set up the image
			PlayerImage:WaitForChild("Picture").Visible = true
			PlayerImage:WaitForChild("Dying").Visible = false
			PlayerImage:WaitForChild("Carried").Visible = false

			if PlayerImage:WaitForChild('Picture').Image == Prefix..7827542343 then
				PlayerImage:WaitForChild('Picture').Image = Prefix..1316516325
				PlayerImage:WaitForChild("Splash").Visible = false
				PlayerImage:WaitForChild("Hooked").Visible = false
				PlayerImage:WaitForChild("Dying").Visible = false
				PlayerImage:WaitForChild("Carried").Visible = false
				Progress_Bar.Visible = false
			end
		elseif state == "Dead" then
			--PlayerImage:WaitForChild('Picture').Image = Prefix..7827545320
			PlayerImage.Parent:WaitForChild("Progress").Visible = false
			Status_Frame:WaitForChild("Broken").Visible = false
			PlayerImage:WaitForChild("Dead").Visible = true
			PlayerImage:WaitForChild('Picture').Visible = false
			PlayerImage:WaitForChild("Carried").Visible = false
			PlayerImage:WaitForChild("Dying").Visible = false
			PlayerImage:WaitForChild("Hooked").Visible = false
		elseif state == "Downed" then
			PlayerImage:WaitForChild("Dying").Visible = true
			--PlayerImage:WaitForChild('Picture').Image = Prefix.. 1317671960
			PlayerImage:WaitForChild("Picture").Visible = false
			PlayerImage:WaitForChild("Carried").Visible = false
			PlayerImage:WaitForChild("Splash").Visible = false
		elseif state == "Hooked" then
			PlayerImage:WaitForChild("Hooked").Visible = true
			--PlayerImage:WaitForChild('Picture').Image = Prefix.. 1329357128
			PlayerImage:WaitForChild("Dying").Visible = false
			PlayerImage:WaitForChild("Picture").Visible = false
			PlayerImage:WaitForChild("Carried").Visible = false
		elseif state == "Trapped" then
			PlayerImage:WaitForChild("Trapped").Visible = false
			PlayerImage:WaitForChild("Hooked").Visible = false
			--PlayerImage:WaitForChild('Picture').Image = Prefix.. 1329357128
			PlayerImage:WaitForChild("Dying").Visible = false
			PlayerImage:WaitForChild("Picture").Visible = false
			PlayerImage:WaitForChild("Carried").Visible = false
		elseif state == 'Escaped' then
			PlayerImage:WaitForChild("Escaped").Visible = true
			PlayerImage:WaitForChild('Picture').Visible = false
			PlayerImage:WaitForChild("Dying").Visible = false
			PlayerImage:WaitForChild("Hooked").Visible = false
			PlayerImage:WaitForChild("Picture").Visible = false
			PlayerImage:WaitForChild("Dead").Visible = false
			Progress_Bar.Visible = false
		elseif state == "Carried" then
			PlayerImage:WaitForChild("Carried").Visible = true
			PlayerImage:WaitForChild("Dying").Visible = false
			PlayerImage:WaitForChild("Picture").Visible = false
			PlayerImage:WaitForChild("Hooked").Visible = false
		end
	else
		PlayerImage:WaitForChild('Picture').Image = Prefix.. 126321926107819
		PlayerImage:WaitForChild("Picture").Visible = true
		Progress_Bar.Visible = false
		PlayerImage:WaitForChild("Splash").Visible = false
		PlayerImage:WaitForChild("Carried").Visible = false
		PlayerImage:WaitForChild("Hooked").Visible = false
		PlayerImage:WaitForChild("Dying").Visible = false
		PlayerImage:WaitForChild("Carried").Visible = false
		PlayerImage:WaitForChild("Dead").Visible = false
	end
end

function Module:UpdateChaseClaws(Frame, RawValue)
	local PlayerImage = Frame:WaitForChild('PictureSection')

	local Raw_Player : Player = game.Players:FindFirstChild(RawValue.Name)
	
	local ChasedConnection

	if RawValue and Raw_Player and Raw_Player.Character then
		local Character = Raw_Player.Character
		local ObsessionFrame = nil

		if RawValue:GetAttribute("Obsession") then
			ObsessionFrame = PlayerImage:WaitForChild('Background'):WaitForChild('Obsession')
		else
			ObsessionFrame = PlayerImage:WaitForChild('Background'):WaitForChild('ChaseObsession')
		end

		local function StartTween(Object, ForceRotation) --because i have to randomize rotation, it should get picked up by garbagecollector
			local Tween = TweenService:Create(Object, TweenInfo_Claws, {Rotation = if ForceRotation then ForceRotation else math.random(-15,15)})
			
			Tween.Completed:Once(function()
				if Character:GetAttribute("Chased") then
					StartTween(Object)
				end
			end)
			
			Tween:Play()
		end
			
		ChasedConnection = Character:GetAttributeChangedSignal("Chased"):Connect(function()
			if Character:GetAttribute("Chased") then
				if not (RawValue:GetAttribute("Obsession")) then
					ObsessionFrame.Visible = true
				end
				
				StartTween(ObsessionFrame:WaitForChild("Frame1"))
				StartTween(ObsessionFrame:WaitForChild("Frame2"))
			else
				if not (RawValue:GetAttribute("Obsession")) then
					ObsessionFrame.Visible = false
				end
				
				StartTween(ObsessionFrame:WaitForChild("Frame1"), 0)
				StartTween(ObsessionFrame:WaitForChild("Frame2"), 0)
			end
		end)
	end
end

return Module
