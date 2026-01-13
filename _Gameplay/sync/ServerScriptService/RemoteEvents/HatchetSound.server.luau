local ids = {
	aim = 6648492342
	,max_charge = 6648492997
	,save = 6648493213
}

local prefix = "rbxassetid://"

local function instantiate_sound(id, char)
--	print(id, char)
	local sound = Instance.new("Sound", char.Head)
	sound.Volume = 4
	sound.RollOffMaxDistance = 250
	if id == "Max" then id = ids.max_charge else id = ids.save end
	sound.SoundId = prefix.. tostring(id)
	sound:Play()

	local ended = sound.Ended

	ended = ended:Connect(function()
		ended:Disconnect()

		sound:Destroy()
	end)
end

game.ReplicatedStorage:WaitForChild("-LockerAuras"):WaitForChild("HatchetSoundEvent").OnServerEvent:Connect(function(Player,Name)
	instantiate_sound(Name, Player.Character)
end)
