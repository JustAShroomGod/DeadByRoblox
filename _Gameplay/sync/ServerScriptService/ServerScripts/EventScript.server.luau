local MatchReader = require(game:GetService("ServerStorage"):WaitForChild("Modules"):WaitForChild("MatchReader"))
local disconnect = require(script.Disconnect)
--local p5 = players:WaitForChild("Player(V)")

game.Players.PlayerAdded:Connect(function(plr)
	local character = plr.Character or plr.CharacterAdded:wait()
	
	character:WaitForChild("Humanoid").Died:Connect(function()
		disconnect.Reset(plr, "Dead")
	end)
end)

game.Players.PlayerRemoving:Connect(function(plr)
	task.spawn(function()
		disconnect.Disconnect(plr, game.Teams:WaitForChild(MatchReader:Search(plr):GetAttribute("Team")))
	end)
end)