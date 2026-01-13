local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = game.Players.LocalPlayer
local PlayerUI = Player:WaitForChild('PlayerGui')

local Data = require(ReplicatedStorage.Modules.Data)

local GAME_HUD : ScreenGui = PlayerUI:WaitForChild('HUD')

--local OLD_PROGRESS_BARS = PlayerUI:WaitForChild('ControlsGUI')

local UI_PERKS : Frame = GAME_HUD:WaitForChild('Perk_Display'):WaitForChild('Perks'):WaitForChild('RATIO-MAKER')
local UI_STATUS : Frame = GAME_HUD:WaitForChild('MainHud'):WaitForChild('Status_Display')
local UI_COLLAPSE : Frame = GAME_HUD:WaitForChild('MainHud'):WaitForChild('Collapse_Display')
local UI_CONTROLS : Frame = GAME_HUD:WaitForChild('Controls_Display'):WaitForChild('Controls')
local UI_SKILL_CHECKS : Frame = GAME_HUD:WaitForChild('Controls_Display'):WaitForChild('SkillChecks')
local UI_MOBILE_CONTROLS : Frame = GAME_HUD:WaitForChild('Controls_Display'):WaitForChild('Mobile')
local UI_MOBILE_DEADZONE : Frame = PlayerUI:WaitForChild('Mobile_Dead'):WaitForChild('Deadzone')
local UI_SOURCE : Folder = UI_CONTROLS:WaitForChild('Prefabs')


local UI_PROGRESS : Frame = GAME_HUD:WaitForChild('Controls_Display'):WaitForChild('Progress_Info')
local UI_PROGRESS_BAR : Frame = UI_PROGRESS:WaitForChild('Progress_Holder')

local UI_GAME_INFO = GAME_HUD:WaitForChild('MainHud'):WaitForChild('Game_Display'):WaitForChild('Game_Info')
local UI_PLAYER_FRAMES : Frame = GAME_HUD:WaitForChild('MainHud'):WaitForChild('Player_Display')

local UI_ITEM = GAME_HUD:WaitForChild('MainHud'):WaitForChild('Item_Display')

local UI_POINTS = GAME_HUD:WaitForChild("MainHud"):WaitForChild("Points_Display")

local UI_MATCHMENU = GAME_HUD:WaitForChild("MatchMenu")

local ShouldKeepHidden = {} --keeps track of the hidden control uis
local ShouldKeepSpawned = {} --keeps track of the control uis that WILL be active even if you hide everything

local Modules = {
	Perks = require(script:WaitForChild('Perk_Handler'));
	Progress = require(script:WaitForChild('Progress'));
	Frame = require(script:WaitForChild('Player_Frame'));
	Item = require(script:WaitForChild('Item_Handler'));
	Skill = require(script:WaitForChild('Skill_Handler'));
	Status = require(script:WaitForChild('Status_Handler'));
	Points = require(script:WaitForChild("Points_Handler"));
	MatchMenu = require(script:WaitForChild("Match_Menu"));
}

local UI = {
	CurrentUI = {};
	CurrentConnections = {}; -- for mobile optimization
	ProgressBar = Modules.Progress.new(UI_PROGRESS_BAR);
}

local function HandleVisibility(Prompt) -- make hidden interactions
	local ToReturn = true
	
	if string.match(Prompt, "#") then 
		ToReturn = false 
	end
	
	if table.find(ShouldKeepHidden,Prompt) then
		ToReturn = false
	end
	
	return ToReturn
end

function UI:Progress(tobind: IntValue | NumberValue | number | nil, ActionText: string | nil, Attribute: string | nil, BaseValue: number | nil, ReverseColor: boolean | nil) : "Bind Progress Bar to this"
	if tobind then
		UI_PROGRESS.Visible = true
		UI.ProgressBar:NewPercent(tobind) -- bind to this object instead
		
		UI.ProgressBar.Tracking = {
			["BaseValue"] = BaseValue;
			["AttributeName"] = Attribute;
			["Reverse"] = ReverseColor;
		}
		
		if ActionText then
			UI_PROGRESS.ActionText.Text = ActionText:upper()
			UI_PROGRESS.ActionText.Visible = true
		else
			UI_PROGRESS.ActionText.Visible = false
		end
	elseif UI.ProgressBar then
		UI.ProgressBar:NewPercent()
		UI_PROGRESS.Visible = false
	end
