local pallet = script.Parent.Parent
local state = script.Parent:WaitForChild("State")
local dropper = script.Parent:WaitForChild("Dropper")
local collision = script.Parent:WaitForChild("Collision")
local modelCollision = script.Parent:WaitForChild("ModelCollision")

local Events = require(game.ServerScriptService["Event System"]:WaitForChild("Events"))
local data_module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))
local code_module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Code'))
local Data = require(game.ReplicatedStorage.Modules:WaitForChild('Data'))

local prefix = "http://www.roblox.com/Asset?ID="

local dropAnim = Instance.new("Animation")
dropAnim.AnimationId = prefix.. "13426176655"
dropAnim.Name = "DropAnim"

local idleAnim = Instance.new("Animation")
idleAnim.AnimationId = prefix.. "13426183060"
idleAnim.Name = "IdleAnim"

local animTrack = nil

local broke = false
local dropping = false

propsStuff = game:GetService('ServerStorage'):WaitForChild("Interactables")

grantedStun = false

function update()

	if state.Value == 0 then

		dropping = false

		if broke then
			if animTrack then animTrack:Stop() animTrack = nil end

			local newPallet = propsStuff:WaitForChild("Pallet"):Clone()
			newPallet.Name = pallet.Name
			newPallet:PivotTo(pallet.HumanoidRootPart.CFrame)
			newPallet.Parent = workspace
			pallet:Destroy()

			return print('Generated', newPallet)
		else
			if animTrack then animTrack:Stop() animTrack = nil end

			modelCollision.CanCollide = true
			collision.CanCollide = false
		end
	elseif state.Value == 1 then
		local bounced = false
		local animTrackReachedConnection
		local animTrackStoppedConnection
		local animTrackBouncedConnection
		game:GetService("TweenService"):Create(script.Parent.Collision, TweenInfo.new(0.02, Enum.EasingStyle.Linear), {Size = Vector3.new(8.586, 9.528, 5.31)}):Play()
		if not broke then
			if animTrack then animTrack:Stop() animTrack = nil end


			animTrack = pallet:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(dropAnim)
			animTrack:Play()
			animTrack:AdjustSpeed(1.3)

			modelCollision.CanCollide = false
			collision.CanCollide = true

			dropping = true

			animTrackBouncedConnection = animTrack:GetMarkerReachedSignal("bounce")

			animTrackBouncedConnection = animTrackBouncedConnection:Connect(function()
				bounced = true

				local dropSound = Instance.new("Sound")
				dropSound.Parent = pallet:WaitForChild("Panel"):WaitForChild("Collision")
				dropSound.RollOffMaxDistance = 80
				dropSound.RollOffMinDistance = 1
				dropSound.Volume = 2.5
				dropSound.SoundId = "rbxassetid://1366920166"

				dropSound:Play()

				dropSound.Stopped:Connect(function()
					dropSound:Destroy()
					return
				end)

				if animTrackBouncedConnection then
					animTrackBouncedConnection:Disconnect()
				end
			end)

			animTrackReachedConnection = animTrack:GetMarkerReachedSignal("stun_end")

			animTrackReachedConnection = animTrackReachedConnection:Connect(function()
				dropping = false

				if animTrackReachedConnection then
					animTrackReachedConnection:Disconnect()
				end
			end)

			animTrackStoppedConnection = animTrack.Stopped:Connect(function()
				animTrack = nil

				animTrack = pallet:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(idleAnim)
				animTrack:Play()

				if animTrackStoppedConnection then
					animTrackStoppedConnection:Disconnect()
				end

				return
			end)
		else
			local newPallet = propsStuff:WaitForChild("Pallet"):Clone()
			newPallet.Name = pallet.Name
			newPallet.Parent = workspace
			newPallet.HumanoidRootPart.CFrame = pallet.HumanoidRootPart.CFrame
			newPallet:WaitForChild("Panel"):WaitForChild("State").Value = 1
			pallet:Destroy()

			return
		end

		local connection = nil
		connection = state.Changed:Connect(function()

			if state.Value ~= 1 then
				while not bounced do task.wait() end


				if animTrackBouncedConnection then animTrackBouncedConnection:Disconnect() end
				if animTrackReachedConnection then animTrackReachedConnection:Disconnect() end
				if animTrackStoppedConnection then animTrackStoppedConnection:Disconnect() end

				if animTrack then animTrack:Stop() end

				connection:Disconnect()
			end
		end)
	elseif state.Value == 2 then
		dropping = false

		local cables = pallet:FindFirstChild("Cables")
		local otherParts = pallet:FindFirstChild("OtherParts")
		local woodParts = pallet:FindFirstChild("WoodParts")
		local welds = pallet:FindFirstChild("Welds")
		local containers = {cables}

		for _, container in pairs(containers) do
			for v1, part in pairs(container:GetChildren()) do
				part:Destroy()
			end
		end

		for _, part in pairs(woodParts:GetChildren()) do
			part.CanCollide = true
		end

		for _, weld in pairs(welds:GetChildren()) do
			if weld then
				weld:Destroy()
			end
		end

		broke = true

		modelCollision.CanCollide = false
		collision.CanCollide = false

		local secondKickSound = Instance.new("Sound")
		secondKickSound.Parent = pallet:WaitForChild("Panel"):WaitForChild("Collision")
		secondKickSound.RollOffMaxDistance = 70
		secondKickSound.RollOffMinDistance = 1
		secondKickSound.Volume = 2.5
		secondKickSound.SoundId = "rbxassetid://9120904218"

		secondKickSound:Play()

		secondKickSound.Stopped:Connect(function()
			secondKickSound:Destroy()
			return
		end)

		local thirdKickSound = Instance.new("Sound")
		thirdKickSound.Parent = pallet:WaitForChild("Panel"):WaitForChild("Collision")
		thirdKickSound.RollOffMaxDistance = 70
		thirdKickSound.RollOffMinDistance = 1
		thirdKickSound.Volume = 3
		thirdKickSound.SoundId = "rbxassetid://4004054685"

		thirdKickSound:Play()

		thirdKickSound.Stopped:Connect(function()
			thirdKickSound:Destroy()
			return
		end)

		local FirstKickbackgroundSound = Instance.new("Sound")
		FirstKickbackgroundSound.Parent = pallet:WaitForChild("Panel"):WaitForChild("Collision")
		FirstKickbackgroundSound.RollOffMaxDistance = 70
		FirstKickbackgroundSound.RollOffMinDistance = 1
		FirstKickbackgroundSound.Volume = 2.5
		FirstKickbackgroundSound.SoundId = "9120917253"

		FirstKickbackgroundSound:Play()

		FirstKickbackgroundSound.Stopped:Connect(function()
			FirstKickbackgroundSound:Destroy()
			return
		end)

		task.wait(4.5)

		for _, part in pairs(woodParts:GetChildren()) do
			part.Anchored = true
			part.CanCollide = false
		end
	end
