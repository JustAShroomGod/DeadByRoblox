local RunService : RunService,Players : Players,ReplicatedStorage : ReplicatedStorage,TweenService : TweenService ,Debris : Debris,TeamsService : Teams,Loop = game:GetService("RunService"),game:GetService("Players"),game:GetService("ReplicatedStorage"),game:GetService("TweenService"),game:GetService("Debris"),game:GetService("Teams") ,nil

local Tool : Model = script.Parent
local Handle : UnionOperation = Tool:FindFirstChild("Handle")

local FirecrackerSettings = Tool:GetAttributes()

local Character : Model = workspace:FindFirstChild(FirecrackerSettings.Owner)

local Progress : NumberValue = Tool:WaitForChild('UseProgress')

local Settings = {
	TweenTime = 0.88;
	Blinded = false; --acts like firecracker in dbd, theres a small window where you can blind killer and it is not throughout all firecrackers lifetime
}


local function Effects()
	for i = 1,2 do
		local beam = Instance.new("Part")
		beam.Parent = script.Parent
		beam.Name = "FireBeam"
		beam.Material = "Neon"
		beam.Color = Color3.fromRGB(255, 149, 1)
		beam.Transparency = 0
		beam.CanCollide = false
		beam.CanQuery = false
		beam.CanTouch = false
		beam.CastShadow = false
		beam.Anchored = true
		beam.Size = Vector3.new(0.2,0.15,0.3)

		local xAngle = math.random(0,120)
		local yAngle = math.random(0,120)
		local zAngle = math.random(0,120)

		beam.CFrame = Handle.CFrame * CFrame.Angles(math.rad(xAngle),math.rad(yAngle),math.rad(zAngle))

		local goal = {}
		goal.Size = Vector3.new(0.25,9,0.4)
		goal.Transparency = 1

		local tween = TweenService:Create(beam,TweenInfo.new(Settings.TweenTime),goal)
		tween:Play()

		Debris:AddItem(beam,Settings.TweenTime)
	end
end

local function KillerBlind()
	local RawKiller = nil

	for _,Team_Member in pairs(TeamsService:WaitForChild('Killer'):GetPlayers()) do --this way of doing it allows JUST FOR 1 killer to be blinded!
		if not Team_Member then continue end

		if not RawKiller then
			RawKiller = Team_Member
		else
			if (RawKiller.Character:GetPivot().Position - Character:GetPivot().Position).Magnitude > (Team_Member.Character:GetPivot().Position - Character:GetPivot().Position).Magnitude then
				RawKiller = Team_Member
			end
		end
	end

	if not RawKiller or not RawKiller.Character then 
		return
	end

	Settings.Blinded = true

	local Distance = RawKiller.Character:GetPivot().Position - Character:GetPivot().Position

	local angle = math.acos(RawKiller.Character.PrimaryPart.CFrame.LookVector:Dot((Distance).Unit))
	local isBehind = angle < (math.pi / 1.5)

	if not isBehind and Distance.Magnitude <= 12 then -- will fire if the object (firecracker) is infront of killer
		local BlindFile = RawKiller.Backpack.Scripts.BlindScript

		-- Create Flash --
		local Flashing = Instance.new("StringValue")
		Flashing.Name = Character.Name
		Flashing.Value = tostring(10)
		Flashing.Parent = BlindFile.Flashing

		task.delay(0.2,function()
			if Flashing then
				Flashing:Destroy()
			end
		end)
	end
end

local function Bind(deltatime, step)
	local subAmount = 100/(FirecrackerSettings.Energy/FirecrackerSettings.Drain_Rate) -- produces incremtal number by seconds
	subAmount *= step -- multiplies by time passed

	Progress.Value = math.clamp(Progress.Value - subAmount, 0, 100)

	if Progress.Value <= 0 then
		if Loop then
			Loop:Disconnect()
			Loop = nil
		end

		Tool:Destroy()
	end

	Effects()

	if not Settings.Blinded then
		KillerBlind()
	end	
end

Tool.Parent.Changed:Connect(function()
	if Tool.Parent == workspace then
		Tool:SetAttribute("Grabbed", true)
		script.Parent.UseProgress.Value = 1
		script.Parent.Handle.Blinder.Value = Character.Name
		script.Parent.Handle.TriggerScript.Enabled = true
		script.Parent.Handle.Activated.Value = true
		script.Parent.Used.Changed:Connect(function()
			script.Parent.Used.Value = true
		end)
		script.Parent.Used.Value = true
	end
end)
