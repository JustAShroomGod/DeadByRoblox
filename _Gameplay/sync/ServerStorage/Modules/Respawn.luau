local Handler = {
	RespawnTime = 1
}

local Lobby = workspace:FindFirstChild("Lobby")

function Handler:AddPlayer(Player : Player)
	
	Player.CharacterAdded:Connect(function(Character)
		
		Character:WaitForChild('Humanoid').Died:Connect(function()
			Character:Destroy()
			task.wait(Handler.RespawnTime)
			Player:LoadCharacterAsync()
		end)
	end)
	
	task.wait(Handler.RespawnTime)
	Player:LoadCharacterAsync()
end

return Handler
