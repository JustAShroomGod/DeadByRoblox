game.Players.LocalPlayer:WaitForChild("PlayerGui")


local Rs = game:GetService('RunService')
local TweenService = game:GetService("TweenService")

local RunCon = nil


if not script.skip.Value then 
	local screen = script.screen:Clone()
	screen.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	screen.Enabled = false

	local event = false

	local tween = TweenService:Create(game.Players.LocalPlayer.PlayerGui.MainMenu.mainarea.TextPrompt, TweenInfo.new(17/10, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true, 1/2), {TextTransparency = 1}):Play()

	coroutine.wrap(function()
		RunCon = Rs.RenderStepped:Connect(function()
			if game:GetService("UserInputService").GamepadEnabled then
				game.Players.LocalPlayer.PlayerGui.MainMenu.mainarea.TextPrompt.Text = "PRESS ANY BUTTON TO CONTINUE"--"PRESS A TO CONTINUE"
			else
				game.Players.LocalPlayer.PlayerGui.MainMenu.mainarea.TextPrompt.Text = "PRESS ANY KEY TO CONTINUE"
			end
		end)
	end)()

	event = game:GetService("UserInputService").InputBegan:Connect(function(input, process)
		if process then 
			return 
		end

		local CorrectKey = false

		if input then --Bite me noob!
			CorrectKey = true
		end

		--if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
		--	CorrectKey = true
		--end

		if not CorrectKey then
			return
		end

		event:Disconnect()
		RunCon:Disconnect()

		game.Players.LocalPlayer.PlayerGui.MainMenu.mainarea.TextPrompt.Text = "LOADING"
		task.wait(1)
		game.Players.LocalPlayer.PlayerGui.MainMenu.mainarea.TextPrompt.Text = "LOADING PLAYER DATA"
		task.wait(1)
		game.Players.LocalPlayer.PlayerGui.MainMenu.mainarea.TextPrompt.Text = "INITIALIZING..."
		task.wait(3)
		game.Players.LocalPlayer.PlayerGui.MainMenu.mainarea.TextPrompt.Text = "INITIALIZIATION COMPLETED"
		task.wait(1)
		
		--[[Tween for blackout]]--
		task.spawn(function()
			local why = game:GetService("TweenService"):Create(game.Players.LocalPlayer.PlayerGui.MainMenu.BlackOut,TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.In, 0, false, 0), {BackgroundTransparency = 0})
			why:Play()
			why.Completed:Wait()
		end)

		--[[tween for song]]--
		task.spawn(function()
			local tween = game:GetService("TweenService"):Create(game.Players.LocalPlayer.PlayerGui.Sounds.MainMenuSong, TweenInfo.new(1), {Volume = 0})
			tween:Play()
			tween.Completed:Wait()
		end)
		task.wait(1)
		game.Players.LocalPlayer.PlayerGui.Sounds.NightAmbient:Play()
		game.Players.LocalPlayer.PlayerGui.Sounds.RainSound:Play()
		--[[turns off mainmenu]]
		game.Players.LocalPlayer.PlayerGui.MainMenu.Enabled = false
		--[[destroys main menu]]--
		local Mainmenuting = game.Workspace:FindFirstChild('MainMenu')
		
		if (Mainmenuting ~= nil) then
			if game.Workspace.MainMenu then
				game.Workspace.MainMenu:Destroy()
				event:Disconnect()
			end
		end
	end)

	--[[Waits for ready gui to change to contine which changes in our input part of script]]--
	screen.Enabled = true
	game.Players.LocalPlayer.Backpack.MCC.CutScene.Value = true
	workspace.CurrentCamera.CFrame = workspace.Points[1].CFrame

	--[[Unblackens screen]]--

	local tween = game:GetService("TweenService"):Create(screen.blackout, TweenInfo.new(3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {BackgroundTransparency = 1})									
	tween:Play()

	--[[Tweens our camera]]--
	task.spawn(function()
		local tween = game:GetService("TweenService"):Create(workspace.CurrentCamera, TweenInfo.new(7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = workspace.Points[2].CFrame})									
		tween:Play()
		game.Players.LocalPlayer.PlayerGui:WaitForChild("ChooseBand").Enabled = true
		game.Players.LocalPlayer.PlayerGui:WaitForChild("ChooseBand"):WaitForChild("Selector").Visible = false
		--game.Players.LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('ChooseBand'):WaitForChild('selectmode').Visible = false
		tween.Completed:Wait()
		game.Players.LocalPlayer.PlayerGui:WaitForChild("ChooseBand"):WaitForChild("Selector").Visible = true
		--game.Players.LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('ChooseBand'):WaitForChild('selectmode').Visible = true
	end)
	--[[Enables new menu]]--
	screen.Enabled = false
	game.Players.LocalPlayer.Backpack.MCC.CutScene.Value = false
else
	game.Players.LocalPlayer.PlayerGui.Ready.Value = true
	workspace.CurrentCamera.CFrame = workspace.Points[2].CFrame
	game.Players.LocalPlayer.PlayerGui.Ready.Value = true
	game.Players.LocalPlayer.Backpack.MCC.CutScene.Value = false
end

game.Players.LocalPlayer.PlayerGui:WaitForChild("VersionGUI").Enabled = true

