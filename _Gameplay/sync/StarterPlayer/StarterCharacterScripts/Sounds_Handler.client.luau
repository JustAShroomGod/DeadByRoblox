repeat task.wait() until game:GetService("Players").LocalPlayer.Character:GetAttribute("IntroDone")


local Sound_Handler = require(script:WaitForChild('Sound_Handler'))

function AutoAdd(Team)
	
	for _, Player in pairs(Team:GetPlayers()) do
		Sound_Handler:ConnectUser(Player)
	end
	
	Team.PlayerAdded:Connect(function(Player)
		Sound_Handler:ConnectUser(Player)
	end)
end

AutoAdd(game.Teams:WaitForChild('Killer'))
AutoAdd(game.Teams:WaitForChild('Survivor'))

Sound_Handler:Connect()