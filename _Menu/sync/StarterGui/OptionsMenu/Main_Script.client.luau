local Header = script.Parent:WaitForChild('Setting_Header')
local Frames = script.Parent:WaitForChild('Setting_Window')

local Tabs = {
	[Header:WaitForChild('Audio')] = Frames:WaitForChild('Audio');
	[Header:WaitForChild('Graphics')] = Frames:WaitForChild('Graphic');
	[Header:WaitForChild('General')] = Frames:WaitForChild('General');
	[Header:WaitForChild('Controls')] = Frames:WaitForChild('Control');
	[Header:WaitForChild('Accessibility')] = Frames:WaitForChild('Accessibility')
}


function OpenTab(Chosen_Tab : Frame) : "Opens Tab"
	
	for title, setting_frame in pairs(Tabs) do
		
		if title == Chosen_Tab then
			title.TextColor3 = Color3.new(223, 223, 223)
			setting_frame.Visible = true
		else
			title.TextColor3 = Color3.fromRGB(120, 120, 120)
			setting_frame.Visible = false
		end
	end
end


for tab, _ in pairs(Tabs) do
	
	tab.MouseButton1Click:Connect(function()
		OpenTab(tab)
	end)
end