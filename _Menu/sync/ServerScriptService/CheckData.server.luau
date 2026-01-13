local function AddonCheck(Data, Addon)
	local Return = false
	for i, Possibilities in pairs(Data.Inventory.Addons.Survivor:GetDescendants()) do
		if Possibilities.Name == Addon.Value then
			if Possibilities.Value <= 0 then
				Return = true
			end
		end
	end
	return Return
end

game.Players.PlayerAdded:Connect(function(Player)
	repeat task.wait() until (Player:FindFirstChild("Data") ~= nil)
	task.wait(1)
	local Data = Player:WaitForChild("Data")
	local Loadout = Data.Loadout.Addons
	local Slot1 = Loadout.Survivor.Slot1
	local Slot2 = Loadout.Survivor.Slot2
	if AddonCheck(Data,Slot1) == true then
		Slot1.Value = ""
	end
	if AddonCheck(Data,Slot2) == true then
		Slot2.Value = ""
	end
end)