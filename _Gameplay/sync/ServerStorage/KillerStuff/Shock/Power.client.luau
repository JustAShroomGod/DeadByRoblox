--[[local plr = game:GetService("Players").LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local replicated_storage = game:GetService("ReplicatedStorage")
local run_service = game:GetService("RunService")
local user_input_service = game:GetService("UserInputService")

local datastorage = plr:WaitForChild('DataStorage')

local mouse = plr:GetMouse()
local camera = workspace.CurrentCamera

local backpack = plr:WaitForChild("Backpack")
local Scripts = backpack:WaitForChild("Scripts")
local killer = Scripts:WaitForChild("Killer")
local character = datastorage:WaitForChild('LoadOut'):WaitForChild('Killer')

local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

local values = Scripts:WaitForChild("values")
local reset_bloodlust = values:WaitForChild("reset_bloodlust")
local killerAction = values:WaitForChild("KillerAction")
local globalKiller = Scripts:WaitForChild("GlobalKiller")

local betterUpdate = replicated_storage:WaitForChild("RemoteEvents"):WaitForChild("NewPropertie")
local shockPowerAction = replicated_storage:WaitForChild("RemoteEvents"):WaitForChild("ShockPowerAction")

local animTrack

local prefix = "rbxassetid://"
local animations = {
	["Switch"] = 03116990808,
	["Hold"] = 03116992955,
	["Shock"] = 03116995143
}

for wAction, animationId in pairs (animations) do
	local animation = Instance.new("Animation", humanoid)
	animation.AnimationId = prefix.. tostring(animationId)
	animations[wAction] = animation
end

local killerModulesNames = {"Speeds"}
local killerModules = {}

for v0, moduleName in pairs (killerModulesNames) do
	killerModules[moduleName] = require(globalKiller:WaitForChild(moduleName.. "Module"))
end

function Obfuscate(TYPE, VALUE1, VALUE2)
	local tablev = {}
	local List = {"Bbh1O", "D9v8", "Db~1O", "Dvh1O", "Dhv8"}

	TYPE = string.lower(TYPE)

	if TYPE == 'string' then
		TYPE = 'S101'
	elseif TYPE == 'object' then
		TYPE = 'O101'
	elseif TYPE == 'number' then
		TYPE = 'I101'
	elseif TYPE == 'bool' then
		TYPE = 'B101'
	end

	local Packaged = {
		['C22'] = TYPE;
		['C21'] = VALUE1;
		['C20'] = VALUE2;
	}

	for _,key in pairs(List) do
		tablev[key] = Packaged
	end

	betterUpdate:FireServer(tablev)
end

if plr.Name ~= "AerooDev" then
	function switchTreatment(dir)
		local switchDownCon, switchUpCon, completedCon, stoppedCon
		local shockDownCon, shockUpCon
		local function connectAction()
			Obfuscate("string", killerAction, "ShockTherapy")
			animTrack = humanoid:LoadAnimation(animations["Hold"]) animTrack:Play() animTrack:AdjustSpeed(1)

			shockDownCon = mouse.Button1Down:Connect(function()
				if shockDownCon then shockDownCon:Disconnect() end
				if animTrack then animTrack:Stop() animTrack = nil end

				Obfuscate("string", killerAction, "ShockCharge")

				local cancel = false

				spawn(function() 
					humanoid.WalkSpeed = killerModules["Speeds"]:GetSpeeds("Doctor")["Movement"]*0.57 
					task.wait()
					humanoid.WalkSpeed = killerModules["Speeds"]:GetSpeeds("Doctor")["Movement"]*0.98

					if cancel then
						return
					end

					reset_bloodlust.Value = true

					shockPowerAction:FireServer(rootPart)
					wait(1.8)
					switchTreatment(-1)
				end)

				if switchDownCon then switchDownCon:Disconnect() end
			end)

		end if dir == -1 then connectAction() end

		switchDownCon = mouse.Button2Down:Connect(function()
			if shockDownCon then shockDownCon:Disconnect() end

			if dir == 1 then

				if killerAction.Value ~= "Nothing" and killerAction.Value ~= "TreatmentSwitch" then
					return
				else
					if switchDownCon then switchDownCon:Disconnect() end
				end
			else
				if switchDownCon then switchDownCon:Disconnect() end
			end

			humanoid.WalkSpeed = killerModules["Speeds"]:GetSpeeds("Doctor")["Movement"]*0.98
			Obfuscate("string", killerAction, "TreatmentSwitch")

			local function disconnect()
				if animTrack then animTrack = nil end
				if completedCon then completedCon:Disconnect() end
			end

			if animTrack then animTrack:Stop() animTrack = nil end

			animTrack = humanoid:LoadAnimation(animations["Switch"])
			animTrack:Play()
			animTrack:AdjustSpeed(dir*2)

			animTrack.TimePosition = animTrack.Length - (animTrack.Length * dir)

			completedCon = animTrack.Stopped:Connect(function() 
				disconnect()

				if dir ~= 1 then
					humanoid.WalkSpeed = killerModules["Speeds"]:GetSpeeds("Doctor")["Movement"]
					Obfuscate("string", killerAction, "Nothing")
				end

				switchTreatment(-dir)
			end)
		end)
	end

	switchTreatment(1)
else
	warn("YOU ARE AERO!")
	local mouseDownCon,animTrackStoppedCon
	
	local function disconnect()
		if animTrack then
			animTrack:Stop()
			animTrack = nil
		end
		
		--if mouseDownCon then
		--	mouseDownCon:Disconnect()
		--	mouseDownCon = nil
		--end
		
		if animTrackStoppedCon then
			animTrackStoppedCon:Disconnect()
			animTrackStoppedCon = nil
		end
		
		humanoid.WalkSpeed = killerModules["Speeds"]:GetSpeeds("Doctor")["Movement"]
		Obfuscate("string", killerAction, "Nothing")
	end
	
	mouseDownCon = mouse.Button2Down:Connect(function()
		if killerAction.Value ~= "Nothing" then
			return
		end
		
		Obfuscate("string", killerAction, "ChargingShock")
		
		humanoid.WalkSpeed = killerModules["Speeds"]:GetSpeeds("Doctor")["Movement"] / 2
		
		animTrack = humanoid:LoadAnimation(animations["Hold"])
		animTrack.Looped = false
		animTrack:AdjustSpeed(.1)
		animTrack:Play()
		
		animTrackStoppedCon = animTrack.Stopped:Connect(function()
			animTrack = humanoid:LoadAnimation(animations["Shock"])
			animTrack:AdjustSpeed(.1)
			animTrack:Play()
			
			animTrackStoppedCon = animTrack.Stopped:Connect(function()
				shockPowerAction:FireServer(rootPart)

				task.spawn(function()
					task.wait(2)
					disconnect()
				end)
			end)
		end)
	end)
end


]]