end

function UI:Remove(Prompt : string) : "Remove UI"
	if not UI.CurrentUI[Prompt] then return end
	
	UI.CurrentUI[Prompt]:Destroy()
	UI.CurrentUI[Prompt] = nil
	
	if UI.CurrentConnections[Prompt] then
		
		for _, connection in pairs(UI.CurrentConnections[Prompt]) do
			connection:Disconnect() connection = nil
		end
	end
end

function UI:InsertDeadzones(Zones : "table") : "Insert Deadzones"
	local Natural_Zone = {
		Position = UDim2.new(0.125, 0, 0.5, 0);
		Size = UDim2.new(0.33, 0, 1, 0);
	}
	
	local function AddZone(Zone_Data : "Table")
		local Zone = Instance.new('Frame', UI_MOBILE_DEADZONE)
		
		Zone.AnchorPoint = Vector2.new(0.5, 0.5)
		Zone.Size = Zone_Data.Size
		Zone.Position = Zone_Data.Position
		
		Zone.BackgroundTransparency = 0.5
		
		Zone.Visible = false
	end
	
	AddZone(Natural_Zone)
	
	for _, Zone_Data in pairs(Zones) do
		AddZone({
			Position = UDim2.new(Zone_Data.Position[1], 0, Zone_Data.Position[2], 0);
			Size = UDim2.new(Zone_Data.Size[1], 0, Zone_Data.Size[2], 0);
		})
	end
end

function UI:Add(Prompt : string, Key : Enum.KeyCode | Enum.UserInputType | "mobile table", Mobile_Remote) : "Create UI"
	if UI.CurrentUI[Prompt] then return end

	local chosenClone : Frame | ImageButton = nil
	
	if type(Key) == "table" then
		chosenClone = UI_SOURCE:WaitForChild('MobileButton'):Clone()
		
		chosenClone.Size = UDim2.new(Key.Size[1], 0, Key.Size[2], 0)
		chosenClone.Position = UDim2.new(Key.Position[1], 0, Key.Position[2], 0)
		
		chosenClone.Name = Key.Button
		
		chosenClone.Parent = UI_MOBILE_CONTROLS
		chosenClone.Visible = true
		
		UI.CurrentConnections[Prompt] = { -- prevent us from making 1 morbillion connection | optimized
			Down = nil;
			Up = nil;
		}
		
		UI.CurrentConnections[Prompt].Down = chosenClone.MouseButton1Down:Connect(function()
			Mobile_Remote:Fire("Down", chosenClone)
		end)
		
		UI.CurrentConnections[Prompt].Up = chosenClone.MouseButton1Up:Connect(function()
			Mobile_Remote:Fire("Up", chosenClone)
		end)
	else
		local SelectedLength = nil
		
		Key = string.gsub(tostring(Key), "Enum.KeyCode.", "")
		Key = string.gsub(Key, "Enum.UserInputType.", "")
		Key = string.gsub(Key, "Button", "")

		if Key == 'LeftShift' then
			Key = 'Shift'
		elseif Key == 'LeftControl' then
			Key = 'Ctrl'
		elseif string.match(string.lower(Key), 'mouse') then

			if string.match(Key, '1') then
				Key = 'M1'
			else
				Key = 'M2'
			end
		end


		if string.len(Key) >= 6 then
			chosenClone = UI_SOURCE:WaitForChild('LongButton'):Clone()
			SelectedLength = "LongButton"
		elseif string.len(Key) >= 3 then
			chosenClone = UI_SOURCE:WaitForChild('MediumButton'):Clone()
			SelectedLength = "MediumButton"
		else
			chosenClone = UI_SOURCE:WaitForChild('ShortButton'):Clone()
			SelectedLength = "Short"
			if Key == "M1" then
				chosenClone:WaitForChild("MouseButton1").Visible = true
				chosenClone:WaitForChild("Button").Visible = false
			elseif Key == "M2" then
				chosenClone:WaitForChild("MouseButton2").Visible = true
				chosenClone:WaitForChild("Button").Visible = false
			end
		end
		
		
		chosenClone.Visible = HandleVisibility(Prompt) --if string.match(Prompt, "#") then false else true -- make hidden interactions
		chosenClone:WaitForChild('Button'):WaitForChild('Key').Text = Key
		chosenClone.Name = Prompt
		chosenClone.Parent = UI_CONTROLS
		
		if Prompt == "#HIT SKILL" then
			if not GAME_HUD:FindFirstChild("SkillCheck"):FindFirstChild(Prompt) then return end
			
			local ControlsSkillCheck = GAME_HUD:FindFirstChild("SkillCheck"):FindFirstChild("Controls")

			if Key == "M1" then
				ControlsSkillCheck:FindFirstChild(SelectedLength):WaitForChild("MouseButton1").Visible = true
				ControlsSkillCheck:FindFirstChild(SelectedLength):WaitForChild("Button").Visible = false
			elseif Key == "M2" then
				ControlsSkillCheck:FindFirstChild(SelectedLength):WaitForChild("MouseButton2").Visible = true
				ControlsSkillCheck:FindFirstChild(SelectedLength):WaitForChild("Button").Visible = false
			else
				ControlsSkillCheck:FindFirstChild(SelectedLength):WaitForChild('Button'):WaitForChild('Key').Text = Key
			end

			ControlsSkillCheck:FindFirstChild(SelectedLength).Visible = true
		end
	end
	
	if not UI.CurrentUI[Prompt] then
		UI.CurrentUI[Prompt] = chosenClone
	else
		chosenClone:Destroy()
		return
	end

	Prompt = string.gsub(Prompt, "#", "")
	
	chosenClone:WaitForChild('Action').Text = Prompt
	
	return chosenClone
