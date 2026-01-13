local spotlight = script.Parent

while true do
	spotlight.Enabled = true
	task.wait(math.random(1, 3))

	spotlight.Enabled = false
	task.wait(math.random(5, 10) / 3) 
end