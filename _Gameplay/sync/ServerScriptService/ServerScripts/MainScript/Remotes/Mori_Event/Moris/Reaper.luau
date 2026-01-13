local TweenService = game:GetService('TweenService')

local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Splatter_Module = require(script.Parent:WaitForChild('Splatter'))

local track_folder = script.Parent.Parent:WaitForChild('Animations'):WaitForChild('Architect')

local Handler = {}

function Soft_DC(Player : Player) : "Fix DC when moried"
	workspace:SetAttribute(Player.Name .. '_Mori', nil) -- undo it since they didn't get to do a mori
	Player.Character:WaitForChild('HumanoidRootPart').Anchored = false
	Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Nothing"
end

function Handler:Mori(Player : Player, survivor : Player, Mori_Type : string)
	local k_char, s_char = Player.Character, survivor.Character

	local Sounds = {  
		Hammer = script.Parent.Parent:WaitForChild('Sounds'):WaitForChild('Architect'):WaitForChild('Hammer'):Clone();
		Scream = script.Parent.Parent:WaitForChild('Sounds'):WaitForChild('Architect'):WaitForChild('Scream'):Clone();
		Splat = script.Parent.Parent:WaitForChild('Sounds'):WaitForChild('Architect'):WaitForChild('Splat'):Clone();
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

	if s_char then
		s_char.Archivable = false
	end

	if Mori_Type ~= 'Ultra Death Card' then
		workspace:SetAttribute(Player.Name .. '_Mori', true) -- mori can only be done once
	end
	Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Mori"
	if survivor then
		survivor:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Mori"
	end

	-- sanity check to see if mori can be performed --

	-- load the animations --
	local killerTrack, survivorTrack = k_char:WaitForChild('Humanoid'):LoadAnimation(track_folder:WaitForChild('Killer')), s_char:WaitForChild('Humanoid'):LoadAnimation(track_folder:WaitForChild('Survivor'))
	local ragdoll, true_ragdoll = s_char:WaitForChild('Humanoid'):LoadAnimation(track_folder:WaitForChild('Ragdoll')), rag_char:WaitForChild('Humanoid'):LoadAnimation(track_folder:WaitForChild('Ragdoll'))

	Sounds.Splat.Parent = s_char.HumanoidRootPart
	Sounds.Scream.Parent = s_char.HumanoidRootPart
	Sounds.Hammer.Parent = k_char.HumanoidRootPart

	-- create animation listeners --
	local Finished = {
		Killer = false;
		Survivor = false;
	}

	survivorTrack.KeyframeReached:Connect(function(frame)

		if s_char.Head:FindFirstChild('face') then

			if frame == "Smash_1" then
				s_char.Head.face.Texture = "rbxassetid://954678048"
			elseif frame == "Smash_2" then
				s_char.Head.face.Texture = "rbxassetid://5831520699"
			elseif frame == "Smash_3" then
				s_char.Head.face.Texture = "rbxassetid://4599588850"
			end
		end

		if string.match(frame, 'Smash') then
			Sounds.Hammer:Play()
			Sounds.Splat:Play()

			for i = 1, math.random(3, 5) do
				if not s_char or not s_char:FindFirstChild('Head') then break end

				coroutine.wrap(function()
					Splatter_Module:Splatter(s_char.Head, {Ignore = s_char})
				end)()
			end
		end
	end)

	-- position the characters --
	k_char:WaitForChild('HumanoidRootPart').Anchored = true
	if s_char then
		s_char:WaitForChild('HumanoidRootPart').Anchored = true
	end

	local cframeValue, connection = Instance.new('CFrameValue'), nil
	cframeValue.Value = s_char.HumanoidRootPart.CFrame

	if s_char then
		connection = cframeValue.Changed:Connect(function()
			s_char.HumanoidRootPart.CFrame = cframeValue.Value
		end)
	end

	local tween = TweenService:Create(cframeValue, TweenInfo.new(0.15), {Value = k_char.HumanoidRootPart.CFrame * CFrame.new(.5, -.25, -7) * CFrame.Angles(0, math.rad(180), 0)})
	tween:Play()
	tween.Completed:Wait()

	-- play animation --

	Sounds.Scream:Play()

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


	-- make this moment last longer
	killerTrack:AdjustSpeed(.8)
	survivorTrack:AdjustSpeed(.8)

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

	-- Mori Fixer --
	coroutine.resume(coroutine.create(function()
		if not s_char or not s_char.Parent then
			Soft_DC(Player)
		end
	end))
	-- Mori Fixer --

	--warn(rag_char, 'is here')

	rag_char:PivotTo(s_char:GetPivot()) -- replace

	-- free the killer
	Code_Module:AddDeath(survivor)

	for _, s in pairs(Sounds) do
		s:Stop()
		s:Remove()
	end

	connection:Disconnect()
	connection = cframeValue.Changed:Connect(function()
		k_char.HumanoidRootPart.CFrame = cframeValue.Value
	end)

	cframeValue.Value = k_char:GetPivot()

	TweenService:Create(cframeValue, TweenInfo.new(0.15), {Value = k_char.HumanoidRootPart.CFrame * CFrame.new(0, 0.5, 1.5)}):Play()
	task.wait(0.35)

	connection:Disconnect()
	cframeValue:Remove()

	k_char.HumanoidRootPart.Anchored = false 
	Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Nothing"
end

return Handler
