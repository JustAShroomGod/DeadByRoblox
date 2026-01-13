local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local TweenService = game:GetService('TweenService')

local BUG_READ = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('BUGREAD')

local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local code_module =require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Events = {
	onGrasp =  ServerScripts["Event System"]:WaitForChild("Killer"):WaitForChild("onGrasp")
}

local Perk_Modules = {
	["Swift Frisson"] = require(ReplicatedStorage:WaitForChild("Game_Data"):WaitForChild("Perks"):WaitForChild("Killer"):WaitForChild("Swift Frisson"));
}

local module = {
	Carry_Connections = {}
}
local Settings = {
	IFrames = 3;
	Length = {
		Carry = 3.5; -- length of time carry should take to play out
		Drop = 1;
	},
	Offset = {
		Carry = CFrame.new(-2.5, -1, 0)
	},
}


function WeldTogether(p1, p2, offset)
	local W = nil

	repeat task.wait()
		W = p1:FindFirstChild('GraspWeld')
		if W then W:Destroy() end
	until not W

	W = Instance.new('Weld', p1)
	W.Name = "GraspWeld"
	W.Part0 = p1
	W.Part1 = p2

	W.C0 = offset
	W.C1 = CFrame.new(0,0,0)

	return W
end

function FreePlayer(Player : Player, Survivor) : "Attempts to undo survivor carried values"

	if Survivor and game.Players:FindFirstChild(Survivor) then
		Survivor = game.Players:FindFirstChild(Survivor) -- got survivor

		code_module:SetCollision(Survivor, 'Survivor')
warn("GOT HERE!")
		Survivor.Backpack:WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "Nothing" -- lets survivor know they are not being carried
		Survivor.Backpack:WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Holded').Value = false -- auto play idle carry animation now

		if Survivor.Character then
			Survivor.Character:WaitForChild('Humanoid').PlatformStand = false -- undo platform stand if any
			Survivor.Character.PrimaryPart.Anchored = false -- undo anchoring if any
		end
	end

	Player.Character:SetAttribute("Carry", nil)
end

function Cancelation(Player : Player) : "Cancels out pickup"
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')

	FreePlayer(Player)

	playerValues.KillerAction.Value = "Nothing" -- changes killer action/let killer know to play carry idle--

	if Player.Character.PrimaryPart:FindFirstChild("GraspWeld") then
		Player.Character.PrimaryPart:WaitForChild('GraspWeld'):Remove()
	end

	Player.Character.PrimaryPart.Anchored = false -- unanchor killer from current location
end

-- ISOLATED CARRY CONNECTIONS --
function Connections(Killer : Player, Survivor : Player)
	if not Killer.Character:GetAttribute("Carry") then return end
	if not Survivor.Character then warn(Survivor.Name, ':', Survivor.ClassName, '- did not have character!') return end
	local Stunner : BoolValue, Stun_Typer : StringValue = Killer:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Stunned'), Killer:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Stunned'):WaitForChild('Kind')
	--print('Connect us to killer connections!')

	if Survivor.Character:GetAttribute("Perk_Defense_Time") then
		local defenseTable = string.split(Survivor.Character:GetAttribute("Perk_Defense_Time"), ":") -- string math
		local TimeElapsed, TotalTime = workspace:GetServerTimeNow() - tonumber(defenseTable[2]), tonumber(defenseTable[1])
		--print(TotalTime - TimeElapsed > 0)
		--print(Survivor.Character:GetAttribute("Perk_Defense_Used"))
		if TotalTime - TimeElapsed > 0 and not Survivor.Character:GetAttribute("Perk_Defense_Used") then
			Survivor.Character:SetAttribute("Perk_Defense_Used", true)

			code_module:Stun_Killer(Killer, 'Defense')

			data_module:GiveBlood(Survivor, 1500, 'Survival', 'STAB KILLER')
		end
	end

	if not module.Carry_Connections[Killer.Character] then -- for branched connections
		module.Carry_Connections[Killer.Character] = {}
	end
end
local FOUND_MODULE = require(game.ReplicatedStorage:WaitForChild("Game_Data"):WaitForChild("Perks"):WaitForChild("Killer"):WaitForChild("Tight Grip"))

