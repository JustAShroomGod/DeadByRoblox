local Handler = {}

function Remove(object)
	local tween = game:GetService('TweenService'):Create(object, TweenInfo.new(3), {Transparency = 1})

	tween:Play()

	tween.Completed:Once(function()
		object:Remove()
	end)
end

function Handler:Splatter(origin, Settings)
	local particle = script.Parent.Parent:WaitForChild('Particles'):WaitForChild('Splatter'):Clone()
	local connection = nil
	particle.Parent = workspace

	if not Settings then
		Settings = {}
	end

	if not Settings.Min then
		Settings.Min = 5
		Settings.Max = 15
	end


	particle.Position = origin:GetPivot().Position
	particle.AssemblyLinearVelocity = Vector3.new(math.random(-Settings.Max, Settings.Max), math.random(Settings.Min, Settings.Max) + 30, math.random(-Settings.Max, Settings.Max))

	task.wait(.5) -- wait a bit

	local function Touched(hit)
		if Settings.Ignore then

			if hit:IsDescendantOf(Settings.Ignore) then
				return -- do nothing
			end
		end

		if hit.Anchored then
			particle.Anchored = true

			connection:Disconnect()

			Remove(particle)

			local splatter = Instance.new("Part", workspace)
			splatter.Anchored = true
			splatter.Shape = Enum.PartType.Cylinder
			splatter.CanCollide = false
			splatter.CastShadow = false
			splatter.CanQuery = false
			splatter.Size = Vector3.new(0.5, 5, 5)
			splatter.Color = Color3.fromRGB(76, 0, 1)
			splatter.CFrame = CFrame.new(particle.Position) * CFrame.Angles(0, 0, math.rad(90))
			Remove(splatter)
		end
	end

	connection = game["Run Service"].Heartbeat:Connect(function()
		local Touching = workspace:GetPartsInPart(particle)

		if #Touching >= 1 then

			for _, Hit in pairs(Touching) do
				Touched(Hit)
			end
		end
	end)
end

return Handler
