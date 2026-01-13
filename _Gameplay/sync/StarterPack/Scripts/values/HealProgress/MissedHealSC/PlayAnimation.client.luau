local plr = game.Players.LocalPlayer
local char = workspace:WaitForChild(plr.Name)

local animation = Instance.new("Animation") 
animation.AnimationId = "http://www.roblox.com/Asset?ID=15080314392"
animTrack = nil

script.Parent.Changed:Connect(function()
	if script.Parent.Value == true then
		script.Parent.Value = false

		animTrack = char:WaitForChild("Humanoid"):LoadAnimation(animation)
		animTrack:Play()
	end
end)