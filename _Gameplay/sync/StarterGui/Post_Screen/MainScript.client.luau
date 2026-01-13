-- Easy plug for now to be inserted into system at later data -- cheeta
local Teams = game:GetService('Teams')
local UserInputService = game:GetService('UserInputService')
local Camera = workspace.CurrentCamera
local Mouse = game.Players.LocalPlayer:GetMouse()

local Game_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data')

local Main_Hud, Spectate = script.Parent:WaitForChild('HUD'), script.Parent:WaitForChild('SPECTATE')
local Caption = script.Parent:WaitForChild("Caption")

local prev, next = Spectate:WaitForChild('LeftArrow'), Spectate:WaitForChild('RightArrow')
local Current_List, Current_Index = {}, 1

local image_surv, image_killer = "rbxassetid://18430122135", "rbxassetid://18430122420"
local color_surv, color_killer = Color3.new(0.141176, 0.913725, 1), Color3.new(0.705882, 0.105882, 0.12549)

function Update_List()
	local current_survivors, current_killers = game.Teams:WaitForChild('Survivor'):GetPlayers(), game.Teams:WaitForChild('Killer'):GetPlayers()
	
	if script.Parent:GetAttribute("GOD") then

		if #current_survivors + #current_killers ~= #Current_List then

			if #current_survivors + #current_killers > #Current_List then

				for _, Survivor in pairs(current_survivors) do
					if table.find(Current_List, Survivor) then continue end
					table.insert(Current_List, Survivor)
				end

				for _, Killer in pairs(current_killers) do
					if table.find(Current_List, Killer) then continue end
					table.insert(Current_List, Killer)
				end
			elseif #current_survivors + #current_killers < #Current_List then

				for _, Survivor in pairs(Current_List) do
					if table.find(current_survivors, Survivor) then continue end
					table.remove(Current_List, table.find(Current_List, Survivor))
				end

				for _, Killer in pairs(Current_List) do
					if table.find(current_survivors, Killer) then continue end
					table.remove(Current_List, table.find(Current_List, Killer))
				end
			end
		end
	else

		if #current_survivors ~= #Current_List then

			if #current_survivors > #Current_List then --more in team than in the list

				for _, Survivor in pairs(current_survivors) do
					if table.find(Current_List, Survivor) then continue end
					table.insert(Current_List, Survivor)
				end
			elseif #current_survivors < #Current_List then -- less in the team than in the list

				for _, Survivor in pairs(Current_List) do
					if table.find(current_survivors, Survivor) then continue end
					table.remove(Current_List, table.find(Current_List, Survivor))
				end
			end
		end
	end
end

function ChangePlayer(Direction : number)
	Update_List()
	
	if #Current_List <= 0 then return end
	if game.Teams:WaitForChild('Spectator') ~= game.Players.LocalPlayer.Team or not script.Parent.Enabled then return end -- not active yet!

	local function CameraPivot(Character : Model)
		Spectate:WaitForChild('PlayerName').Text = Character.Name
		Camera.CameraSubject = Character
		Camera.CameraType = Enum.CameraType.Custom
	end
	
	if Current_Index + Direction >= #Current_List then
		Current_Index = 1
	elseif Current_Index + Direction <= 0 then
		Current_Index = #Current_List
	else
		Current_Index += Direction
	end
	
	CameraPivot(Current_List[Current_Index].Character)
end

prev.MouseButton1Click:Connect(function()
	ChangePlayer(-1)
end)

next.MouseButton1Click:Connect(function()
	ChangePlayer(1)
end)

Spectate:WaitForChild('Back').MouseButton1Click:Connect(function()
	Spectate.Visible = false
	Main_Hud.Visible = true
end)

Main_Hud:WaitForChild('Quit').MouseButton1Click:Connect(function()
	game.Players.LocalPlayer:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild("Match"):WaitForChild("Disconnected").Value = true
end)

Main_Hud:WaitForChild('Spectate').MouseButton1Click:Connect(function()
	Spectate.Visible = true
	Main_Hud.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, proc)

	if not Spectate.Visible then return end
	if proc then return end
	
	if input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.ButtonL1 then
		ChangePlayer(-1)
	elseif input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonR1 then
		ChangePlayer(1)
	end
	
end)

function CraftFrame(Player : Player, Role)
	local Data = Player:FindFirstChild('Data')
	if (Data == nil) then return end
	local New_Frame = script:WaitForChild('Prefab'):WaitForChild(`Template_{Role}`):Clone()
	
	New_Frame.Name = Player.Name
	New_Frame.Parent = Main_Hud.Frame.Players
	
	New_Frame:WaitForChild('User').Text = Player.Name
	
	for _, perk in pairs(Data:WaitForChild('Perks'):WaitForChild(Role):GetChildren()) do
		local perk_slot = perk:GetAttribute("Slot")
		local perk_frame = New_Frame:WaitForChild('Perks'):FindFirstChild(perk_slot)
		if not perk_frame then continue end

		local perk_module = Game_Data:WaitForChild('Perks'):WaitForChild(Role):FindFirstChild(perk.Name)
		if not perk_module then continue end
		perk_module = require(perk_module)

		perk_frame.Image = perk_module.Image
		perk_frame.BackgroundColor3 = perk_module.Colors[perk.Value] or Color3.fromRGB(6, 62, 125)
		perk_frame.Visible = true

		perk_frame.MouseEnter:Connect(function()
			Caption.TitleBackground.Title.Text = perk_module.Name
			Caption.Description.Text = perk_module.Description
			Caption.TitleBackground.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1,perk_module.Colors[perk.Value])})

			Caption.Visible = true

			perk_slot = string.gsub(perk_slot, "Slot", "")
			perk_slot = tonumber(perk_slot)

			if (perk_slot <= 2) then
				Caption.AnchorPoint = Vector2.new(0, 0)
			else
				Caption.AnchorPoint = Vector2.new(1, 0)
			end
			Caption.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
		end)

		perk_frame.MouseLeave:Connect(function()
			Caption.Visible = false
		end)
	end
end

while task.wait() do
	
	for _, v in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do
		
		if not Main_Hud:WaitForChild('Frame'):WaitForChild('Players'):FindFirstChild(v.Name) then
			CraftFrame(v, "Survivor")
		end
	end

	for _, v in pairs(game.Teams:WaitForChild('Killer'):GetPlayers()) do

	if not Main_Hud:WaitForChild('Frame'):WaitForChild('Players'):FindFirstChild(v.Name) then
		CraftFrame(v, "Killer")
		end
	end
	
	local Points = if game.Players.LocalPlayer:GetAttribute("Earned_Points") then math.floor(game.Players.LocalPlayer:GetAttribute('Earned_Points')) else 0
	
	if game.Players.LocalPlayer.Team == game.Teams:WaitForChild("Survivor") then
		local Rank = math.round(Points/2500)
		Main_Hud:WaitForChild('Frame'):WaitForChild('BLOOD').Text = `BLOOD EARNED: {Points} (Rank progress has increased by {Rank})`
	elseif game.Players.LocalPlayer.Team == game.Teams:WaitForChild("Killer") then
		local Rank = math.round(Points/1900)
		Main_Hud:WaitForChild('Frame'):WaitForChild('BLOOD').Text = `BLOOD EARNED: {Points} (Rank progress has increased by {Rank})`
	else
		break
	end
end