end

function UI:Hide(hidden : boolean) : "Hide Controls"
	for _,Control in pairs(UI_CONTROLS:GetChildren()) do
		if table.find(ShouldKeepSpawned,Control.Name) then continue end
		if not Control:IsA("Frame") then continue end
		if string.match(Control.Name, "#") then continue end
		if string.find(Control.Name, "Manipulate Time") then continue end -- Have to make an exception cuz stuff like vaulting would hide it
		
		Control.Visible = not hidden
	end
end

function UI:HideSpecific(ActionName : string, hidden : boolean)
	if hidden then
		if not table.find(ShouldKeepHidden,ActionName) then
			table.insert(ShouldKeepHidden,ActionName)
		end
	else
		if table.find(ShouldKeepHidden,ActionName) then
			table.remove(ShouldKeepHidden, table.find(ShouldKeepHidden,ActionName))
		end
	end
	
	if UI_CONTROLS:FindFirstChild(ActionName) then
		UI_CONTROLS:FindFirstChild(ActionName).Visible = not hidden
	end
end

function UI:AlwaysShowSpecific(ActionName : string, keep : boolean)
	if keep then
		if not table.find(ShouldKeepSpawned,ActionName) then
			table.insert(ShouldKeepSpawned,ActionName)
		end
	else
		if table.find(ShouldKeepSpawned,ActionName) then
			table.remove(ShouldKeepSpawned, table.find(ShouldKeepSpawned,ActionName))
		end
	end
end

function UI:ChangeName(ActionName : string, Prompt : string)
	if UI_CONTROLS:FindFirstChild(ActionName) then
		UI_CONTROLS:FindFirstChild(ActionName):WaitForChild('Action').Text = Prompt
	end
end