end

update()

state.Changed:Connect(function()
	local playing = false
	update()
end)

local Spirit_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('SpiritFury'))

function StunKiller(Killer)
	local killerBackpack = Killer:FindFirstChild("Backpack")

	if killerBackpack then
		local killerScripts = killerBackpack:FindFirstChild("Scripts")

		if killerScripts then
			local killerValues = killerScripts:FindFirstChild("values")

			if killerValues then
				local stunned = killerValues:FindFirstChild("Stunned")
				local kind = stunned:FindFirstChild("Kind")

				local IFrame, AFrame = code_module:GetEffect("IFrame", Killer), code_module:GetEffect("AFrame", Killer)

				if not stunned.Value
					and (not AFrame or (AFrame and not AFrame.Active))
					and (not IFrame or (IFrame and not IFrame.Active)) then -- No IFrame

					local perksBase = killerScripts:WaitForChild("PerksBase")
					
					local dropperPlayer = game.Players:FindFirstChild(dropper.Value)
					code_module:Stun_Killer(Killer, 'Pallet', dropperPlayer)
					
					if perksBase then
						local spiritfuryBase = perksBase:WaitForChild("SpiritFury")

						if spiritfuryBase then
							local HasSpirit, SpiritTier = Data:GetPerk("SpiritFury", Killer)
							local pallets = spiritfuryBase:WaitForChild("Pallets")

							if pallets and HasSpirit then

								if pallets.Value >= Spirit_Module.Tiers[SpiritTier] then
									state.Value = 2
									pallets.Value = 0
								end
							end
						end
					end

					if dropperPlayer then
						data_module:GiveBlood(dropperPlayer, 1000, "Boldness", "KILLER STUN")
						Events.Survivor.onKillerStun:Fire(dropperPlayer, Killer)

						if Killer.Character:GetAttribute("Carry") then
							data_module:GiveBlood(dropperPlayer, 1500, 'Altruism', 'KILLER GRASP RESCUE')
						end
					end
				end
			end
		end
	end
end

collision.Touched:Connect(function(part)
	if part.Name == "Flash_Zone" or part.Name == "Hitbox" or not dropping then return end
	local currentPlayer = nil

	if game.Players:FindFirstChild(part.Parent.Name) and game.Players:FindFirstChild(part.Parent.Name).Team == game.Teams:WaitForChild('Killer') then
		currentPlayer = game.Players:FindFirstChild(part.Parent.Name)
	end

	if part.Parent:FindFirstChild("AttackAction") then return end
	
	if currentPlayer then
		StunKiller(currentPlayer)
	end
end)