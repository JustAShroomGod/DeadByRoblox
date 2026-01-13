local Player : Player, TweenService : TweenService = game:GetService('Players').LocalPlayer, game:GetService('TweenService')
local UI : PlayerGui = Player:WaitForChild('PlayerGui')

local ReadyScreen : ScreenGui = script:WaitForChild('LoadScreen')
local LoadingScreen : ScreenGui = require(script:WaitForChild('Load')).load()

LoadingScreen.text.frame.Visible = true

repeat task.wait() until Player:FindFirstChild("Data") -- Waits For Data to Exist Meaning we have a assigned team

task.wait(1)

if game:GetService('ReplicatedStorage'):WaitForChild('Match'):WaitForChild('Started').Value then
	LoadingScreen:delete()
else
	ReadyScreen.Parent = UI
	LoadingScreen:delete()

	while task.wait() do

		if not ReadyScreen or not ReadyScreen.Parent then
			break
		end
	end

	local Backpack = Player:WaitForChild("Backpack")
	local Scripts = Player:WaitForChild("Backpack"):WaitForChild("Scripts")

	if not Scripts:WaitForChild("Killer").Value then
		UI:WaitForChild("Intro").SurvivorCutScene.Disabled = false
	else
		UI:WaitForChild("Intro").KillerCutScene.Disabled = false
	end
end

