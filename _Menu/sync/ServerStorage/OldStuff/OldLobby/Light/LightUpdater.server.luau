tweenService = game:GetService("TweenService")

p1 = script.Parent:WaitForChild("PointLight")

task.spawn(function()
	while task.wait(0.3) do 

		local goal1 = {} goal1.Range = math.random(40,100)/5

		local tween1 = tweenService:Create(p1,TweenInfo.new(0.3),goal1)
		tween1:Play()

		task.wait (0.1)

		local goal1 = {} goal1.Range = math.random(20,75)/5

		local tween1 = tweenService:Create(p1,TweenInfo.new(0.3),goal1)
		tween1:Play()
	end
end)

task.spawn(function()
	while task.wait(0.3) do 

		local goal1 = {} goal1.Brightness = math.random(70,200)/10

		local tween1 = tweenService:Create(p1,TweenInfo.new(0.3),goal1)
		tween1:Play()

		task.wait(0.1)

		local goal1 = {} goal1.Brightness = math.random(90,120)/10

		local tween1 = tweenService:Create(p1,TweenInfo.new(0.3),goal1)
		tween1:Play()

		task.wait (0.1)

		local goal1 = {} goal1.Brightness = 15

		local tween1 = tweenService:Create(p1,TweenInfo.new(0.3),goal1)
		tween1:Play()
	end
end)
