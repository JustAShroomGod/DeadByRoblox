local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
--local keybinds = script.Parent.Parent:WaitForChild('Keybinds')

local SkillChecksFrame = game.Players.LocalPlayer:WaitForChild('PlayerGui'):WaitForChild("HUD"):WaitForChild('Controls_Display'):WaitForChild('SkillChecks')

local Remotes = ReplicatedStorage:WaitForChild('RemoteEvents')
local Event = Remotes:WaitForChild('SendSkillCheck')

local Prefix = "rbxassetid://"

local AudioIds = {
	['Alert'] = Prefix..1479839128;
	['Bad'] = Prefix..9476395954;
	['Good'] = Prefix..1480001625;
	['Great'] = Prefix..1479888663;
}

local ImageIds = {
	['Normal'] = Prefix..1296267849;
	['decisive'] = Prefix..2770743202;
}

local skillchecks = 0

local Skill = {
	Connections = {};
	Checks = {};
}
Skill.__index = Skill

---

local function GetDelay(Type : "Normal" | nil) : "Generate new delay between skill checks"

	if Type == "Normal" then
		return math.random(2, 20) -- delay between 1/15 seconds for now later we will check for special perks --
	else
		warn('I do not support:', Type, "skill checks!")
	end
end

local function getRange(Type : "Normal" | nil, Direction : number) : "Create Skill Check Angle"

	if Type == "Normal" then
		return math.random(-50, 120)
	end
end

function Skill:End() : "end skill check w/ out missing" -- closes without error if skill check is appearing --
	self.Paused = true
	
	if self.Current.Frame then
		self.Current.Frame:Destroy()
		self.Current.Sound:Destroy()
		self.Current = nil
	end
	
	Skill.Checks[self.Name] = nil
end

function Skill:Hit() : "hit skill check" -- us pressing space on a skill check --
	if self.Function.Hit then return end
	self.Function.Hit = true
	
	if self.Current.Frame.Visible then
		local savedRotation, savedDifference = self.Current.Frame.Arrow.Rotation, self.Current.Frame.Background.Rotation
		
		self.Function.LastSpawn = workspace:GetServerTimeNow() -- getting new end
		self.Settings.Frequency = GetDelay(self.Settings.Type or "Normal") or 5; -- reset the frequency rate

		if self.Settings.Type == "Normal" then
			local result = savedDifference - savedRotation

			if result >= 15 and result <= 25 then
				self.Event("Great")
				game.ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Sound_Event'):Fire("Skill_Great")
			elseif result >= -28 and result <= 15 then
				self.Event("Good")
				game.ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Sound_Event'):Fire("Skill_Good")
			else
				self.Event("Bad")
				game.ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Sound_Event'):Fire("Skill_Miss")
				
				if self.Miss then
					self.Miss()
				else -- default miss event
					warn("No custom miss event for", self.Name)
				end
			end
		end
		
		self:ForceReset() -- reset by force should change nothing from normal point, but prevent dupe skill checks i think
		
		if self.Function.Amount == -1 then -- keep going inf
			-- do nothing we got our delay and result
		elseif self.Function.Amount > 0 then -- repeat loop and subtract amount
			self.Function.Amount -= 1
		end
		
		if self.Function.Amount == 0 then -- we lost all skill checks
			self:End()
		end
	end
	
	self.Function.Hit = false
end

function Skill:Pause(boolean : boolean) : "Pause/Unpause"
	
	if boolean then
		self:Hit()
		self.Function.Paused = true
	else
		self.Settings.Frequency = GetDelay(self.Settings.Type or "Normal") or 1;
		self.Function.LastSpawn = workspace:GetServerTimeNow() -- getting new end
		self.Function.Paused = false
	end
end

function Skill:ForceReset()
	
	task.wait(0.5)

	if self.Current then -- hide the existance of the old skill check | reuse the same one so no loading time/optimization from not re-spawning
		self.Current.Frame.Visible = false
		self.Current.Sound.Volume = 0
		self.Current.Reset = false
	end
end

