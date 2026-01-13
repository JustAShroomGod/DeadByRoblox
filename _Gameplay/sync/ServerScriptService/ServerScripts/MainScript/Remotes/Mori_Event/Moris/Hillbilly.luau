local TweenService = game:GetService('TweenService')

local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local track_folder = script.Parent.Parent:WaitForChild('Animations'):WaitForChild('Hillbilly')

local Handler = {}

function Soft_DC(Player : Player) : "Fix DC when moried"
	workspace:SetAttribute(Player.Name .. '_Mori', nil) -- undo it since they didn't get to do a mori
	Player.Character:WaitForChild('HumanoidRootPart').Anchored = false
	Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Nothing"
end

function Handler:Mori(Player : Player, survivor : Player, Mori_Type : string)
	local k_char, s_char = Player.Character, survivor.Character

	local bloodFX = script.Parent.Parent:WaitForChild('Particles'):WaitForChild('Blood'):Clone()
	local Sounds = {
		No = script.Parent.Parent:WaitForChild('Sounds'):WaitForChild('Hillbilly'):WaitForChild('No'):Clone();
		Scream = script.Parent.Parent:WaitForChild('Sounds'):WaitForChild('Hillbilly'):WaitForChild('Scream'):Clone();
		Saw = script.Parent.Parent:WaitForChild('Sounds'):WaitForChild('Hillbilly'):WaitForChild('Chainsaw'):Clone();
	}
	
	if (s_char == nil) then
		Soft_DC(Player)
		return
	end
	
	s_char.Archivable = true
	--
	local rag_char = s_char:Clone()
	rag_char:WaitForChild('HumanoidRootPart').Anchored = true
	rag_char:PivotTo(CFrame.new())
	rag_char.Parent = workspace

	s_char.Archivable = false

	if Mori_Type ~= 'Ultra Death Card' then
		workspace:SetAttribute(Player.Name .. '_Mori', true) -- mori can only be done once
	end	

	Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Mori"
	survivor:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Mori"

	-- load the animations --
	local killerTrack, survivorTrack = k_char:WaitForChild('Humanoid'):LoadAnimation(track_folder:WaitForChild('Killer')), s_char:WaitForChild('Humanoid'):LoadAnimation(track_folder:WaitForChild('Survivor'))
	local ragdoll, true_ragdoll = s_char:WaitForChild('Humanoid'):LoadAnimation(track_folder:WaitForChild('RagDoll')), rag_char:WaitForChild('Humanoid'):LoadAnimation(track_folder:WaitForChild('RagDoll'))

	Sounds.No.Parent = s_char.HumanoidRootPart
	Sounds.Scream.Parent = s_char.HumanoidRootPart
	Sounds.Saw.Parent = k_char.HumanoidRootPart

	bloodFX.Parent = s_char:WaitForChild('Head'):WaitForChild('FaceFrontAttachment')

	-- create animation listeners --
	local Finished = {
		Killer = false;
		Survivor = false;
	}

	survivorTrack.KeyframeReached:Connect(function(frame)

		if frame == 'Blood_Start' then
			bloodFX.Enabled = true
			Sounds.Scream:Play()
			Sounds.Saw:Play()

			if s_char.Head:FindFirstChild('face') then
				s_char.Head.face.Texture = "rbxassetid://954678048"
			end
		elseif frame == 'Blood_End' then
			bloodFX.Enabled = false
			Sounds.Saw:Stop()

			if s_char.Head:FindFirstChild('face') then
				s_char.Head.face.Texture = "rbxassetid://4599588850"
			end
		end
	end)

	-- position the characters --
	k_char:WaitForChild('HumanoidRootPart').Anchored = true
	if s_char then
		s_char:WaitForChild('HumanoidRootPart').Anchored = true
	end

	local cframeValue = Instance.new('CFrameValue')
	cframeValue.Value = s_char.HumanoidRootPart.CFrame

	cframeValue.Changed:Connect(function()
		s_char.HumanoidRootPart.CFrame = cframeValue.Value
	end)

	local tween = TweenService:Create(cframeValue, TweenInfo.new(0.15), {Value = k_char.HumanoidRootPart.CFrame * CFrame.new(-.248, -.743, -4.763) * CFrame.Angles(0, math.rad(180), 0)})
	tween:Play()
	tween.Completed:Wait()

	-- play animation --

	task.wait(.5)

	-- Mori Fixer --
	if not s_char or not s_char.Parent then
		return Soft_DC(Player)
	end
	-- Mori Fixer --

	killerTrack:Play()
	if s_char then
		survivorTrack:Play()
	end
	true_ragdoll:Play()

	if s_char then
		Sounds.No:Play()
	end

	-- make this moment last longer
	killerTrack:AdjustSpeed(.5)
	survivorTrack:AdjustSpeed(.5)

	killerTrack.Stopped:Connect(function()
		Finished.Killer = true
	end)

	if s_char then
		survivorTrack.Stopped:Connect(function()
			Finished.Survivor = true
		end)
	end
	ragdoll:Play()
	-- wait for both to stop --

	repeat task.wait()

		if not s_char or not s_char.Parent then
			Finished.Survivor = true
			Finished.Killer = true
		end
	until Finished.Killer and Finished.Survivor

	coroutine.resume(coroutine.create(function()
		if not s_char or not s_char.Parent then
			Soft_DC(Player)
		end
	end))

	rag_char:PivotTo(s_char:GetPivot()) -- replace

	Code_Module:AddDeath(survivor)

	for _, s in pairs(Sounds) do
		s:Stop()
		s:Remove()
	end

	k_char.HumanoidRootPart.Anchored = false
	Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Nothing"
end

return Handler
