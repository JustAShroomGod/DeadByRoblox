-- Replicates Killer Head Tilt and Flashlight Angles --
local TweenService : TweenService, ReplicatedStorage : ReplicatedStorage = game:GetService('TweenService'), game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Flash_Remote = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Flashlight_Client')

local Code_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local IsKiller = game.Players.LocalPlayer:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('Killer')
local Bright = IsKiller.Parent:WaitForChild('BlindScript'):WaitForChild('Brightness')

local DefaultConeAngle = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(-70));

Flash_Remote.OnClientEvent:Connect(function(...)
	local args = {...}
	
	local Command = args[1]
	
	if Command == 'Flashlight_Angle' then
		local Flashlight, Angle, ConeSize = args[2], args[3], args[4]
		
		-- Adjust the cone size --
		local Cone, Weld = Flashlight:FindFirstChild('Cone'), Flashlight:FindFirstChild('Weld')
		
		if not Cone or not Weld then return end
		
		if IsKiller.Value and tonumber(Bright.Value) > 0 then -- we are a killer and are being blinded
			Cone:WaitForChild("Highlight").Enabled = false -- disable the highlight
		elseif IsKiller.Value and tonumber(Bright.Value) <= 0 then -- we are killer and not being blinded
			Cone:WaitForChild("Highlight").Enabled = true -- re-enable the highlight
		end
		
		local VALUE1 = Instance.new('Vector3Value')
		VALUE1.Value = Cone.Size
		
		VALUE1.Changed:Connect(function()
			Cone.Size = VALUE1.Value
			Cone.Pivot.C1 = CFrame.new(0, -VALUE1.Value.Y/2 + 1, 0)
		end)
		
		TweenService:Create(VALUE1, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {Value = ConeSize}):Play()
		TweenService:Create(Weld, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {C0 = (DefaultConeAngle * CFrame.Angles(0, 0, Angle))}):Play()
		
		task.wait(.5)
		
		VALUE1:Destroy()
	elseif Command == 'Flashlight_Reset' and args[2] then
		local Flashlight = args[2]
		local Weld = Flashlight:FindFirstChild('Weld')
		
		if not Weld then return end
		
		Weld.C0 = DefaultConeAngle * CFrame.Angles(0, 0, math.rad(70))
	end
end)

local Visual, Last_Bright = require(script:WaitForChild('Visual')), 0
local Brightness = game.Players.LocalPlayer:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('BlindScript'):WaitForChild('Brightness')

RunService.Heartbeat:Connect(function(delta)
	if not game.Players.LocalPlayer.Character or not game.Players.LocalPlayer.Character.Parent then
		return coroutine.yield()
	end
	
	if not IsKiller.Value then -->> survivor blind visuals << --
		local Is_Flashed = Code_Module:GetEffect("Flashed")
		
		if Is_Flashed and Is_Flashed.Active then
			Visual.Update(100)
			Last_Bright = workspace:GetServerTimeNow()
		else
			local Transparency = math.clamp(((workspace:GetServerTimeNow() - Last_Bright)/1.5) * 100, 0, 100)
			
			Visual.Update(100 - Transparency)
		end
	else -->> killer blind visuals << --
		Visual.Update(tonumber(Brightness.Value))
	end
end)