function module:Fire(Player : Player, Arguments : "table")
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')

	local Command, Survivor = Arguments[2], Arguments[3]

	--warn('Carry fired')
	--print(Player, Arguments)

	if Command == "Connect" and Survivor then
		Connections(Player, Survivor)
	elseif Command == "Cancel" then
		--	Cancelation(Player)
	elseif (Command == "Drop_Default" or Command == "Hooked" or Command == "Rescued") and Player.Character:GetAttribute("Carry") then
		local Survivor, Survivor_Content = Player.Character:GetAttribute("Carry"), nil

		if Survivor and game.Players:FindFirstChild(Survivor) then
			Survivor = game.Players:FindFirstChild(Survivor)
			Survivor_Content = Survivor:WaitForChild('Backpack'):WaitForChild('Scripts')
		else
			Survivor = nil
		end

		if Command == "Drop_Default" and Survivor and Survivor.Character then -- Dropping
			--BUG_READ:FireAllClients("Normal Drop:", tostring(Survivor) .. ':' .. tostring(Survivor.ClassName))

			if (Survivor_Content:WaitForChild('values'):WaitForChild('WiggleProgress').Value + 250) >= 1000 then
				local Stunned = playerValues:WaitForChild('Stunned')

				--BUG_READ:FireAllClients("SHOULD STUN US!:", Survivor.ClassName)

				if not Stunned.Value then
					code_module:Stun_Killer(Player, 'Wiggle')
					data_module:GiveBlood(Survivor, 1500, "Survival", "KILLER GRASP ESCAPE")
				end
				Player.Character:SetAttribute("Carry", nil)
				FreePlayer(Player, Survivor.Name) 

				coroutine.resume(coroutine.create(function()
					Survivor.Character.PrimaryPart.Anchored = false
					for l, ideas in pairs(Player.Character:GetDescendants()) do
						if ideas and ideas.Name == "GraspWeld" then
							ideas:Destroy()
						end
					end
					code_module:SetCollision(Survivor, 'Survivor')
					Survivor.Backpack.Scripts.values.HealthState.Value = 1
				end))

				Survivor_Content:WaitForChild('values'):WaitForChild('WiggleProgress').Value = 0
				return -- reset wiggle --
			else
				--BUG_READ:FireAllClients("SHOULD BE ADDING PROGRESS:", Survivor_Content:WaitForChild('values'):WaitForChild('WiggleProgress').Value)
				Survivor_Content:WaitForChild('values'):WaitForChild('WiggleProgress').Value += 250
				--BUG_READ:FireAllClients("WIGGLE RESULTS: ".. Survivor_Content:WaitForChild('values'):WaitForChild('WiggleProgress').Value)
				--BUG_READ:FireAllClients("---------------")
			end

			Survivor.Backpack:WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Holded').Value = false -- Prevents Wiggling Further --
			playerValues.KillerAction.Value = "Dropping" -- Blind/Stun Safety --

			Player.Character.PrimaryPart.Anchored = true -- anchor killer to current location

			-- Reset Action Animation --
			local Length = (Settings.Length.Drop - 0.2)
			Length *= Player.Backpack.Scripts.PerksBase["Rigged Game"]:GetAttribute("Percentage")
			Player.Character:SetAttribute("Action_Animation", "")
			task.wait(0.1)

			Survivor.Backpack:WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "BeingDropped" -- lets survivor know to stop moving

			-- If we have drop speed perks we would adjust values here --

			-- Survivor and Killer welded and in animation position = SEND SIGNAL TO ANIMATE NOW --
			Player.Character:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
			Player.Character:SetAttribute("Action_Animation", "Drop_Default")

			Survivor.Character:SetAttribute("Action_Animation_Time", Player.Character:GetAttribute("Animation_Time"))
			Survivor.Character:SetAttribute("Action_Animation", "Drop_Default")

			task.wait(Length - 0.1) -- animation should be done playing on all clients

			if not Player.Character:GetAttribute("Carry") then return Cancelation(Player) end -- Was Saved...
			Player.Character:SetAttribute("Carry", nil)
			FreePlayer(Player, Survivor.Name) -- releases survivor completly and removes carry attribute
			Survivor.Character:SetAttribute('Motion_Locked', false) -- allow movement again

			task.wait(0.1)

			playerValues.KillerAction.Value = "Nothing" -- changes killer action/let killer know to play carry idle--

			if Survivor and Survivor.Backpack.Scripts.values.HealthState.Value <= 0 then
				code_module:SetCollision(Survivor, 'Downed')
			end
			Survivor.Character.HumanoidRootPart.CFrame = Player.Character.PrimaryPart.CFrame 
			Player.Character.PrimaryPart.Anchored = false -- unanchor killer from current location
		elseif Command == "Rescued" then -- Stun --
			print('Rescue Portion!')
			FreePlayer(Player, Survivor.Name) -- releases survivor w/ out healing and removes killer carry attribute
			Player.Character:SetAttribute("Carry", nil)
			if Survivor then
				Survivor.Character.HumanoidRootPart.CFrame = Player.Character.PrimaryPart.CFrame 
				code_module:SetEffect("IFrame", Survivor, Settings.IFrames,"Struggle") -- last for duration | COUNTER SWING BUG
				Survivor_Content:WaitForChild('values'):WaitForChild('WiggleProgress').Value = 0 -- reset wiggle
				Survivor_Content:WaitForChild('values'):WaitForChild('HealthState').Value = 1 -- healed
				Survivor.Character:SetAttribute('Motion_Locked', false) -- allow movement again
			end
		elseif Command == "Hooked" then -- HOOKED --
			FreePlayer(Player, Survivor.Name)
			Player.Character:SetAttribute("Carry", nil)
			if Survivor then
				Survivor_Content:WaitForChild('values'):WaitForChild('WiggleProgress').Value = 0 -- reset wiggle
				Survivor_Content:WaitForChild('values'):WaitForChild('HealthState').Value = 1 -- healed
			end
		else -- Left / (BUGGED DROPPING)
			BUG_READ:FireAllClients("Bugged Drop:", Command, Survivor)

			FreePlayer(Player) -- releases survivor w/ out healing and removes killer carry attribute

			Player.Character:SetAttribute("Action_Animation", "Soft_Reset") -- fixes camera issues
			Survivor.Character.HumanoidRootPart.CFrame = Player.Character.PrimaryPart.CFrame 
			if Survivor then
				BUG_READ:FireAllClients("Bugged Drop 2:", Survivor.ClassName)

				Survivor_Content:WaitForChild('values'):WaitForChild('WiggleProgress').Value = 0 -- reset wiggle
				Survivor.Character:SetAttribute('Motion_Locked', false) -- allow movement again
			end
		end

		if Player.Character.PrimaryPart:FindFirstChild("GraspWeld") then
			Player.Character.PrimaryPart:WaitForChild('GraspWeld'):Remove()
		end
	elseif (Command == "Pickup_Default") and Survivor and Survivor.Parent and Survivor:FindFirstChild('Backpack') then
		-- Playing animation on clients so set up timers
		playerValues.KillerAction.Value = "GraspBegin" --TODO: will want to change, but keep same for now
		Events.onGrasp:Fire(Player, Survivor)
		Player.Character.PrimaryPart.Anchored = true -- anchor killer to current location

		Survivor.Backpack:WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "GettingCarried" -- lets survivor know to stop moving

		task.wait(0.1)

		if Survivor and Survivor.Parent then
			Survivor.Character.PrimaryPart.Anchored = true -- anchor them to tween tem

			local Tween = TweenService:Create(Survivor.Character.PrimaryPart, TweenInfo.new(0.1), {CFrame = Player.Character.PrimaryPart.CFrame * Settings.Offset.Carry})
			Tween:Play()
			Tween.Completed:Wait()
		end

		-- Reset Action Animation --
		local Length = (Settings.Length.Carry - 0.2)
		local hasPerk, PerkTier = data_module:GetPerk("Tight Grip", Player)
		if hasPerk then
			Length *= (FOUND_MODULE.Tiers[PerkTier]*-1+2)
		end
		Length *= Player.Backpack.Scripts.PerksBase["Rigged Game"]:GetAttribute("Percentage")
		Player.Character:SetAttribute("Action_Animation", "")
		task.wait(0.1)

		-- If we have pickup speed perks we would adjust values here --

		-- Survivor and Killer Anchored and in animation position = SEND SIGNAL TO ANIMATE NOW --
		Player.Character:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
		Player.Character:SetAttribute("Action_Animation", "Pickup_Default")

		if Survivor and Survivor.Parent then
			Player.Character:SetAttribute("Carry", Survivor.Name) -- lets survivor know they need to be carried + blind

			Survivor.Character:SetAttribute("Action_Animation_Time", Player.Character:GetAttribute("Animation_Time"))
			Survivor.Character:SetAttribute("Action_Animation", "Pickup_Default")
		end


		task.wait(Length - 0.1) -- animation should be done playing on all clients
		if not Player.Character:GetAttribute("Carry") or not Survivor or not Survivor.Parent then return Cancelation(Player) end -- Was Saved...

		if Survivor then
			Survivor.Backpack:WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value = "InCarry" -- lets survivor know to stop moving
			Survivor.Backpack:WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Holded').Value = true -- auto play idle carry animation now
		end
		-- Let Survivor/Killer know to auto-play carry idle animations ahead of time ^ --

		task.wait(0.1)
		if not Player.Character:GetAttribute("Carry") or not Survivor or not Survivor.Parent then return Cancelation(Player) end -- Was Saved...

		playerValues.KillerAction.Value = "Nothing" -- changes killer action/let killer know to play carry idle--

		if Survivor then
			Survivor.Character.Humanoid.PlatformStand = true -- removes control from survivor
			Survivor.Character.PrimaryPart.Anchored = false
		end
		if Survivor then
			WeldTogether(Player.Character.PrimaryPart, Survivor.Character.PrimaryPart, Settings.Offset.Carry)
			code_module:SetCollision(Survivor, 'Carry') -- >> remove survivor collision
		end
		Player.Character.PrimaryPart.Anchored = false -- unanchor killer from current location

		--[[
		NOTE: Normally we would have connections for stunning and such here, but I think it's inheartily flawed
		to handle logic this way so we will have that part of code as a isolated event instead so it works for
		lockers without the need to retype it all connections/fail-safes
		]]--

		module:Fire(Player, {"", "Connect", Survivor}) -- bind/bound us to carry connections
	end
end

return module