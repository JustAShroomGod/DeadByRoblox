local RunService : RunService,ReplicatedStorage : ReplicatedStorage,ServerStorage : ServerStorage, TweenService : TweenService = game:GetService("RunService"),game:GetService('ReplicatedStorage'),game:GetService('ServerStorage'), game:GetService("TweenService")

local Modules = {
	BadgeManager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("BadgeManager"));
	Code = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'));
	DataModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Data"))
}

local Item_Data = ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Items')

local GameAssets = ReplicatedStorage:WaitForChild("Game_Assets") 
local HookAnimations = GameAssets:WaitForChild("Animations"):WaitForChild("Hook"):WaitForChild("Object")

local PerkModules = {
	ColdComfort = require(ReplicatedStorage:WaitForChild("Game_Data"):WaitForChild("Perks"):WaitForChild("Survivor"):WaitForChild("Cold Comfort"))
}

local TweenInfo_Ice = TweenInfo.new(
	2,
	Enum.EasingStyle.Exponential,
	Enum.EasingDirection.InOut
)


local module = {
	Settings = {
		Hook_Depletion = 1000 / 120; -- 2 minutes same as dbd | (base-amount / desired_time)
		Hook_Depletion_Icy = (1000 / 120) + (1000/120) * PerkModules.ColdComfort.Slowness_Percentage;
	}
}
module.__index = module

local function hasBox(Player : Player) -- returns toolbox or nil
	local Character, Box = Player.Character, nil

	if Character and Character.Parent then
		
		for _, Model in pairs(Character:GetChildren()) do
			
			if Model:GetAttribute("Tool") and Model:GetAttribute("Class") == "Toolbox" then
				return Model
			elseif Model:GetAttribute("Tool") then
				break
			end
		end
	end

	return nil
end


local function Freeze(Ice : Model, Bool : boolean, DesiredCFrame : CFrame, Sound : Sound)
	if Bool then
		local Tween = TweenService:Create(Ice.PrimaryPart, TweenInfo_Ice, {CFrame = (DesiredCFrame - Vector3.new(0,2,0))})
		
		Ice.Particle.Smoke.Enabled = true
		Tween:Play()
		Sound:Play()
	else
		local Tween = TweenService:Create(Ice.PrimaryPart, TweenInfo_Ice, {CFrame = (DesiredCFrame - Vector3.new(0,15,0))})

		Ice.Particle.Smoke.Enabled = true
		Tween:Play()
		Sound:Play()
	end
end

function module.New(Object : "Hook")
	local self = {}
	setmetatable(self, module)
	
	self.Hook = Object
	self.Panel = self.Hook:WaitForChild("Panel")
	self.Animator = self.Hook:WaitForChild('Humanoid'):WaitForChild('Animator')
	self.Entity = self.Hook:WaitForChild("hookentity")
	self.Ice = self.Hook:WaitForChild("Ice")
	
	
	self.Connections = {}
	
	--moved to Game Assets folder so the animations can load in with preloadasync
	self.Animations = {
		Dropped = self.Animator:LoadAnimation(HookAnimations:WaitForChild('Hook_Dropped'));
		Broken = self.Animator:LoadAnimation(HookAnimations:WaitForChild('Hook_Broken'));

		Struggle = self.Animator:LoadAnimation(HookAnimations:WaitForChild('Entity_Struggle'));
		Sacrifice = self.Animator:LoadAnimation(HookAnimations:WaitForChild('Entity_Sacrifice'));
		Grab = self.Animator:LoadAnimation(HookAnimations:WaitForChild('Entity_Grab'));
	}
	
	self.Values = {
		Progress = self.Panel:WaitForChild("Progress");
		Sabotaging = self.Panel:WaitForChild("Sabotaging");
		IcePlayer = self.Panel:WaitForChild("IcePlayer");
		Ocuped = self.Panel:WaitForChild("Ocuped");
		Used = self.Panel:WaitForChild("Used");
		Basement = self.Panel:WaitForChild('Basement');
		Player = self.Panel:WaitForChild("Player");
		Icy = self.Panel:WaitForChild("Icy");
	}
	
	self.Sounds = {
		BrokenSound = self.Hook:WaitForChild("HumanoidRootPart"):WaitForChild("BrokenSound");
		IceSound = self.Hook:WaitForChild("HumanoidRootPart"):WaitForChild("IceSound");
	}
	
	self:Start()
	
	return self
