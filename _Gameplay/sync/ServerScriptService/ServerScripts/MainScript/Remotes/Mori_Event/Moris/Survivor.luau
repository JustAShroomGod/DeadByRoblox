local TweenService = game:GetService('TweenService')

local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local track_folder = script.Parent.Parent:WaitForChild('Animations'):WaitForChild('Survivor')

local Handler = {}

function Soft_DC(Player : Player) : "Fix DC when moried"
	workspace:SetAttribute(Player.Name .. '_Mori', nil) -- undo it since they didn't get to do a mori
	Player.Character:WaitForChild('HumanoidRootPart').Anchored = false
	Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Nothing"
end

function Handler:Mori(Player : Player, survivor : Player)
	local s_char = Player.Character
	Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Mori"

	local Sounds = {
		Break = script.Parent.Parent:WaitForChild('Sounds'):WaitForChild('Survivor'):WaitForChild('No'):Clone();
	}
	
	-- load the animations --
	local survivorTrack = s_char:WaitForChild('Humanoid'):LoadAnimation(track_folder:WaitForChild('Start'))
	local ragdoll = s_char:WaitForChild('Humanoid'):LoadAnimation(track_folder:WaitForChild('End'))

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
	s_char:WaitForChild('HumanoidRootPart').Anchored = true

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

	game.ReplicatedStorage:WaitForChild('Match'):WaitForChild('Players'):WaitForChild(Player.Name):SetAttribute("Dead", true)

	for _, s in pairs(Sounds) do
		s:Stop()
		s:Remove()
	end
end

return Handler
