local Players : Players,UserInputService : UserInputService, ReplicatedStorage : ReplicatedStorage = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("ReplicatedStorage")

local RemotesArea = ReplicatedStorage:WaitForChild("RemoteEvents")
local AdminEvents = RemotesArea:WaitForChild("AdminEvents")
local DevEvents = RemotesArea:WaitForChild("DevEvents")

local LocalPlayer = Players.LocalPlayer

local OpenPanel = script.Parent:WaitForChild("OpenPanel")
local MainContainer = script.Parent:WaitForChild("MainFrame")

local BackgroundFrame = MainContainer:WaitForChild("Background")
local UpperBackgroundFrame = MainContainer:WaitForChild("UpperBackground")
local TargetFrame = MainContainer:WaitForChild("TargetStuff")

local Title = MainContainer:WaitForChild("Title")

local Target = {
	Username = MainContainer:WaitForChild("Target");
	Duration = BackgroundFrame:WaitForChild("Duration");
	DisplayReason = BackgroundFrame:WaitForChild("DisplayReason");
	PrivateReason = BackgroundFrame:WaitForChild("PrivateReason");
	ExcludeAltAccounts = BackgroundFrame:WaitForChild("ExcludeAltAccounts");
	Ban = BackgroundFrame:WaitForChild("Ban");
	Unban = BackgroundFrame:WaitForChild("Unban");
}

local TargetStuffMisc = {
	Username = TargetFrame:WaitForChild("TargetUsername");
	UserId = TargetFrame:WaitForChild("TargetUserId");
	Thumbnail = TargetFrame:WaitForChild("Thumbnail");
}

local TargetPlayer = nil
local Title_Bool = false

UpperBackgroundFrame:WaitForChild("Username").Text = tostring("Welcome, "..LocalPlayer.Name)

function GetThumbnail(TargetPlayer)
	
	local content, isReady = Players:GetUserThumbnailAsync(TargetPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

	TargetStuffMisc.Thumbnail.Image = content
	TargetFrame.Visible = true
	
	TargetStuffMisc.Username.Text = Players:GetNameFromUserIdAsync(TargetPlayer.UserId)
	TargetStuffMisc.UserId.Text = TargetPlayer.UserId
	
end

local function GetInfo()
	local usingUser, newId = pcall(function()
		return Players:GetUserIdFromNameAsync(Target.Username.Text)
	end)
	
	TargetPlayer = {}
	
	if usingUser then
		TargetPlayer.Name = Target.Username.Text
		TargetPlayer.UserId = newId
	elseif Target.Username ~= "" then
		TargetPlayer.UserId = tonumber(Target.Username.Text)
		TargetPlayer.Name = Players:GetNameFromUserIdAsync(TargetPlayer.UserId)
	end
	
	if TargetPlayer.UserId and TargetPlayer.Name then
	else
		TargetPlayer = nil
	end
end

local function ButtonBool(Button : TextButton)
	if string.match(Button.Text, "(On)") then 
		return true 
	else 
		return false 
	end
end

Target.Ban.MouseButton1Click:Connect(function()
	if TargetPlayer and Target.Username.Text ~= "" and Target.DisplayReason.Text ~= "" and Target.PrivateReason.Text ~= "" and Target.Duration.Text ~= "" then
		AdminEvents:FireServer("Ban", TargetPlayer.UserId,tonumber(Target.Duration.Text), Target.DisplayReason.Text, Target.PrivateReason.Text,ButtonBool(Target.ExcludeAltAccounts), true)
		task.wait(2)

		GetInfo()
	end
end)

Target.Unban.MouseButton1Click:Connect(function()
	if TargetPlayer then
		warn(TargetPlayer)
		AdminEvents:FireServer("Unban",TargetPlayer.UserId)
	end
	
	task.wait(2)

	GetInfo()
end)

UserInputService.InputBegan:Connect(function()
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)then
		if UserInputService:IsKeyDown(Enum.KeyCode.M) then
			if MainContainer.Visible == false then
				MainContainer.Visible = true
			else
				MainContainer.Visible = false
			end
		end
	end
end)

OpenPanel.MouseButton1Click:Connect(function()
	if MainContainer.Visible == false then
		MainContainer.Visible = true
	else
		MainContainer.Visible = false
	end
end)

Target.ExcludeAltAccounts.MouseButton1Click:Connect(function()
	if string.match(Target.ExcludeAltAccounts.Text, "(Off)") then
		Target.ExcludeAltAccounts.Text = "ExcludeAltAccounts - Bans player's alt accounts (On)"
		Target.ExcludeAltAccounts.BackgroundColor3 = Color3.fromRGB(133, 171, 10)
	else
		Target.ExcludeAltAccounts.Text = "ExcludeAltAccounts - Bans player's alt accounts (Off)"
		Target.ExcludeAltAccounts.BackgroundColor3 = Color3.fromRGB(102, 102, 102)
	end
end)

Title.Activated:Connect(function()
	Title_Bool = not Title_Bool

	DevEvents:FireServer("Title",Title_Bool)
end)

Target.Username.FocusLost:Connect(function(EnterPressed : boolean)
	if EnterPressed then
		GetInfo()

		if TargetPlayer then
			GetThumbnail(TargetPlayer)
			TargetFrame.Visible = true
		else
			TargetFrame.Visible = false
		end
	end
end)