function UI:UpdateGame(control_scheme : "Controller" | "Mobile" | "Keyboard") : "Updates Game Info and reposition Hud"
	
	if control_scheme == "Mobile" then
		GAME_HUD:WaitForChild('Perk_Display').Position = UDim2.new(0.41, 0, 0.75, 0)
		GAME_HUD:WaitForChild('MainHud'):WaitForChild('Player_Display').Position = UDim2.new(0.025, 0, 0.1, 0)
		UI_GAME_INFO.Parent.Position = UDim2.new(0.025, 0, 0.5, 0)
		UI_ITEM.Position = UDim2.new(0.025, 0, 0.6, 0)
		UI_PROGRESS.Position = UDim2.new(0.5, 0, -0.25,0)

		UI_SKILL_CHECKS.Position = UDim2.new(.5,0,.75,0)
		UI_SKILL_CHECKS.Size = UDim2.new(1.15,0,3.5,0)
		
		if not GAME_HUD:WaitForChild('Perk_Display'):WaitForChild('Perks'):WaitForChild('RATIO-MAKER'):FindFirstChild("UIListLayout") then
			local l = Instance.new('UIListLayout', GAME_HUD:WaitForChild('Perk_Display'):WaitForChild('Perks'):WaitForChild('RATIO-MAKER'))
			l.VerticalAlignment = Enum.VerticalAlignment.Bottom
			l.HorizontalAlignment = Enum.HorizontalAlignment.Center
			l.FillDirection = Enum.FillDirection.Horizontal
		end
	else
		GAME_HUD:WaitForChild('Perk_Display').Position = UDim2.new(0.8, 0,0.75, 0)
		GAME_HUD:WaitForChild('MainHud'):WaitForChild('Player_Display').Position = UDim2.new(0.042, 0, 0.31, 0)
		UI_GAME_INFO.Parent.Position = UDim2.new(0.025, 0, 0.72, 0)
		UI_ITEM.Position = UDim2.new(0.025, 0, 0.825, 0)
		UI_PROGRESS.Position = UDim2.new(0.5, 0, 0.08,0)
		
		UI_SKILL_CHECKS.Position = UDim2.new(0.5,0,0,0)
		UI_SKILL_CHECKS.Size = UDim2.new(1.5,0,2,0)
		
		if GAME_HUD:WaitForChild('Perk_Display'):WaitForChild('Perks'):WaitForChild('RATIO-MAKER'):FindFirstChild("UIListLayout") then
			GAME_HUD:WaitForChild('Perk_Display'):WaitForChild('Perks'):WaitForChild('RATIO-MAKER'):FindFirstChild("UIListLayout"):Remove()
		end
	end
	
	local GeneratorsLeft = (5 - workspace:WaitForChild('MatchValues'):WaitForChild('GeneratorsRepaired').Value)
	
	if GeneratorsLeft > 0 then -- need to repair generators still
		UI_GAME_INFO:WaitForChild('Generator'):WaitForChild('GenCount').Text = GeneratorsLeft
		UI_GAME_INFO:WaitForChild('Generator').Visible = true
		UI_GAME_INFO:WaitForChild('ExitGate').Visible = false
	else
		UI_GAME_INFO:WaitForChild('Generator').Visible = false
		UI_GAME_INFO:WaitForChild('ExitGate').Visible = true
	end
	
	GAME_HUD:WaitForChild('MainHud'):WaitForChild('Game_Display').Visible = true
	
	if workspace:WaitForChild("Hatch") then
		if workspace:WaitForChild("Hatch"):GetAttribute("State") == "Open" then
			UI_GAME_INFO:WaitForChild("Hatch").Visible = true
		else
			UI_GAME_INFO:WaitForChild("Hatch").Visible = false
		end
	end
end

function UI:UpdateSurvivors(...) : "Update Survivor Frames" -- frame, player for now
	
	for _, Survivor in pairs(ReplicatedStorage:WaitForChild('Match'):WaitForChild('Players'):GetChildren()) do
		if Survivor:GetAttribute("Team") ~= "Survivor" then continue end -- not a survivor!
		
		if not UI_PLAYER_FRAMES:FindFirstChild(Survivor.Name) then
			local New_Frame = UI_PLAYER_FRAMES:WaitForChild('Template'):WaitForChild('Source'):Clone()
			New_Frame.Name = Survivor.Name
			New_Frame.Parent = UI_PLAYER_FRAMES
			New_Frame.Visible = true
		end
		
		Modules.Frame:Update(UI_PLAYER_FRAMES:WaitForChild(Survivor.Name), Survivor, ...)
	end
end

function UI:UpdateChaseClaws(...) : "Update Chase Claws Frames"
	for _, Survivor in pairs(ReplicatedStorage:WaitForChild('Match'):WaitForChild('Players'):GetChildren()) do
		if Survivor:GetAttribute("Team") ~= "Survivor" then continue end -- not a survivor!
		
		if not UI_PLAYER_FRAMES:FindFirstChild(Survivor.Name) then continue end
		
		Modules.Frame:UpdateChaseClaws(UI_PLAYER_FRAMES:WaitForChild(Survivor.Name), Survivor)
	end
end

