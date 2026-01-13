local Players : Players = game:GetService("Players")

local LocalPlayer = Players:GetPlayerFromCharacter(script.Parent.Parent)

local TitleModule = require(script:WaitForChild('Title'))
local GroupId = 3863491

repeat task.wait() until LocalPlayer:FindFirstChild("Data")

local Data = LocalPlayer:WaitForChild('Data')
local Role = LocalPlayer:GetRoleInGroupAsync(GroupId)

local Skill_Title = script.Parent.Parent:WaitForChild('Head'):WaitForChild('Title'):WaitForChild('TextLabel')
local Name_Title = script.Parent.Parent:WaitForChild('Head'):WaitForChild('Name'):WaitForChild('TextLabel')

local function Killer_Update()
	if not LocalPlayer.Character:GetAttribute("Escapes") then
		require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')):GetKills(LocalPlayer) -- update our kills
	end

	if not (LocalPlayer.Character:GetAttribute("Team") == "Killer") then return end

	Skill_Title.Text = TitleModule:Translate('Kills', LocalPlayer.Character:GetAttribute('Kills'), 'String') .. ' ' .. Data:WaitForChild('Loadout'):WaitForChild('Killer').Value
	Skill_Title.TextColor3 = TitleModule:Translate('Kills', LocalPlayer.Character:GetAttribute('Kills'), 'Color')

	Name_Title.Visible = true
	Skill_Title.Visible = true
end

local function Survivor_Update()
	if not LocalPlayer.Character:GetAttribute("Escapes") then
		require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')):GetKills(LocalPlayer) -- update our kills
	end

	if not (LocalPlayer.Character:GetAttribute("Team") == "Survivor") then return end

	Skill_Title.Text = TitleModule:Translate('Escapes', LocalPlayer.Character:GetAttribute('Escapes'), 'String')  .. ' Survivor'
	Skill_Title.TextColor3 = TitleModule:Translate('Escapes', LocalPlayer.Character:GetAttribute('Escapes'), 'Color')

	Name_Title.Visible = true
	Skill_Title.Visible = true
end

local function Title_Display()
	Name_Title.Text = LocalPlayer.DisplayName
	Name_Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	
	if TitleModule.Titles[Role] and Role == "CONTENT CREATOR" then
		TitleModule:Title_Display_Rank(LocalPlayer, true)
	end
end


Data:WaitForChild('Loadout'):WaitForChild('Killer').Changed:Connect(Killer_Update)
LocalPlayer.Character:GetAttributeChangedSignal("Team"):Connect(function()
	if LocalPlayer.Character:GetAttribute("Team") == "Survivor" then
		Survivor_Update()
	else
		Killer_Update()
	end
end)

task.spawn(function()
	Killer_Update()
end)

Title_Display()
