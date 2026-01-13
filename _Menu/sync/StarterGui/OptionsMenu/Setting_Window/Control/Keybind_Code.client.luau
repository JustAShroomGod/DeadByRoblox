local Module = require(script:WaitForChild('Key_Handle'))

local Team_Button = script.Parent:WaitForChild('Team')
local Platform_Button = script.Parent:WaitForChild('Platform')

local Teams = {"Survivor", "Killer"}
local Platforms = {"Keyboard", "Console", "Mobile"}

local Texts = {
	Team = Team_Button:WaitForChild('TextLabel');
	Platform = Platform_Button:WaitForChild('TextLabel');
}

local Editor_Button = script.Parent:WaitForChild('Editor')

function UpdateListing()
	local Listing = Module:GetKeys(Texts.Team.Text, Texts.Platform.Text)
	
	if Listing == "Mobile" then
		Editor_Button.Visible = true
	else
		Editor_Button.Visible = false
		Module:SetKeys(Listing, Texts.Team.Text, Texts.Platform.Text)
	end
end

Editor_Button.MouseButton1Click:Connect(function()
	Module:OpenLayout(Texts.Team.Text)
end)

Platform_Button.MouseButton1Click:Connect(function()
	local platform_index = table.find(Platforms, Texts.Platform.Text)

	if platform_index >= #Platforms then
		Texts.Platform.Text = Platforms[1]
	else
		Texts.Platform.Text = Platforms[platform_index + 1]
	end

	UpdateListing()
end)

Team_Button.MouseButton1Click:Connect(function()
	local team_index = table.find(Teams, Texts.Team.Text)
	
	if team_index >= #Teams then
		Texts.Team.Text = Teams[1]
	else
		Texts.Team.Text = Teams[team_index + 1]
	end
	
	UpdateListing()
end)

UpdateListing()