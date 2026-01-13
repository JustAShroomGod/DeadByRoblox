local mouse = game.Players.LocalPlayer:GetMouse()

--local loadout_survivor = game.Players.LocalPlayer.PlayerGui:WaitForChild("PreMS")
--local loadout_killer = game.Players.LocalPlayer.PlayerGui:WaitForChild("PreMK")

local spin_enabled = false

local held,target = nil,nil
local tween_info = TweenInfo.new(0.1)

mouse.Button1Down:Connect(function()
	held = true
	target = mouse.Target
end)

mouse.Button1Up:Connect(function()
	held = nil
	target = nil
end)


mouse.Move:Connect(function()
	if held and target then
		local ry = mouse.X/100

		if target.Name == "SurvivorMouse" and spin_enabled then
			game.Players.LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(game.Players.LocalPlayer.Character.PrimaryPart.CFrame.Position) * CFrame.fromOrientation(0, ry, 0)
		elseif target.Name == "KillerMouse" and spin_enabled then
			game.Players.LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(game.Players.LocalPlayer.Character.PrimaryPart.CFrame.Position) * CFrame.fromOrientation(0, ry, 0)
		end
	end
end)
