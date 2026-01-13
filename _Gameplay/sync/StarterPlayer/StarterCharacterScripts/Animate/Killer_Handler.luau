local Runservice, ReplicatedStorage = game:GetService('RunService'), game:GetService('ReplicatedStorage')

local Assets = ReplicatedStorage:WaitForChild('Game_Assets'):WaitForChild('Animations')

local Player = game.Players.LocalPlayer
local Character = Player.Character

local ValidActions = {"Swing","Lunge","Nothing","PowerAct","Charge","Bell Use","Cancel Bell","Charging_Hatchet","Aiming_Hatchet","Throwing","Start_Aiming","Aiming","Hiding","Cancel_Charge","Dashing","Stalking","Slamming","Charging_Shock","Rush_Charge","Charging","Blinking","Holding_Blink","Charging_Blink"}

local Killer_Character = Player:WaitForChild('Data'):WaitForChild('Killer')

local Handler = {
	IsRunning = false;
	Connections = {};
	Tracks = {};
	Action_Tracks = {};
}

local Humanoid, Rootpart = Character:WaitForChild('Humanoid'), Character:WaitForChild('HumanoidRootPart')

function PlayAnimation(Track : Animation, Speed : number) : "Play Animation"
	
	if Track then

		if not Handler.Tracks[Track] then -- Create Track
			Handler.Tracks[Track] = Humanoid:LoadAnimation(Track)
		end
		
		if not Handler.Tracks[Track].IsPlaying then
			Handler.Tracks[Track]:Play()
			Handler.Tracks[Track]:AdjustSpeed(Speed)
		else
			Handler.Tracks[Track]:AdjustSpeed(Speed)
		end
	end
	
	for _, animation in pairs(Handler.Tracks) do -- close animations
		if animation == Handler.Tracks[Track] then continue end
		if not animation.IsPlaying then continue end
		animation:Stop()
	end
end

function StopAnimations()
	for _, animation in pairs(Handler.Tracks) do 
		if animation then
			animation:Stop()
		end
	end
end

function PlaySpecial(Track : Animation, Speed : number) : "Play Secondary Animation"

	if Track then

		if not Handler.Action_Tracks[Track] then -- Create Track
			Handler.Action_Tracks[Track] = Humanoid:LoadAnimation(Track)
		end

		if not Handler.Action_Tracks[Track].IsPlaying then
			Handler.Action_Tracks[Track]:Play()
			Handler.Action_Tracks[Track]:AdjustSpeed(Speed)
		else
			Handler.Action_Tracks[Track]:AdjustSpeed(Speed)
		end
	end

	for _, animation in pairs(Handler.Action_Tracks) do -- close animations
		if animation == Handler.Action_Tracks[Track] then continue end
		if not animation.IsPlaying then continue end
		animation:Stop()
	end
end

function AnimationCycle(Step : number)
	local IsMoving : boolean = (Humanoid.MoveDirection.Magnitude > 0.1)
	local IsCarry : boolean = (Character:GetAttribute("Carry") ~= "" and Character:GetAttribute("Carry") ~= nil)
	local Power_State : string = Character:GetAttribute("Power_State")
	local Animation, Speed = nil, 1
	local KAction = Player.Backpack.Scripts.values.KillerAction
	local ValidAction = true
	for i, B in pairs(ValidActions) do
		if KAction.Value == B then
			ValidAction = true
		end
	end
	
	if ValidAction == false then
		StopAnimations()
		return
	end
	
	if IsCarry then -- Carry is Special Action Animation = Hold no weight over normal movement
		local Animation_2 : "Action Track", Speed_2 = nil, 1
		
		if IsMoving then

			if Assets:WaitForChild('Carry'):WaitForChild('Killer'):FindFirstChild("Carry_"..Killer_Character.Value) then
				Animation_2 = Assets:WaitForChild('Carry'):WaitForChild('Killer'):WaitForChild("Carry_"..Killer_Character.Value)
			else
				--warn(Killer_Character.Value..'_Walk', 'does not exist')

				Animation_2 = Assets:WaitForChild('Carry'):WaitForChild('Killer'):WaitForChild('Carry_Default')
			end
		else

			if Assets:WaitForChild('Carry'):WaitForChild('Killer'):FindFirstChild("Carry_"..Killer_Character.Value) then
				Animation_2 = Assets:WaitForChild('Carry'):WaitForChild('Killer'):WaitForChild("Carry_"..Killer_Character.Value)
			else
				--warn(Killer_Character.Value..'_Walk', 'does not exist')

				Animation_2 = Assets:WaitForChild('Carry'):WaitForChild('Killer'):WaitForChild('Carry_Default')
			end
		end
		
		PlaySpecial(Animation_2, Speed_2)
	else
		local Animation_2 : "Action Track", Speed_2 = nil, 0
		
		if Killer_Character.Value == "Ninja" and Power_State == "Hidden" then
			Speed_2 = 1
			
			if IsMoving then
				Animation_2 = Assets:WaitForChild('Ninja'):WaitForChild('Crouch_Walk')
				Speed_2 = Animation_2:GetAttribute("Speed") * Humanoid.WalkSpeed
			else -- play idle
				Animation_2 = Assets:WaitForChild('Ninja'):WaitForChild('Crouch')
			end
		end
		
		PlaySpecial(Animation_2, Speed_2)
	end
	
	if IsMoving then -- Normal Movement Tracks
		
		if Assets:WaitForChild('Movement'):WaitForChild('Killer'):FindFirstChild(Killer_Character.Value..'_Walk') then
			Animation = Assets:WaitForChild('Movement'):WaitForChild('Killer'):WaitForChild(Killer_Character.Value..'_Walk')
		else
			--warn(Killer_Character.Value..'_Walk', 'does not exist')
			
			Animation = Assets:WaitForChild('Movement'):WaitForChild('Killer'):WaitForChild('Default_Walk')
		end
		
		Speed = Animation:GetAttribute("Speed") * Humanoid.WalkSpeed
	else
		
		if Assets:WaitForChild('Movement'):WaitForChild('Killer'):FindFirstChild(Killer_Character.Value..'_Idle') then
			Animation = Assets:WaitForChild('Movement'):WaitForChild('Killer'):WaitForChild(Killer_Character.Value..'_Idle')
		else
			--warn(Killer_Character.Value..'_Idle', 'does not exist')
			
			Animation = Assets:WaitForChild('Movement'):WaitForChild('Killer'):WaitForChild('Default_Idle')
		end
		
		Speed = Animation:GetAttribute("Speed")
	end
	
	PlayAnimation(Animation, Speed)
end

function Handler:Run()
	if Handler.IsRunning then return warn("Already Running...") end
	Handler.IsRunning = true

	if Handler.Connections.Player then -- disconnect animation player
		Handler.Connections.Player:Disconnect()
	end
	
	Handler.Connections.Player = Runservice.Heartbeat:Connect(AnimationCycle) -- bind animation player
end

function Handler:Stop()
	if not Handler.IsRunning then return end
	Handler.IsRunning = false
	
	if Handler.Connections.Player then -- disconnect animation player
		Handler.Connections.Player:Disconnect()
		Handler.Connections.Player = nil
	end
	
	PlayAnimation(nil, 0)
	PlaySpecial(nil, 0)
end

return Handler
