local text_box = script.Parent
local info_frame = script.Parent:WaitForChild("Main")

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = {
	Data = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
}

text_box.FocusLost:Connect(function(enter)
	if not enter then return end
	local text = text_box.Text
	local result = Modules.Data:UseCode(text)
	
	if result == "Accepted" then
		text_box.Text = "CODE REDEEMED!"
		text_box.TextColor3 = Color3.fromRGB(0, 255, 8)
	elseif result == "Used" then
		text_box.Text = "CODE USED!"
		text_box.TextColor3 = Color3.fromRGB(255, 0, 0)
	elseif result == "Invalid" then
		text_box.Text = "INVALID CODE!"
		text_box.TextColor3 = Color3.fromRGB(255, 0, 4)
	end

	task.wait(1)
	
	text_box.Text = ""
	text_box.TextColor3 = Color3.fromRGB(255, 255, 255)
end)


local function hover()
	info_frame.Visible = true
end

local function unhover()
	info_frame.Visible = false
end


text_box.MouseEnter:Connect(hover)
text_box.MouseLeave:Connect(unhover)