end

function module:Start()
	local SaboConnection = nil
	local IceConnection = nil
	local Sabo_PerkProgress = nil
	
	local function SetEntityTransparency(Transparency : number) : "Set Transparency of the entity model"
		for _, child in ipairs(self.Entity:GetChildren()) do
			if child.ClassName == "MeshPart" or child.ClassName == "UnionOperation" or child.ClassName == "Part" and child.Name ~= "Torso" then
				child.Transparency = Transparency
			end
		end
	end
	
	
	self.Values.Player.Changed:Connect(function()
		if workspace:FindFirstChild(self.Values.Player.Value) then
			local splashSound = Instance.new("Sound")
			splashSound.Name = "SplashSound"
			splashSound.RollOffMinDistance = 1
			splashSound.RollOffMaxDistance = 90
			splashSound.Volume = 8
			splashSound.SoundId = "rbxassetid://3198541209"
			splashSound.Parent = self.Hook:WaitForChild("Hitch")
			splashSound.Playing = true

			local endCon endCon = splashSound.Ended:Connect(function()
				endCon:Disconnect()
				splashSound:Destroy()
			end)
		end
	end)

	self.Values.Icy.Changed:Connect(function()
		Freeze(self.Ice, self.Values.Icy.Value, self.Hook.PrimaryPart.CFrame, self.Sounds.IceSound)
	end)

	self.Values.Sabotaging.Changed:Connect(function()
		if self.Hook:GetAttribute("CustomSaboTime") and not self.Values.Ocuped.Value and self.Values.Player.Value == "Nobody" then
			local timetoWait = self.Hook:GetAttribute("CustomSaboTime")

			task.wait(timetoWait)

			self.Values.Used.Value = false
			self.Values.Sabotaging.Value = nil
			self.Values.Progress.Value = 0
			
			self.Hook:SetAttribute("CustomSaboTime",nil)
		end

		local function closeFunction()
			if SaboConnection then
				SaboConnection:Disconnect()
				SaboConnection = nil

				if not self.Values.Used.Value and self.Values.Progress.Value ~= 0 then -- reset progress
					self.Values.Progress.Value = 0
				end
			end
		end

		if self.Values.Sabotaging.Value and not self.Values.Basement.Value and not self.Hook:GetAttribute("CustomSaboTime") then
			local toolboxtorun = hasBox(self.Values.Sabotaging.Value)

			if toolboxtorun then
				local Tool_Module = require(Item_Data:WaitForChild(toolboxtorun.Name))
				local increaseSpeed, timetoWait = 200, 20

				if Tool_Module then
					increaseSpeed *= toolboxtorun['Server-Script'].Speed.Value
					timetoWait += Tool_Module.Sabatage_Time_Bonus
				end

				SaboConnection = RunService.Heartbeat:Connect(function(step)
					if self.Values.Progress.Value < 1000 then
						self.Values.Progress.Value += step * increaseSpeed
					else

						if not self.Values.Used.Value or self.Values.Sabotaging.Value then
							self.Values.Used.Value = true
							self.Values.Sabotaging.Value = nil

							coroutine.wrap(function()
								task.wait(timetoWait)

								self.Values.Used.Value = false
								self.Values.Sabotaging.Value = nil
								self.Values.Progress.Value = 0
							end)()
						end

						if SaboConnection then
							SaboConnection:Disconnect()
							SaboConnection = nil
						end
					end
				end)
			else
				closeFunction()
			end
		else
			closeFunction()
		end
	end)
	
	self.Values.IcePlayer.Changed:Connect(function()
		local function closeFunction()
			if IceConnection then
				IceConnection:Disconnect()
				IceConnection = nil

				self.Values.Progress.Value = 0
			end
		end

		if self.Values.IcePlayer.Value and not self.Values.Basement.Value then
			local increaseSpeed = 200

			IceConnection = RunService.Heartbeat:Connect(function(step)
				if self.Values.Progress.Value < 1000 then
					self.Values.Progress.Value += step * increaseSpeed
				else
					self.Values.Icy.Value = true

					self.Values.IcePlayer.Value.Backpack.Scripts.PerksBase["Cold Comfort"]:SetAttribute("Count", 0)

					if IceConnection then
						IceConnection:Disconnect()
						IceConnection = nil
					end
					
					closeFunction()
				end
			end)
		else
			closeFunction()
		end
	end)
	
	while task.wait(1) do
		local Hooked_Player = game.Players:FindFirstChild(self.Values.Player.Value)

		--[[ handles the hook breaking ]]--
		if not Hooked_Player and self.Values.Used.Value and not self.Values.Basement.Value
			and (not self.Animations.Dropped.IsPlaying and not self.Animations.Broken.IsPlaying) then -- break the hook part of code

			self.Sounds.BrokenSound:Play()
			self.Animations.Dropped:Play()
			self.Animations.Dropped:AdjustSpeed(1.5)

			self.Connections.Drop_Connection = self.Animations.Dropped.Stopped:Once(function()
				self.Animations.Broken:Play()
			end)
		elseif not self.Values.Used.Value and (self.Animations.Dropped.IsPlaying or self.Animations.Broken.IsPlaying) then
			if self.Animations.Dropped.IsPlaying then self.Animations.Dropped:Stop() end
			if self.Animations.Broken.IsPlaying then self.Animations.Broken:Stop() end
		end
		--[[ handles the hook breaking ]]--

		--[[handles the hook animations]]--

		if Hooked_Player then
			local Hooked_Character = Hooked_Player.Character
			local hookBlood = string.split(Hooked_Character:GetAttribute("Hook_Blood"), ':')
			local hookStage = string.split(Hooked_Character:GetAttribute("Hook_Stage"), ':')
			local AutoKill : boolean = false

			local Entity_Visibility : number = math.clamp(tonumber(hookBlood[1])/tonumber(hookBlood[2]), 0.5, 1)/0.5-1

			SetEntityTransparency(Entity_Visibility)

			if self.Values.Basement.Value then
				
				for _, Killer in pairs(game.Teams:WaitForChild('Killer'):GetPlayers()) do
					Modules.BadgeManager.Award("Basement Gamer", Killer.UserId)
				end
			end

			Hooked_Character:SetAttribute("Hook_Blood", (tonumber(hookBlood[1]) - if self.Values.Icy.Value then module.Settings.Hook_Depletion_Icy else module.Settings.Hook_Depletion)..':'..tonumber(hookBlood[2]))

			if ((tonumber(hookBlood[1])/tonumber(hookBlood[2])) * 100) > 50 and tonumber(hookStage[1]) == 2 then
				Hooked_Character:SetAttribute("Hook_Blood", ((tonumber(hookBlood[2])/100) * 50)..':'..tonumber(hookBlood[2]))
			elseif ((tonumber(hookBlood[1])/tonumber(hookBlood[2])) * 100) > 0 and tonumber(hookStage[1]) >= 3 then
				Hooked_Character:SetAttribute("Hook_Blood", ((tonumber(hookBlood[2])/100) * 0)..':'..tonumber(hookBlood[2]))
			end
			
			if ((tonumber(hookBlood[1])/tonumber(hookBlood[2])) * 100) <= 50 and tonumber(hookStage[1]) < 2 then
				Hooked_Character:SetAttribute("Hook_Stage", '2:'..hookStage[2])
			elseif ((tonumber(hookBlood[1])/tonumber(hookBlood[2])) * 100) <= 0 and tonumber(hookStage[1]) < 3 then
				Hooked_Character:SetAttribute("Hook_Stage", '3:'..hookStage[2])
			end

			if #game.Teams:WaitForChild('Survivor'):GetPlayers() > 1 then
				AutoKill = true

				for _, Player in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do
					if Player == Hooked_Player then continue end
					local IsHooked = Player.Backpack.Scripts.values.Hooked

					if not IsHooked.Value then -- one of them is not hooked
						AutoKill = false
						break
					elseif ((tonumber(hookBlood[1])/tonumber(hookBlood[2])) * 100) > 50 then -- one person can still attempt
						AutoKill = false
						break
					end
				end
			elseif ((tonumber(hookBlood[1])/tonumber(hookBlood[2])) * 100) <= 50 then
				AutoKill = true
			end

			if ((tonumber(hookBlood[1])/tonumber(hookBlood[2])) * 100) > 50 then -- stage 1 or higher
				if self.Animations.Broken.IsPlaying then self.Animations.Broken:Stop() end
				if self.Animations.Dropped.IsPlaying then self.Animations.Dropped:Stop() end
				if self.Animations.Sacrifice.IsPlaying then self.Animations.Sacrifice:Stop() end
				if self.Animations.Struggle.IsPlaying then self.Animations.Struggle:Stop() end
				if self.Animations.Grab.IsPlaying then self.Animations.Grab:Stop() end
			elseif ((tonumber(hookBlood[1])/tonumber(hookBlood[2])) * 100) > 0 then -- stage 2
				if self.Animations.Broken.IsPlaying then self.Animations.Broken:Stop() end
				if self.Animations.Dropped.IsPlaying then self.Animations.Dropped:Stop() end
				if self.Animations.Sacrifice.IsPlaying then self.Animations.Sacrifice:Stop() end

				if not self.Animations.Struggle.IsPlaying and not self.Animations.Grab.IsPlaying then
					self.Animations.Grab:Play()

					self.Connections.Grab_Connection = self.Animations.Grab.Stopped:Once(function()
						if not Hooked_Player then return end
						self.Animations.Struggle:Play()
					end)
				end
			else -- dead/stage 3
				if self.Animations.Broken.IsPlaying then self.Animations.Broken:Stop() end
				if self.Animations.Dropped.IsPlaying then self.Animations.Dropped:Stop() end
				if self.Animations.Grab.IsPlaying then self.Animations.Grab:Stop() end
				if self.Animations.Struggle.IsPlaying then self.Animations.Struggle:Stop() end

				if not self.Animations.Sacrifice.IsPlaying then
					self.Animations.Sacrifice:Play()
				end
			end

			if tonumber(hookStage[1]) >= 3 or ((tonumber(hookBlood[1])/tonumber(hookBlood[2])) * 100) <= 0 or AutoKill then
				Modules.Code:AddDeath(Hooked_Player)

				self.Values.Ocuped.Value = false
				self.Values.Player.Value = "Nobody"

				if not self.Values.Basement.Value then
					self.Values.Used.Value = true
				end
				
				Modules.BadgeManager.Award("Sacrifice", Hooked_Player.UserId)
				
				local Killers = Modules.Code:getKiller()
				local Reward, Text = 500, 'SACRIFICE'
				
				if workspace:GetAttribute("Endgame") then
					Reward, Text = 1000, 'LATE SACRIFICE'
				end
				
				if Killers then
					
					if typeof(Killers) == "table" then
						
						for _, Killer in pairs(Killers) do
							Modules.DataModule:GiveBlood(Killer, Reward, "Hunter", Text)
						end
					else
						Modules.DataModule:GiveBlood(Killers, Reward, "Hunter", Text)
					end
				end
			end

			if Hooked_Character and Hooked_Character.Parent and Hooked_Character:WaitForChild("Humanoid").Health == 0 then
				self.Values.Ocuped.Value = false
				self.Values.Player.Value = "Nobody"
			elseif not Hooked_Character or not Hooked_Character.Parent then
				self.Values.Ocuped.Value = false
				self.Values.Player.Value = "Nobody"
			end
		else
			if self.Animations.Grab.IsPlaying then self.Animations.Grab:Stop() end

			if self.Animations.Sacrifice.IsPlaying then
				SetEntityTransparency(0)
			else
				SetEntityTransparency(1)
			end

			if self.Values.Player.Value ~= "Nobody" and self.Values.Ocuped.Value then
				self.Values.Ocuped.Value = false
				self.Values.Player.Value = "Nobody"
			end
		end
	end
end

return module
