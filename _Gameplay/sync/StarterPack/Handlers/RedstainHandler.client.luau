--!nocheck
--!nolint

local playerservice = game:GetService("Players")
local replicatedstorage = game:GetService("ReplicatedStorage")
local tweenservice = game:GetService("TweenService")
local runservice = game:GetService("RunService")
local Teams = game:GetService("Teams")

local folder = workspace:WaitForChild('Beams')

local max_range = 13.4
local amount = 20
local angle_range = 48

local Killer_Stains = {}
local RedStain_Lights = {}

local player = playerservice.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local scripts = backpack:WaitForChild("Scripts")
local killer_value = scripts:WaitForChild("Killer")

local event = runservice.Heartbeat
local code_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local IgnoreSurvivorsList = {}

local function lerp(a, b, x)
	return (a + ((b - a) * x))
end

local function GetIgnoredPlayers(currentkiller)
	for _,SurvivorPlayer in pairs(Teams.Survivor:GetPlayers()) do
		if SurvivorPlayer.Character then
			--[[for _,Part in ipairs(SurvivorPlayer.Character:GetDescendants()) do
				if Part:IsA("Part") or Part:IsA("MeshPart") then
					table.insert(IgnoreSurvivorsList, Part)
				end
			end]]
			
			table.insert(IgnoreSurvivorsList, SurvivorPlayer.Character)
		end
	end
end

function IsSilent(killer) : boolean | "Returns insidious value"
	if not killer then return end
	local Hidden = code_module:GetEffect("Hidden", killer)
	
	if Hidden then
		return true
	end
	
	return false
end

function CreateParts(Killer)
	Killer_Stains[Killer.Name] = {}
	RedStain_Lights[Killer.Name] = {}
	
	for i = 1, amount do
		local part = Instance.new("Part", folder) 
		part.Size = Vector3.new(1, 0.1, 0) 
		part.Anchored = true 
		part.CanCollide = false
		part.Color = Color3.fromRGB(80, 20, 20) 
		part.Transparency = 0.5
		part.Material = "Neon"
		part.Name = "RedstainPart"

		table.insert(Killer_Stains[Killer.Name], part)
	end
	
	RedStain_Lights[Killer.Name] = script:WaitForChild("RedStain_Light"):Clone()
	RedStain_Lights[Killer.Name].Parent = Killer.Character:WaitForChild("Head")
end

function Cycle_Killer(CURRENT_KILLER)
	local ocharacter = CURRENT_KILLER.Character

	if ocharacter then
		local ohumanoid = ocharacter:FindFirstChild("Humanoid")
		local orootpart = ocharacter:FindFirstChild("HumanoidRootPart")
		local olowertorso = ocharacter:FindFirstChild("LowerTorso")

		if ohumanoid and orootpart and olowertorso then
			local deactivated = false
			local weapon, power = nil, nil

			local children = ocharacter:GetChildren()
			
			if not Killer_Stains[CURRENT_KILLER.Name] then
				CreateParts(CURRENT_KILLER)
			end

			for _,model in pairs(children) do
				local IsWeapon = (model:GetAttribute('Type') == 'Weapon')

				if IsWeapon then
					weapon = model

					if power then
						break
					end
				end
			end

			if weapon then

				if weapon.Name == "Wraith" then
					if olowertorso.Transparency >= 0.85 then
						deactivated = true
					end
				elseif weapon.Name == "Stalker" then
					local variable = ocharacter:GetAttribute("Power_Tier")

					if variable then

						if variable == 1 then
							deactivated = true
						elseif variable > 1 then
							deactivated = false
						end
					end
				end

				if IsSilent(CURRENT_KILLER) then
					deactivated = true
				end
			end


			local BrightnessGoal = 200 -- default
			local tweengoal = {}
			tweengoal.Transparency = 0.7

			if deactivated == true then
				tweengoal.Transparency = 1
				BrightnessGoal = 0
			end

			if RedStain_Lights[CURRENT_KILLER.Name].Brightness ~= BrightnessGoal then
				RedStain_Lights[CURRENT_KILLER.Name].Brightness = lerp(RedStain_Lights[CURRENT_KILLER.Name].Brightness, BrightnessGoal, 1)
			end

			for n, part in pairs(Killer_Stains[CURRENT_KILLER.Name]) do
				if part.Transparency ~= tweengoal.Transparency then
					local tween = tweenservice:Create(part, TweenInfo.new(0.3), tweengoal) 
					tween:Play()
				end
			end

			if deactivated == false then
				local depth = -2
				local offset_z = CFrame.new(0, 0, depth)

				local root_cframe = orootpart.CFrame*offset_z

				local start_angle = -math.pi/2
				local angles = CFrame.Angles(start_angle, 0, 0)

				local this_cframe = orootpart.CFrame*angles

				local look_depth = 5
				local look_vector = this_cframe.LookVector
				local look_direction = look_vector*look_depth

				local offset_r = CFrame.new(0, 1.5, 0)
				local raycast_cframe = root_cframe*offset_r

				local raycast = Ray.new(raycast_cframe.p, look_direction)

				local ignore_table = {unpack(Killer_Stains[CURRENT_KILLER.Name])}
				table.insert(ignore_table, ocharacter)
				if #IgnoreSurvivorsList > 0 then
					for _,SurvivorCharacter in pairs(IgnoreSurvivorsList) do
						for _,Part in ipairs(SurvivorCharacter:GetChildren()) do
							if Part:IsA("Part") or Part:IsA("MeshPart") or Part:IsA("Accessory") then
								table.insert(ignore_table, Part)
							end
						end
					end
				end
				
				local _, position = workspace:FindPartOnRayWithIgnoreList(raycast, ignore_table, true, true)

				local height = position.Y-root_cframe.p.Y
				local offset_h = CFrame.new(0, height, 0)

				local root_cframe = root_cframe*offset_h
				local part_size = 11.5/amount

				for n, part in pairs(Killer_Stains[CURRENT_KILLER.Name]) do
					local half_range = angle_range/2 
					half_range = -half_range

					local per_angle = angle_range/amount
					local cur_angle = per_angle*n
					local newangle = math.rad(half_range+cur_angle)

					local angles = CFrame.Angles(0, newangle, 0)

					local base_cframe = root_cframe*angles
					local ray = Ray.new(base_cframe.p, (base_cframe.LookVector * max_range))

					local hit, position

					local function remove()
						local newhit, newpos = workspace:FindPartOnRayWithIgnoreList(ray, ignore_table, true, true)

						if hit == nil then
							hit, position = newhit, newpos
						elseif newhit.Transparency > 0.9 then
							table.insert(ignore_table, newhit)

							remove()
						else
							hit, position = newhit, newpos
						end
					end 	

					remove()

					local mag = (base_cframe.p - position).magnitude

					local distance = math.clamp(mag, 0.05, max_range)
					local goal = {} 
					goal.CFrame = base_cframe * CFrame.new(0,0,-distance/2)
					goal.Size = Vector3.new(part_size, part.Size.Y, distance)

					local tween = tweenservice:Create(part, TweenInfo.new(0.09), goal) 
					tween:Play()
				end
			end
		end
	end
end

event = event:Connect(function()
	
	if killer_value.Value then
		event:Disconnect()
		
		folder:Destroy()
		return
	end
	
	for _, Curr_Player in pairs(game.Teams:WaitForChild('Killer'):GetPlayers()) do
		Cycle_Killer(Curr_Player)
	end
end)

if not killer_value.Value then
	for _, Curr_Player in pairs(game.Teams:WaitForChild('Killer'):GetPlayers()) do
		GetIgnoredPlayers(Curr_Player)
	end
end