function Skill:Update(Control_Type : "Controller" | "Mobile" | "Keyboard") : "Update skill check arrow and sounds"
	if self.Function.Paused then --[[we are paused or cancelled]]
		if self.Current then -- hide the existance of the old skill check | reuse the same one so no loading time/optimization from not re-spawning
			self.Current.Frame.Visible = false
			self.Current.Sound.Volume = 0
			self.Current.Reset = false
		end
		
		return
	end
	
	----- Interupted skill check -----
	-- || We got interupted or we don't have enough time between last skill check || --

	if (workspace:GetServerTimeNow() - self.Function.LastSpawn) <= self.Settings.Frequency then
		self:ForceReset()
		return -- end the function here
	end
	
	--warn(workspace:GetServerTimeNow() - self.Function.LastSpawn, 'is time elapsed --', self.Settings.Frequency)
	----- || need to generate a skill check || -----

	if not self.Current.Reset then
		self.Current.Reset = true
		
		-- Apply/Reset the Direction
		if self.Settings.Direction == 1 then
			self.Current.Direction = 1
		elseif self.Settings.Direction == 2 then
			self.Current.Direction = -1
		elseif self.Settings.Direction == 3 then -- mixed skill checks so do random

			if math.random() >= 0.5 then
				self.Current.Direction = 1
			else
				self.Current.Direction = -1
			end
		end
		
		-- Apply/Reset the Rotation --
		self.Current.Frame.Background.Rotation = getRange(self.Settings.Type, self.Current.Direction)
		self.Current.Frame.Arrow.Rotation = -180
		self.Current.Frame.Arrow.Visible = false
		
		if self.Settings.Audio >= 0 then -- if audio is less then 0 do not play!
			game.ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Sound_Event'):Fire("Skill_Alert")
			--self.Current.Sound:Play() -- play the noise
		end
		
		self.Current.Spawned = workspace:GetServerTimeNow()
	end

	----- Update rotation -----
	
	if self.Current.Frame:FindFirstChild(Control_Type) then
		self.Current.Frame[Control_Type].Visible = true
	else -- mobile or doesn't exist
		self.Current.Frame.Keyboard.Visible = false
		self.Current.Frame.Controller.Visible = false
	end
	
	if (workspace:GetServerTimeNow() - self.Current.Spawned) >= (self.Settings.Audio - 0.25) and not self.Current.Frame.Visible then --- if time elapses start check
		self.Current.Frame.Visible = true
	end

	if (workspace:GetServerTimeNow() - self.Current.Spawned) < self.Settings.Audio then
		return -- used to stop early rotation
	else
		self.Current.Frame.Arrow.Visible = true
	end

	if self.Current.Frame.Visible then
		self.Current.Frame.Arrow.Rotation = -180 + (((workspace:GetServerTimeNow() - self.Current.Spawned) - self.Settings.Audio) * (self.Settings.Speed * 45) * self.Current.Direction)
		
		if self.Current.Frame.Arrow.Rotation <= -540
			or self.Current.Frame.Arrow.Rotation >= 180 then -- done full rotation
			
			self:Hit()
		end
	end
end

function Skill.new(...) : "Creates a skill check loop" -- forms new skill check loop
	local args = {...}
	
	local skillCheck = {}
	setmetatable(skillCheck, Skill)
	
	local skillInfo = args[1] -- should be table of skill check information
	skillchecks += 1
	
	skillCheck.Name = skillInfo.Name or "Skill_"..skillchecks
	
	Skill.Checks[skillCheck.Name] = skillCheck
	
	-- Applying Skill Check Settings --
	skillCheck.Settings = {
		Direction = skillInfo.Direction or 1; -- 1 = normal, 2 = reversed only, 3 = both;
		Speed = skillInfo.Speed or 6;
		Audio = skillInfo.Audio or .75;
		Type = skillInfo.Type or "Normal";
		Object = skillInfo.Object or nil; -- where we send skill checks
		Frequency = GetDelay(skillInfo.Type or "Normal") or 5; -- create the frequency rate
	}
	
	skillCheck.Current = {
		Spawned = 0; -- time we were spawned to keep consistant arrow speed
		Direction = 0; -- 0 = normal, 1 = backwards
	}
	
	-- Skill Check Function/Variables --
	skillCheck.Function = {
		LastSpawn = 0; -- last skill time we spawned a skill check
		Amount = skillInfo.Amount or 1; -- amount of skill checks left to play | if -1 then infinate
		Paused = true; -- if paused do not create new skill checks
		Hit = false;
	}
	
	skillCheck.Event = function(result)
		print(skillCheck.Name, 'trigged as', result)
	end
	
	skillCheck.Current.Frame = SkillChecksFrame:WaitForChild('Prefab'):WaitForChild('Template'):Clone()
	skillCheck.Current.Frame.Background.Image = ImageIds[skillCheck.Settings.Type]
	skillCheck.Current.Frame.Parent = SkillChecksFrame

	skillCheck.Current.Sound = Instance.new('Sound', game:GetService('SoundService'))
	skillCheck.Current.Sound.Volume = 0
	skillCheck.Current.Sound.SoundId = AudioIds.Alert
	
	return skillCheck
end

function Skill:GetSkills() -- updater for ui/controls
	return Skill.Checks
end

function Skill.Config()
	
	--[[Skill.Connections = Event.OnClientEvent:Connect(function(...)
		local args = {...}
		local skill_check, command, amount = Skill.Checks[args[1]..'_Skill_Checks'], args[2], args[3]
	
		if not skill_check then return warn(args[1], 'are not existing skill checks!') end
		
		if command == "Speed" then
			if not skill_check.Settings.Base_Speed then
				skill_check.Settings.Base_Speed = (skill_check.Settings.Speed + 0)
				skill_check.Settings.Current_Stack = 0
			end
			
			skill_check.Settings.Current_Stack += amount
			skill_check.Settings.Speed = math.clamp(skill_check.Settings.Base_Speed + ((skill_check.Settings.Current_Stack/100) * skill_check.Settings.Base_Speed), 0.1, math.huge)
		elseif command == "Direction" then -- normal = 1, reveresed = 2, mixed = 3
			skill_check.Settings.Direction = amount
		elseif command == "Type" then -- affects range of where to hit + frequency
			skill_check.Settings.Type = amount
		elseif command == "Audio" then -- amount of warning time needs no clamping
			skill_check.Settings.Audio += amount
		else
			warn(command, 'not a valid skill check command!')
		end
	end)]]
	
	return Skill
end

return Skill.Config()
