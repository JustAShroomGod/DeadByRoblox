local Players : Players, ReplicatedStorage : ReplicatedStorage, UserInputService : UserInputService, TweenService : TweenService = game:GetService('Players'), game:GetService('ReplicatedStorage'), game:GetService('UserInputService'), game:GetService("TweenService")

local loadFrame : Frame = script.Parent:WaitForChild('LoadMenu')
local NavigationFrame : Frame = loadFrame:WaitForChild("Navigation")
local PlayersFrame, XboxFrame = loadFrame:WaitForChild('Players'), NavigationFrame:WaitForChild('XBOX')
local State_TextLabel : TextLabel = NavigationFrame:WaitForChild("State")
local Tips_TextLabel : TextLabel = NavigationFrame:WaitForChild("Tips")

local Region_TextLabel : TextLabel = loadFrame:WaitForChild("Region")

local Game_Data = ReplicatedStorage:WaitForChild('Game_Data')

local Remotes = {
	Ready = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Ready');
	BUGREAD = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BUGREAD")
}

local Modules = {
	Skill = require(script:WaitForChild('Skill_Translate'));
	Data = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'));
	Tips = require(script:WaitForChild("Tips"));
}

local Buttons = {
	Leave = NavigationFrame:WaitForChild('Leave');
	Ready = NavigationFrame:WaitForChild('ReadyUp');
}

local Tier_Image = {
	"rbxassetid://9498500529";
	"rbxassetid://9498500370";
	"rbxassetid://9498500167";
}

local Connections = {}

local Picture = require(script:WaitForChild('Profile'))


