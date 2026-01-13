runService = game:GetService("RunService")
tweenService = game:GetService("TweenService")
debris = game:GetService("Debris")

activated = script.Parent:WaitForChild("Activated")
energy = script.Parent:WaitForChild("Energy")

local Orientation = script.Parent.Orientation

increaseSpeed = 0.5

cWait = false
cWaitProgress = 0

local PlayerBlinder = game.Players[script.Parent.Blinder.Value]
local Character = PlayerBlinder.Character
local TeamsService = game:GetService("Teams")
local Tool = script.Parent.Parent
local Settings = {
	TweenTime = 0.88;
	Blinded = false; --acts like firecracker in dbd, theres a small window where you can blind killer and it is not throughout all firecrackers lifetime
}
local Progress : NumberValue = Tool:WaitForChild('UseProgress')

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

task.wait(1)
script.Parent["Firecrackers SOUND EFFECT"]:Play()
task.wait(1)

game:GetService("RunService").Heartbeat:Connect(function(delta)

	if activated.Value == true then

		if energy.Value > 0 then

			energy.Value = energy.Value - 25 * delta

		else

		end

		if cWait == false then

			cWait = true 

			for i = 1,5 do

				local beam = Instance.new("Part")
				beam.Parent = script.Parent
				beam.Name = "FireBeam"
				beam.Material = "Neon"
				beam.Color = Color3.fromRGB(255, 149, 1)
				local BeamRandom = math.random(1,15)
				if BeamRandom > 9 then
					beam.Color = Color3.fromRGB(255,25,0)
				end
				beam.Transparency = 0
				beam.CanCollide = false
				beam.Anchored = true
				--beam.Size = Vector3.new(0.08,0.1,0.08)
				beam.Size = Vector3.new(0.2,0.15,0.3)

				local xAngle = math.random(0,120)
				local yAngle = math.random(0,120)
				local zAngle = math.random(0,120)

				beam.CFrame = script.Parent.CFrame * CFrame.Angles(math.rad(xAngle),math.rad(yAngle),math.rad(zAngle))

				local goal = {}
				goal.Size = Vector3.new(0.25,9,0.4)
				goal.Transparency = 1

				local tweenTime = 0.88

				local tween = tweenService:Create(beam,TweenInfo.new(tweenTime),goal)
				tween:Play()

				debris:AddItem(beam,tweenTime)

			end


			KillerBlind()


		else

			local incSpeed = 700

			if cWaitProgress < 200 then

				cWaitProgress = cWaitProgress + incSpeed

			else

				cWait = false
				cWaitProgress = 0	

			end	

			KillerBlind()

		end	


	end

end)

task.wait(3)

script.Parent.Parent:Destroy()