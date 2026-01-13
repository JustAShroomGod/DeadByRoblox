task.wait(3)

local remoteEvents = game.ReplicatedStorage:WaitForChild("-LockerAuras")
powerAction = remoteEvents:WaitForChild("HuntressPowerAction")

local runService = game:GetService("RunService")
local debugMode = false
local tweenService = game:GetService("TweenService") 

local plr = game.Players.LocalPlayer
local char = workspace:WaitForChild(plr.Name) 
local Backpack = plr:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")
local values = Scripts:WaitForChild("values") 
local killer = Scripts:WaitForChild("Killer")

local hatchet_model = script:WaitForChild("Handle")
local part = Instance.new("Part", hatchet_model)
part.Anchored = false
part.CanCollide = false
part.Size = hatchet_model.Size * Vector3.new(1.8,4.4,2.6)
part.CFrame = hatchet_model.CFrame
local weld = Instance.new("WeldConstraint", part)
weld.Part0 = hatchet_model
part.Transparency = 1
weld.Part1 = part

local function visibilityfix(Tool)
	-- Keep Hatchet Visible --
	local function KeepVisible(part : BasePart) : "Local Trransparency Modifier"
		part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
			part.LocalTransparencyModifier = 0
			part.Transparency = 0
		end)

		part:GetPropertyChangedSignal("Transparency"):Connect(function()
			part.LocalTransparencyModifier = 0
			part.Transparency = 0
		end)
		part.Transparency = 0
		part.LocalTransparencyModifier = 0
	end

	for _, object in pairs(Tool:GetChildren()) do
		if object:IsA('BasePart') then
			KeepVisible(object)
		end
	end
end

function ginstantiate_hatchet(charge, cf, my_tick)
	if charge and cf and my_tick then else return end
	local normal = CFrame.new(cf.start.p, cf.start_cam.p)
	local x, y, z = normal:ToOrientation()
	if x > 1.3 then
		x = 1.3
	end
	local xv,y,z = cf.start:ToOrientation()
	local deg = math.deg(x)

	normal = CFrame.new((cf.start*CFrame.new(0,1,0)).p)
		*CFrame.Angles(0, y, 0)

	local vel = charge/1.5*100
	local vel_x = math.cos(x)*vel*1.2
	local vel_y = math.sin(x)*vel*(x*1.3)

	if x < 0.01 then
		vel_x *= x+0.65
		vel_y *= (x+0.08)
	end

	if x > 1.05 then
		vel_x *= (x*-1+1.05)
	end

	local hatchet_copy = hatchet_model:Clone()
	hatchet_copy.Parent = workspace
	local r = hatchet_copy
	local run = runService.RenderStepped
	local hit = hatchet_copy.Touched
	local secondhit = hatchet_copy.Part.Touched
	hatchet_copy:WaitForChild("Trail").Enabled = true
	local stuff = hatchet_copy.Part
	stuff.Parent = workspace
	hatchet_copy.Parent = stuff

	task.spawn(function()
		visibilityfix(hatchet_copy)
		visibilityfix(hatchet_model)
	end)

	local prefix = "rbxassetid://"

	local function instantiate_sound(id, parent)
		local sound = Instance.new("Sound", parent)
		sound.Volume = 4
		sound.SoundId = prefix.. tostring(id)
		sound.RollOffMaxDistance = 300
		sound:Play()

		return sound
	end

	local spin = instantiate_sound(6648492524, hatchet_copy)
	spin.Looped = true
	stuff.CanTouch = true
	hatchet_copy.CanTouch = true
	hatchet_copy = stuff

	local function destroy()
		hit:Disconnect()
		run:Disconnect()
		secondhit:Disconnect()
		stuff:Destroy()
	end

	local function hit_function(part)
		if part.Transparency > 1/2 then print("invisible") return end 

		local killer_player = game.Players.LocalPlayer

		local hit_cf = hatchet_copy.CFrame

		local function check(child)
			if not child or not child.Parent then return nil end

			if not (child.Parent:FindFirstChild("LowerTorso") ~= nil) then return nil end

			local lower = child.Parent["LowerTorso"]

			if not (game.Players:FindFirstChild(lower.Parent.Name) ~= nil) then
				return nil
			end

			if game.Players[lower.Parent.Name].Team == game.Teams.Killer then return nil end

			return game:GetService("Players"):FindFirstChild(lower.Parent.Name) 
		end

		if not part:IsDescendantOf(killer_player.Character) then else print("HIT_SELF") return end

		--print("getting_player")
		local player = (check(part) or check(part.Parent) or check(part.Parent.Parent))
		--print(player)
		local id = nil

		if player then
			id = 1365520443
		else
			id = 6648740188
		end

		local part = Instance.new("Part", workspace)
		part.CFrame = hit_cf
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1

		destroy()

		local sound = instantiate_sound(id, part)
		sound.Volume = 7

		local ended = sound.Ended

		ended = ended:Connect(function()
			ended:Disconnect()

			part:Destroy()
		end)

		if not player then return end

		local success, response = pcall(function ()
			if player.Backpack.Scripts.values.HealthState.Value >= 1
				and player.Backpack.Scripts.values.Action.Value ~= "Hiding" then 
				game.ReplicatedStorage:WaitForChild("-LockerAuras"):WaitForChild("Hatchet_Event"):FireServer(player)
			end		
		end)

		if not success then
		end
	end
	local my_tick = workspace.DistributedGameTime
	if debugMode then
		run = runService.Heartbeat:Connect(function(delta)
			local time = (workspace.DistributedGameTime-my_tick)*delta

			if time > 15 then
				destroy()

				return
			end

			time *= 1.8

			local a = (vel/time)*delta
			local g = -10

			local x = (a*time^2)/2+vel_x*time
			local y = (g*time^2)/2+vel_y*time

			x *= 1
			y *= 1

			local rad = time%(2*math.pi)*10

			local cframe = normal*CFrame.new(0, y, -x)

			hatchet_copy.CFrame = cframe

			r.CFrame = cframe * 
				CFrame.Angles(-math.pi/2, 0, 0)
				*CFrame.Angles(0, -math.pi/2, 0)
				*CFrame.Angles(0, -rad, 0)
		end)
	else
		local b = false
		run = run:Connect(function()
			local time = workspace.DistributedGameTime-my_tick

			if time > 15 then
				destroy()

				return
			end

			time *= 1.8

			local a = vel/time
			local g = -10*(0.7+x)

			local x = (a*time^2)/2+vel_x*time
			local y = (g*time^2)/2+vel_y*time

			x *= 1
			y *= 1

			local rad = time%(2*math.pi)*10

			local cframe = normal*CFrame.new(0, y, -x)
				*CFrame.Angles(0, -math.pi/2, 0)
				*CFrame.Angles(-math.pi/2, 0, 0)
				*CFrame.Angles(0, -rad, 0)

			hatchet_copy.CFrame = cframe
			warn(hatchet_copy.CFrame, time)
		end)
	end

	secondhit = secondhit:Connect(function(part)
		hit_function(part)
	end)

	hit = hit:Connect(function(part)
		hit_function(part)
	end)
end

local mod = {}

mod.run = function(...)
	ginstantiate_hatchet(...)
end

return mod