game.ReplicatedStorage:WaitForChild("-LockerAuras"):WaitForChild("ForceCloak").OnServerEvent:Connect(function(Player)
	if (Player.Character:FindFirstChild("Bell") ~= nil) or (Player.Character:FindFirstChild("Wraith") ~= nil) then
		require(game.ServerScriptService.ServerScripts.MainScript.Remotes.Server_Event.Modules.Cloak):StartCloaked(Player)
	end
end)