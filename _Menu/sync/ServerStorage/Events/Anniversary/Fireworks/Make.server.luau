local TweenService : TweenService = game:GetService("TweenService")
local Spawners = script:FindFirstChild("Spawners")

while task.wait(math.random(3, 5)) do
	local amount = math.random(2, 7)
	local lenght = math.random(1, 3)
	for i = 1, amount do
		task.wait(.7)
		
		local cl = script.Firework:Clone()
		cl.Parent = script.Parent
		cl.Transparency = 0
		cl.Sparks.Enabled = true
		cl.Wind:Play()
		cl.Position =  Spawners:GetChildren()[math.random(1,#Spawners:GetChildren())].Position --Vector3.new(math.random(Xmin, Xmax), cl.Position.Y, math.random(Zmin, Zmax))

		local g = {Position = Vector3.new(cl.Position.X, cl.Position.Y + 35, cl.Position.Z)}
		TweenService:Create(cl, TweenInfo.new(lenght, Enum.EasingStyle.Linear), g):Play()

		task.delay(lenght, function()
			cl.Perform:Destroy()
			cl.Sparks:Destroy()

			for i, v in pairs(cl:GetChildren()) do
				if v.Name == "Blast" then
					v.Enabled = true
				end
			end

			cl.Transparency = 1
			game.Debris:AddItem(cl, 2)
		end)
	end
end