local function LoadDataToUi(Player : Player, Prefab : Frame)
	--if not Player:FindFirstChild("Data") then return end

	local Data_Folder = Player:FindFirstChild("Data")
	local Player_Team = Player:GetAttribute("Team")
	local Caption : Frame = script.Parent:WaitForChild("Caption")

	if Player_Team == "Killer" then
		if not (Player_Team == Players.LocalPlayer:GetAttribute("Team")) then
			return
		end

		local Item = require(Game_Data:FindFirstChild("Killers"):FindFirstChild(Data_Folder:FindFirstChild("Killer").Value))

		Prefab:FindFirstChild("Item"):FindFirstChild("Main"):FindFirstChild("Icon").Image = Item.Power_Image
		Prefab:FindFirstChild("Item"):FindFirstChild("Main"):FindFirstChild("Icon").BackgroundColor3 = Item.Power_Color

		Prefab:FindFirstChild("Item"):FindFirstChild("Main").MouseEnter:Connect(function()
			Caption.TitleBackground.Title.Text = Item.Power_Name
			Caption.Description.Text = Item.Description
			Caption.TitleBackground.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1,Item.Power_Color)})

			Caption.Visible = true

			Caption.AnchorPoint = Vector2.new(0, 0)
			Caption.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
		end)

		Prefab:FindFirstChild("Item"):FindFirstChild("Main").MouseLeave:Connect(function()
			Caption.Visible = false
		end)
	else
		if Player_Team ~= Players.LocalPlayer:GetAttribute("Team") then 
			return 
		end

		if Game_Data:FindFirstChild("Items"):FindFirstChild(Data_Folder:FindFirstChild("Item").Value) then
			local Item = require(Game_Data:FindFirstChild("Items"):FindFirstChild(Data_Folder:FindFirstChild("Item").Value))
			Prefab:FindFirstChild("Item"):FindFirstChild("Main"):FindFirstChild("Icon").Image = Item.Image
			Prefab:FindFirstChild("Item"):FindFirstChild("Main"):FindFirstChild("Icon").BackgroundColor3 = Item.Color

			Prefab:FindFirstChild("Item"):FindFirstChild("Main").MouseEnter:Connect(function()
				Caption.TitleBackground.Title.Text = Item.Name
				Caption.Description.Text = Item.Description
				Caption.TitleBackground.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1,Item.Color)})

				Caption.Visible = true

				if Player_Team == "Killer" then
					Caption.AnchorPoint = Vector2.new(0, 0)
				else
					Caption.AnchorPoint = Vector2.new(1, 0)
				end
				
				Caption.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
			end)

			Prefab:FindFirstChild("Item"):FindFirstChild("Main").MouseLeave:Connect(function()
				Caption.Visible = false
			end)
		end
	end

	if Player_Team == Players.LocalPlayer:GetAttribute("Team") or (Player == Players.LocalPlayer) then
		for _,Perk in pairs(Data_Folder:FindFirstChild("Perks"):FindFirstChild(Player_Team):GetChildren()) do
			local Perk_Slot = Perk:GetAttribute("Slot")
			local Perk_Module = require(Game_Data:FindFirstChild('Perks'):FindFirstChild(Player_Team):FindFirstChild(Perk.Name))
			local Perk_Ui = Prefab:FindFirstChild("Perks"):FindFirstChild(Perk_Slot)

			Perk_Ui:FindFirstChild("PerkImage").Image = Perk_Module.Image
			Perk_Ui:FindFirstChild("PerkTier").Image = Tier_Image[Perk.Value]
			Perk_Ui:FindFirstChild("Frame1"):FindFirstChild("ImageLabel").ImageColor3 = Perk_Module.Colors[Perk.Value]
			Perk_Ui:FindFirstChild("Frame2"):FindFirstChild("ImageLabel").ImageColor3 = Perk_Module.Colors[Perk.Value]

			Perk_Ui.MouseEnter:Connect(function()
				Caption.TitleBackground.Title.Text = Perk_Module.Name
				Caption.Description.Text = Perk_Module.Description
				Caption.TitleBackground.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1,Perk_Module.Colors[Perk.Value])})

				Caption.Visible = true

				if Player_Team == "Killer" then
					Caption.AnchorPoint = Vector2.new(0, 0)
				else
					Caption.AnchorPoint = Vector2.new(1, 0)
				end

				Caption.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
			end)

			Perk_Ui.MouseLeave:Connect(function()
				Caption.Visible = false
			end)
		end
	end

	for _,Addon in pairs(Data_Folder:FindFirstChild("Addons"):FindFirstChild(Player_Team):GetChildren()) do
		local Addon_Module = require(Game_Data:FindFirstChild('Addons'):FindFirstChild(Player_Team):FindFirstChild(Addon.Value))
		local Addon_Ui = Prefab:FindFirstChild("Item"):FindFirstChild(Addon.Name)

		Addon_Ui:FindFirstChild("Icon").Image = Addon_Module.Image
		Addon_Ui:FindFirstChild("Icon").BackgroundColor3 = Addon_Module.Color

		Addon_Ui.MouseEnter:Connect(function()
			Caption.TitleBackground.Title.Text = Addon_Module.Name
			Caption.Description.Text = Addon_Module.Description
			Caption.TitleBackground.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1,Addon_Module.Color)})

			Caption.Visible = true
			
			if Player_Team == "Killer" then
				Caption.AnchorPoint = Vector2.new(0, 0)
			else
				Caption.AnchorPoint = Vector2.new(1, 0)
			end
			
			Caption.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
		end)

		Addon_Ui.MouseLeave:Connect(function()
			Caption.Visible = false
		end)
	end
end

local function CraftNew(Player) : "Create a new Frame"
	local prefab = loadFrame:WaitForChild('Players'):WaitForChild('Prefab'):WaitForChild('Template'):Clone()
	prefab.Name = Player.Name
	
	if not workspace:GetAttribute("Pro_Enabled") then
		Picture.new(prefab.Profile, Player)
		prefab.PlayerName.Text = Player.Name
	
		LoadDataToUi(Player,prefab)
	end
	
	return prefab
end

local function FindFrame(Player : Player) : "Returns Template Frame Based on Player"
	if not Player then return nil end
	
	for _, template in pairs(loadFrame:WaitForChild('Players'):WaitForChild('Killers'):GetChildren()) do
		
		if template.Name == Player.Name then
			return template
		end
	end
	
	for _, template in pairs(loadFrame:WaitForChild('Players'):WaitForChild('Survivors'):GetChildren()) do
		
		if template.Name == Player.Name then
			return template
		end
	end
end

