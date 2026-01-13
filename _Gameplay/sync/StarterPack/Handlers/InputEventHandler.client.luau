local Player = game.Players.LocalPlayer
local Remotes = game.ReplicatedStorage.RemoteEvents

local Mouse = Player:GetMouse()
local InputService = game:GetService("UserInputService")

local DONT_SEND = {
	Enum.KeyCode.W,
	Enum.KeyCode.A,
	Enum.KeyCode.S,
	Enum.KeyCode.D,
	Enum.KeyCode.Thumbstick1,
	Enum.KeyCode.Thumbstick2,
}

InputService.InputBegan:Connect(function(Input, Processed)

	if (Processed or table.find(DONT_SEND, Input.KeyCode)) then
		return
	end

	Remotes.EventRemotes.InputEvent:FireServer(Input.KeyCode, true)

end)

InputService.InputEnded:Connect(function(Input, Processed)

	if (Processed or table.find(DONT_SEND, Input.KeyCode)) then
		return
	end

	Remotes.EventRemotes.InputEvent:FireServer(Input.KeyCode, false)

end)

Mouse.Button1Down:Connect(function()
	Remotes.EventRemotes.MouseEvent:FireServer(1, true)
end)

Mouse.Button2Down:Connect(function()
	Remotes.EventRemotes.MouseEvent:FireServer(2, true)
end)

Mouse.Button1Up:Connect(function()
	Remotes.EventRemotes.MouseEvent:FireServer(1, false)
end)

Mouse.Button2Up:Connect(function()
	Remotes.EventRemotes.MouseEvent:FireServer(2, false)
end)