local module = {}

local match = game.ReplicatedStorage:WaitForChild("Match")
local players = match:WaitForChild("Players")

local spectate = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local remoteevents = game.ReplicatedStorage:WaitForChild("RemoteEvents")

function module.Reset(Player : Player, Event : string)
	if Event ~= "Dead" then return end

	if Player.Team == game:GetService('Teams').Killer then
		return spectate:Spectate(Player)
	end

	local s_char = Player.Character
	local old_position = s_char:GetPivot()

	s_char.Archivable = true
	Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Mori"

	-- sanity check to see if mori can be performed --
	local clone_character =  Player.Character:Clone()
	local track_folder = script:WaitForChild('Animations'):WaitForChild('Survivor')

	clone_character:WaitForChild('HumanoidRootPart').Anchored = true
	clone_character:PivotTo(clone_character:GetPivot() * CFrame.new(0, 1000, 0))
	clone_character.Parent = workspace

	-- load the animations --
	local survivorTrack = clone_character:WaitForChild('Humanoid'):LoadAnimation(track_folder:WaitForChild('Start'))
	local ragdoll = clone_character:WaitForChild('Humanoid'):LoadAnimation(track_folder:WaitForChild('End'))

	local Sounds = {
		Break = script:WaitForChild('Sounds'):WaitForChild('Survivor'):WaitForChild('No'):Clone();
	}

	Sounds.Break.Parent = s_char.HumanoidRootPart

	-- create animation listeners --
	local Finished = {
		Survivor = false;
	}

	survivorTrack.KeyframeReached:Connect(function(frame)

		if frame == 'Break' then
			Sounds.Break:Play()
		end
	end)

	-- position the characters --
	clone_character.Name = "Ragdoll"

	clone_character:PivotTo(old_position)
	spectate:Spectate(Player)

	-- play animation --

	task.wait(.5)

	survivorTrack:Play()


	survivorTrack.Stopped:Connect(function()
		Finished.Survivor = true
	end)

	ragdoll:Play()
	-- wait for both to stop --

	repeat task.wait()
	until Finished.Survivor

	-- free the killer

	for _, p_string in pairs(game.ReplicatedStorage:WaitForChild('Match'):WaitForChild('Players'):GetChildren()) do

		if p_string.Value == Player.Name then
			p_string:WaitForChild('Death').Value = true
		end
	end

	for _, s in pairs(Sounds) do
		s:Stop()
		s:Remove()
	end
end

function module.Disconnect(plr, mode) -- WHAT I NEED --
	if mode == game.Teams:WaitForChild('Killer') then -- person disconnecting is the killer
		if #game.Teams.Killer:GetPlayers() <= 0 then
			for _, player in pairs(game.Teams.Survivor:GetPlayers()) do
				spectate:AddEscape(player)
				spectate:Spectate(player)

				if game.ReplicatedStorage:WaitForChild('Match'):WaitForChild('Started').Value then
					coroutine.wrap(function()
						task.wait(5) --was 30
						player:WaitForChild("Backpack"):WaitForChild("Scripts"):WaitForChild("values"):WaitForChild("Match"):WaitForChild("Disconnected").Value = true
					end)()
				else
					player:WaitForChild("Backpack"):WaitForChild("Scripts"):WaitForChild("values"):WaitForChild("Match"):WaitForChild("Disconnected").Value = true
				end
			end
		end
	elseif mode == game.Teams:WaitForChild('Survivor') then
		spectate:AddDeath(plr)
		
		for _, player in pairs(game.Teams:WaitForChild('Killer'):GetPlayers()) do
			require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')):AddKill(player)
		end
	end
end

return module