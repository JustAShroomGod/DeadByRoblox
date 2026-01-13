local Players : Players,UserInputService : UserInputService, ReplicatedStorage : ReplicatedStorage = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("ReplicatedStorage")

local RemotesArea = ReplicatedStorage:WaitForChild("RemoteEvents")
local DevEvents = RemotesArea:WaitForChild("DevEvents")

local LocalPlayer = Players.LocalPlayer

local OpenPanel = script.Parent:WaitForChild("OpenPanel")
local MainContainer = script.Parent:WaitForChild("MainFrame")

local BackgroundFrame = MainContainer:WaitForChild("Background")
local UpperBackgroundFrame = MainContainer:WaitForChild("UpperBackground")

local Buttons = {
	BloodRain = BackgroundFrame:WaitForChild("BloodRain");
	Title = BackgroundFrame:WaitForChild("Title");
}

local Title_Bool = false

UpperBackgroundFrame:WaitForChild("Username").Text = tostring("Welcome, "..LocalPlayer.Name)

UserInputService.InputBegan:Connect(function()
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)then
		if UserInputService:IsKeyDown(Enum.KeyCode.N) then
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

Buttons.BloodRain.Activated:Connect(function()
	DevEvents:FireServer("Rain")
end)


Buttons.Title.Activated:Connect(function()
	Title_Bool = not Title_Bool
	
	DevEvents:FireServer("Title",Title_Bool)
end)