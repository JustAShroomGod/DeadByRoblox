Prefab = require(script.Parent.PostgamePrefab)













localPlayer = game:GetService("Players").LocalPlayer
screen = script.Parent.Parent
screen_body = screen.Body

local WIREFRAMES_LIST = {
	[screen.BottomNavegator.Continue.Label] = 1,
	[screen.BottomNavegator.Continue] = 1,
	[screen.BottomNavegator.Upgrade.Label] = 1,
	[screen.BottomNavegator.Upgrade] = 1,
	[screen.BottomNavegator] = 1,
	[screen_body.Navegator.blank.blank] = true,
	[screen_body.Navegator.Checkboxes] = 1,
	[screen_body.BloodpointsEarned.Points.MatchLabel] = 1,
	[screen_body.BloodpointsEarned.Points.Match] = 1,	
	[screen_body.BloodpointsEarned.Points.TotalLabel] = 1,
	[screen_body.BloodpointsEarned.Points.Total] = 1,
	[screen_body.BloodpointsEarned.Points] = 1, 
	[screen_body.BloodpointsEarned.Categories.blank.blank] = true,
	[screen_body.BloodpointsEarned.Categories] = 1,
	[screen_body.OnlineGrade.Design.GradeProgressLabel] = 1,
	[screen_body.OnlineGrade.GradeProgress] = 1,
	[screen_body.OnlineGrade.Emblems.blank.blank] = true,
	[screen_body.OnlineGrade.Rank.Checkboxes] = 1,
	[screen_body.OnlineGrade.Emblems] = 1,
	[screen_body.PlayerLevel.Design.DevotionLabel] = 1,
	[screen_body.PlayerLevel.Design.LevelLabel] = 1,
	[screen_body.PlayerLevel.Devotion] = 1,
	[screen_body.PlayerLevel.Level] = 1,
	[screen_body.PlayerLevel.Xp] = 1,
	[screen_body.PlayerLevel.MatchXP.Caption] = 1,
	[screen_body.Scoreboard.Survivors.blank.blank] = true,
	[screen_body.Scoreboard.Killer.blank.KillerPrefab] = true,
	[screen_body.Scoreboard.Killer.blank.KillerPrefabBackground] = true,
}

local is_enabled = false
function update_wireframe_visibility(bool)
	is_enabled = bool
	for child, value in pairs(WIREFRAMES_LIST) do
		if type(value) == "boolean" then
			child.Visible = bool
		else
			if bool then
				child.BackgroundTransparency = 0
			else
				child.BackgroundTransparency = 1
			end
		end
	end
end

update_wireframe_visibility(false)

if not game:GetService("RunService"):IsStudio() then
	screen.WireframeButton.Visible = false
	return	--	ONLY SHOW ON STUDIO
end

screen.WireframeButton.MouseButton1Down:Connect(function()
	update_wireframe_visibility(not is_enabled)
end)

local module = {}

return module
