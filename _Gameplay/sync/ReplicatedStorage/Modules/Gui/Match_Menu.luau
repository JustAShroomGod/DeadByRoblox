local TweenService : TweenService, ReplicatedStorage : ReplicatedStorage, Players : Players, Teams : Teams, UserInputService : UserInputService = game:GetService("TweenService"), game:GetService("ReplicatedStorage"), game:GetService("Players"), game:GetService("Teams"), game:GetService("UserInputService")

local Game_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data')

local Disconnected = Players.LocalPlayer.Backpack:WaitForChild("Scripts"):WaitForChild("values"):WaitForChild("Match"):WaitForChild("Disconnected")
local Module = {}

local Tier_Image = {
	"rbxassetid://9498500529";
	"rbxassetid://9498500370";
	"rbxassetid://9498500167";
}

local function UpdateTween(Frame : Frame, DesiredTransparency : number)
	local Tween = TweenService:Create(Frame, TweenInfo.new(0.25), {ImageTransparency = DesiredTransparency})
	
	Tween:Play()
end

local function UpdatePerks(SelectedPlayer : Player, Side : string, New_Frame : Frame, Current_UI : Frame)
	local Data = SelectedPlayer:FindFirstChild('Data')
	local Caption : Frame = Current_UI.Parent:WaitForChild("Caption")
	
	for _, DesiredPerk in pairs(Data:WaitForChild('Perks'):WaitForChild(Side):GetChildren()) do
		local Perk_Slot = DesiredPerk:GetAttribute("Slot")
		local Perk_Frame = New_Frame:WaitForChild('Perks'):FindFirstChild(Perk_Slot)
		if not Perk_Frame then continue end

		local Perk_Module = Game_Data:WaitForChild('Perks'):WaitForChild(Side):FindFirstChild(DesiredPerk.Name)
		if not Perk_Module then continue end
		Perk_Module = require(Perk_Module)

		Perk_Frame.PerkImage.Image = Perk_Module.Image
		Perk_Frame.Blackout.ImageColor3 = Perk_Module.Colors[DesiredPerk.Value] or Color3.fromRGB(6, 62, 125)
		Perk_Frame.PerkTier.Image = Tier_Image[DesiredPerk.Value] or Tier_Image[1]
		
		Perk_Frame.MouseEnter:Connect(function()
			Caption.TitleBackground.Title.Text = Perk_Module.Name
			Caption.Description.Text = Perk_Module.Description
			Caption.TitleBackground.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1,Perk_Module.Colors[DesiredPerk.Value])})

			Caption.Visible = true

			Perk_Slot = string.gsub(Perk_Slot, "Slot", "")
			Perk_Slot = tonumber(Perk_Slot)

			if (Perk_Slot <= 2) then
				Caption.AnchorPoint = Vector2.new(0, 0)
			else
				Caption.AnchorPoint = Vector2.new(1, 0)
			end
			
			Caption.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
		end)

		Perk_Frame.MouseLeave:Connect(function()
			Caption.Visible = false
		end)
	end
end

local function UpdateOffering(SelectedPlayer : Player, Side : string, New_Frame : Frame, Current_UI : Frame)
	local Data = SelectedPlayer:FindFirstChild('Data')
	local Caption : Frame = Current_UI.Parent:WaitForChild("Caption")
	
	local Offering = Data:WaitForChild("Offerings"):WaitForChild(Side)
	local Offering_Module = Game_Data:FindFirstChild('Offerings'):FindFirstChild(Side):FindFirstChild(Offering.Value)
	local Offering_Frame = New_Frame:WaitForChild('Offering'):FindFirstChild("Slot")

	if not Offering_Module then
		return 
	end
	
	Offering_Module = require(Offering_Module)

	Offering_Frame.Icon.Image = Offering_Module.Image
	Offering_Frame.Blackout.ImageColor3 = Offering_Module.Color
	
	Offering_Frame.MouseEnter:Connect(function()
		Caption.TitleBackground.Title.Text = Offering_Module.Name
		Caption.Description.Text = Offering_Module.Description
		Caption.TitleBackground.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1,Offering_Module.Color)})

		Caption.Visible = true

		Caption.AnchorPoint = Vector2.new(1, 0)
		Caption.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
	end)

	Offering_Frame.MouseLeave:Connect(function()
		Caption.Visible = false
	end)
end

local function UpdatePlatform(SelectedPlayer : Player, Side : string, New_Frame : Frame, Current_UI : Frame)
	if SelectedPlayer:GetAttribute("PLATFORM") then
		local platform = SelectedPlayer:GetAttribute("PLATFORM")

		if platform == "Keyboard" then
			New_Frame.Platform.Image = "rbxassetid://14254707430"
		elseif platform == "Console" then
			New_Frame.Platform.Image = "rbxassetid://14254703135"
		elseif platform == "Mobile" then
			New_Frame.Platform.Image = "rbxassetid://14254726313"
		end
	end
end

function Module:AttachConnections(Current_UI, ...)
	local LowerFrame = Current_UI:WaitForChild("LowerFrame")
	local LeaveFrame = LowerFrame:WaitForChild("Leave")
	
	LeaveFrame.MouseEnter:Connect(function()
		UpdateTween(LeaveFrame:WaitForChild("Hover"), 0.6)
	end)
	
	LeaveFrame.MouseLeave:Connect(function()
		UpdateTween(LeaveFrame:WaitForChild("Hover"), 1)
	end)
	
	LeaveFrame:WaitForChild("Button").MouseButton1Click:Connect(function()
		Disconnected.Value = true
	end)
end

function Module:Add(Current_UI ,...) : "Creates Survivor/Killer Ui"
	local args = {...}
		
	local Side : string, SelectedPlayer : Player = args[1], args[2]

	local Prefab = if Side == "Killer" then Current_UI:WaitForChild("MiddleFrame"):WaitForChild("Killer_Prefab") else Current_UI:WaitForChild("MiddleFrame"):WaitForChild("Survivors"):WaitForChild("Prefabs"):WaitForChild("Prefab"):Clone()
	
	Prefab.PlayerName.Text = SelectedPlayer.Name
	
	SelectedPlayer:GetAttributeChangedSignal("PING"):Connect(function()
		Prefab.Ping.Text = tostring(SelectedPlayer:GetAttribute("PING") .. " ms")
	end)
	
	UpdatePlatform(SelectedPlayer, Side, Prefab, Current_UI)
	
	if Side == "Killer" then
		Prefab.Name = SelectedPlayer.Name
		
		if Players.LocalPlayer.Team == Teams[Side] then
			UpdatePerks(SelectedPlayer, Side, Prefab, Current_UI)
			UpdateOffering(SelectedPlayer, Side, Prefab, Current_UI)
		end
	elseif Side == "Survivor" then
		Prefab.Name = SelectedPlayer.Name
		Prefab.Parent = Current_UI:WaitForChild("MiddleFrame"):WaitForChild("Survivors")
		
		if Players.LocalPlayer.Team == Teams[Side] then
			UpdatePerks(SelectedPlayer, Side, Prefab, Current_UI)
			UpdateOffering(SelectedPlayer, Side, Prefab, Current_UI)
		end
	else
		return
	end

	Prefab.Visible = true
end

return Module