function UI:UpdatePlayers_GameMenu(...) : "Update Player Frames for Game Menu"
	for _, Player_GameMenu in pairs(game:GetService("Players"):GetPlayers()) do
		local Team = Player_GameMenu.Team
		local MiddleFrame = UI_MATCHMENU:WaitForChild("MiddleFrame")
		
		if MiddleFrame:WaitForChild("Survivors"):FindFirstChild(Player_GameMenu.Name) then return end -- already exists
		if MiddleFrame:FindFirstChild(Player_GameMenu.Name) then return end -- already exists
		
		Modules.MatchMenu:Add(UI_MATCHMENU, Team.Name, Player_GameMenu)
	end
	
	Modules.MatchMenu:AttachConnections(UI_MATCHMENU)
end

function UI:UpdatePerks(...) : "Update Perk Frame"
	local args = {...}
	local playerValues = args[1]
	local PerkList = nil
	
	if playerValues.IsKiller.Value then
		PerkList = Data:GetPerks("Killer")
	else
		PerkList = Data:GetPerks("Survivor")
	end
	
	for PerkName, PerkData in pairs(PerkList) do
		local Frame = UI_PERKS:FindFirstChild(PerkData.Slot)
		
		local Perk_Info = {
			Name = PerkName;
			Tier = PerkData.Tier;
		}
		
		if Perk_Info
			and Perk_Info.Tier
			and Frame
			and Perk_Info.Name ~= "" and Perk_Info.Name ~= " " then
			
			Frame.Visible = true
			Modules.Perks:Update(Frame, Perk_Info, playerValues)
		elseif Frame then
			Frame.Visible = false
		end
	end
end

function UI:UpdateItem(...) : "Updates Item Image"
	local args = {...}
	
	Modules.Item:Update(UI_ITEM, args[1])
end

function UI:UpdateSkill(Control_Type : "Controller" | "Mobile" | "Keyboard") : "Update Skill Checks"
	local skillchecks = Modules.Skill:GetSkills()
	
	for skillName, skillObject in pairs(skillchecks) do
		skillObject:Update(Control_Type) -- update all skill checks
	end
end

function UI:UpdateStatus(...)
	local args = {...}
	
	Modules.Status:Update(UI_STATUS, args[1]) -- status frame and player values
end

function UI:CreateSkill(...)
	return Modules.Skill.new(...)
end

function UI:UpdateCollapse() : "Update Endgame Collapse Screen"
	if not workspace:GetAttribute("Endgame") then return end -- do nothing
	local collapse_info = string.split(workspace:GetAttribute("Endgame"), ':')

	local function shake()
		local humanoid = Player.Character.Humanoid
		local PreviousOffset = humanoid.CameraOffset
		for i = 1, 30 do
			local x = math.random(-50, 50)/200
			local y = humanoid.CameraOffset.Y
			local z = math.random(-50, 50)/200
			humanoid.CameraOffset = Vector3.new(x,y,z)
			wait(.01)
			humanoid.CameraOffset = PreviousOffset
		end
	end

	if collapse_info then
		local current_elapsed, total_elapsed = collapse_info[1], collapse_info[2]
		
		UI_COLLAPSE:WaitForChild('Progress').Size = UDim2.new(math.clamp(1 - (current_elapsed/total_elapsed), 0, 1), 0, 1, 0)
		UI_COLLAPSE.Visible = true

		if workspace:GetAttribute("Endgame_Modifier") == "Normal" and not UI_COLLAPSE:WaitForChild("Progress"):WaitForChild("Normal").Enabled then
			UI_COLLAPSE:WaitForChild("Progress"):WaitForChild("Normal").Enabled = true
			UI_COLLAPSE:WaitForChild("Progress"):WaitForChild("Slow").Enabled = false
		elseif workspace:GetAttribute("Endgame_Modifier") == "Slow" and not UI_COLLAPSE:WaitForChild("Progress"):WaitForChild("Slow").Enabled then
			UI_COLLAPSE:WaitForChild("Progress"):WaitForChild("Normal").Enabled = false
			UI_COLLAPSE:WaitForChild("Progress"):WaitForChild("Slow").Enabled = true
		end
	else
		UI_COLLAPSE.Visible = false
	end
end

function UI:CreatePoints(...) : "Create Score Points UI"
	Modules.Points:Add(UI_POINTS, ...)
end

return UI