local function ReturnPlayerOnSide(Team : "Killer/Survivor")
	local Amount = 0 
	
	for _,v in pairs(Players:GetChildren()) do
		if v:GetAttribute("Team",Team) then
			Amount += 1
		end
	end
	
	return Amount
end

local function UpdateTips()
	local TweenOut = TweenService:Create(Tips_TextLabel,TweenInfo.new(0.5),{TextTransparency = 1})
	local TweenIn = TweenService:Create(Tips_TextLabel,TweenInfo.new(0.5),{TextTransparency = 0})
	
	Connections["TweenOut"] = TweenOut.Completed:Connect(function()
		local Tip = nil
		repeat
			if math.random(1,2) == 2 then
				--print(Players.LocalPlayer:GetAttribute("Team"))
				local team = Players.LocalPlayer:GetAttribute("Team") or "Global"
				Tip = Modules.Tips[team][math.random(1,#Modules.Tips[team])]
			else
				Tip = Modules.Tips.Global[math.random(1,#Modules.Tips.Global)]
			end
		until not (Tip == Tips_TextLabel.Text) 
		
		Tips_TextLabel.Text = Tip
		
		Connections["TweenOut"]:Disconnect()
		Connections["TweenOut"] = nil
		
		TweenIn:Play()
	end)

	TweenOut:Play()
end

local function UpdateFrames() : "Removes Old Frames and Updates the Ready/Ping Status of Frames"
	
	-- removing outdating/removed players --
	for _,frame in pairs(loadFrame:WaitForChild('Players'):WaitForChild('Survivors'):GetChildren()) do

		if not Players:FindFirstChild(frame.Name) and frame:IsA('Frame') then
			frame:Destroy()
		end
	end

	for _,frame in pairs(loadFrame:WaitForChild('Players'):WaitForChild('Killers'):GetChildren()) do

		if not Players:FindFirstChild(frame.Name) and frame:IsA('Frame') then
			frame:Destroy()
		end
	end

	XboxFrame.Visible = UserInputService.GamepadEnabled
	
	if not (State_TextLabel.Text == "GAME IS STARTING!") then 
		if ReturnPlayerOnSide("Killer") >= 1 and ReturnPlayerOnSide("Survivor") >= 4 then
			State_TextLabel.Text = "WAITING FOR PLAYERS. (Need 4 survivors to start!)"
		else
			State_TextLabel.Text = "WAITING FOR PLAYERS. (Need 4 survivors to start!)"
		end 
	end
	
	-- Adding Frames --
	for _, Player in pairs(Players:GetChildren()) do
		if not Player:FindFirstChild("Data") then continue end
		if not Player:GetAttribute("Team") then continue end

		local imageFrame = FindFrame(Player)
		
		if not imageFrame then
			imageFrame = CraftNew(Player)
			
			if Player:GetAttribute("Team") == 'Killer' then
				imageFrame.Parent = loadFrame:WaitForChild('Players'):WaitForChild('Killers')
			else
				imageFrame.Parent = loadFrame:WaitForChild('Players'):WaitForChild('Survivors')
			end
			
			if Player:GetAttribute("Team") == "Spectator" then
				imageFrame.Visible = false
			else
				imageFrame.Visible = true
			end
		--else
			--LoadDataToUi(imageFrame,imageFrame)
		end
		
		if Player:GetAttribute("Team") == 'Killer' then
			imageFrame.Parent = loadFrame:WaitForChild('Players'):WaitForChild('Killers')
			
			--[[if not workspace:GetAttribute("Pro_Enabled") then
				imageFrame:WaitForChild('Stat').Text = Modules.Skill:Translate('Kills', Player:GetAttribute("Kills"), 'String')
				imageFrame:WaitForChild('Stat').TextColor3 = Modules.Skill:Translate('Kills', Player:GetAttribute("Kills"), 'Color')
			end]]
		else
			imageFrame.Parent = loadFrame:WaitForChild('Players'):WaitForChild('Survivors')

			--[[if not workspace:GetAttribute("Pro_Enabled") then
				imageFrame:WaitForChild('Stat').Text = Modules.Skill:Translate('Escapes', Player:GetAttribute("Escapes"), 'String')
				imageFrame:WaitForChild('Stat').TextColor3 = Modules.Skill:Translate('Escapes', Player:GetAttribute("Escapes"), 'Color')
			end]]
		end
		
		
		if Player:GetAttribute("READY") then
			imageFrame.Status.TextColor3 = Color3.fromRGB(55, 255, 0)
			imageFrame.Status.Text = 'Ready'
		else
			imageFrame.Status.TextColor3 = Color3.fromRGB(255, 0, 4)
			imageFrame.Status.Text = 'Unready'
		end

		--[[if Player:GetAttribute("PLATFORM") then
			local platform = Player:GetAttribute("PLATFORM")

			if platform == "Keyboard" then
				imageFrame.Platform.Image = "rbxassetid://14254707430"
			elseif platform == "Console" then
				imageFrame.Platform.Image = "rbxassetid://14254703135"
			elseif platform == "Mobile" then
				imageFrame.Platform.Image = "rbxassetid://14254726313"
			end
		end]]
		
		local ping = (Player:GetAttribute("PING") or 0)

		imageFrame.Ping.Text = 'Ping: '..tostring(ping)..' ms'

		if ping <= 90 then
			imageFrame.Ping.TextColor3 = Color3.fromRGB(98, 255, 0)
		elseif ping <= 145 then
			imageFrame.Ping.TextColor3 = Color3.fromRGB(255, 179, 0)
		else
			imageFrame.Ping.TextColor3 = Color3.fromRGB(255, 23, 7)
		end
	end
end

local db = tick()

local function ready()
	if (tick() - db) <= 1 then return end
	db = tick()

	Remotes.Ready:FireServer()

	if Buttons.Ready.BackgroundColor3 == Color3.fromRGB(255, 0, 0) then
		Buttons.Ready.BackgroundColor3 = Color3.fromRGB(50, 127, 1)
		Buttons.Ready.Text = 'Ready Up'
	else
		Buttons.Ready.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		Buttons.Ready.Text = 'Unready'
	end
end

Buttons.Ready.MouseButton1Click:Connect(function()
	ready()
end)


local leaving = false
local lobbyId = 14904820737

local function backout()
	if leaving then return warn('already leaving!') end
	leaving = true
	
	local screen = require(game:GetService("ReplicatedFirst"):WaitForChild('TeleportUI'):WaitForChild('Load')).load()
	
	task.wait(1)
	game:GetService('TeleportService'):Teleport(lobbyId, game.Players.LocalPlayer, {}, screen.object)
end

UserInputService.InputBegan:Connect(function(input, process)
	if not UserInputService.GamepadEnabled then return end
	
	if input.KeyCode == Enum.KeyCode.ButtonA then
		ready()
	elseif input.KeyCode == Enum.KeyCode.ButtonB then
		backout()
	end
end)

Buttons.Leave.MouseButton1Click:Connect(function()
	backout()
end)

Players.LocalPlayer.AttributeChanged:Connect(function(Attribute)
	
	if Attribute == 'FINISHED' and Players.LocalPlayer:GetAttribute("FINISHED") then
		UserInputService.MouseIconEnabled = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		
		repeat task.wait() until ReplicatedStorage.Match.Started.Value
		
		script.Parent:Destroy()
	end
end)

ReplicatedStorage:WaitForChild("Match"):WaitForChild("Region").Changed:Once(function()
	Region_TextLabel.Text = ReplicatedStorage.Match.Region.Value
	Region_TextLabel.Visible = true
end)

Connections["BugRead"] = Remotes.BUGREAD.OnClientEvent:Connect(function(Text)
	if string.match(Text,"Game has begun booting up!") then
		State_TextLabel.Text = "GAME IS STARTING!"
		Connections["BugRead"]:Disconnect()
		Connections["BugRead"] = nil
	end
end)

task.spawn(function()
	while task.wait(.5) do
		if workspace:GetAttribute("TESTING") or workspace:GetAttribute("CUSTOM") then
			if not Buttons.Ready.Visible then
				Buttons.Ready.Visible = true
			end
		end
		
		UpdateFrames() -- update frames
	end
end)

task.spawn(function()
	while task.wait(10) do
		UpdateTips()
	end
end)