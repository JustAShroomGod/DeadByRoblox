local selector = script.Parent
local TweenService = game:GetService("TweenService")

-- Returns all frames from an object and its children
local function get_all_frames(object)
	local frames = {}
	if object.ClassName == "Frame" then
		table.insert(frames, object)
	end
	for _, child in pairs(object:GetChildren()) do
		for _, frame in pairs(get_all_frames(child)) do
			table.insert(frames, frame)
		end
	end
	return frames
end

-- Collect all the frames within selector.Upper and selector.Lower
local allFrames = {}
for _, frame in pairs(get_all_frames(selector.Upper)) do
	table.insert(allFrames, frame)
end
for _, frame in pairs(get_all_frames(selector.Lower)) do
	table.insert(allFrames, frame)
end

-- Tween function
local function create_hover_tween(layout_object, t)
	local tween = TweenService:Create(layout_object, TweenInfo.new(0.3), t)
	tween:Play()
end

-- Connect hover events to frames
for _, frame in pairs(allFrames) do
	local border = frame:FindFirstChild("Border")

	if border then
		local sizes = {}
		local sizes0 = {}
		local sizes1 = {}
		local pixels = 1
		for _, line in pairs(border:GetChildren()) do
			sizes[line] = UDim2.new(0,0,0,0) -- line.Size
			sizes0[line] = UDim2.new(1, 0, 0, pixels)
			sizes1[line] = UDim2.new(0, pixels, 1, 0)
		end

		frame.MouseEnter:Connect(function()
			create_hover_tween(frame, {BackgroundTransparency = 0})
			for _, line in pairs(border:GetChildren()) do
				if line.Name == "Bottom" or line.Name == "Top" then
					create_hover_tween(line, {Size = sizes0[line], BackgroundTransparency = 0})
				elseif line.Name == "Right" or line.Name == "Left" then
					create_hover_tween(line, {Size = sizes1[line], BackgroundTransparency = 0})
				end
			end
		end)

		frame.MouseLeave:Connect(function()
			create_hover_tween(frame, {BackgroundTransparency = 0.8})
			for _, line in pairs(border:GetChildren()) do
				if line.Name == "Bottom" or line.Name == "Top" then
					create_hover_tween(line, {Size = sizes[line], BackgroundTransparency = 1})
				elseif line.Name == "Right" or line.Name == "Left" then
					create_hover_tween(line, {Size = sizes[line], BackgroundTransparency = 1})
				end
			end
		end)
		local button = frame:FindFirstChild("Button")
		if button then
			button.MouseButton1Click:Connect(function()
				create_hover_tween(frame, {BackgroundTransparency = 0.8})
				frame.BackgroundTransparency = 1
				for _, line in pairs(border:GetChildren()) do
					create_hover_tween(line, {Size = sizes[line], BackgroundTransparency = 1})
				end
			end)
		end
	end
end
