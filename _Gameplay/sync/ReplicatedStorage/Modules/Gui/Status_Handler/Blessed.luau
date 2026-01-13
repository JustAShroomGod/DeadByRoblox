local Status_Progress = {}
local Circle = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Circle_Dependency')) -- used to fill radials
local code = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Frame_Name, lastUpdate = "Blessed", 0

function lerp(a, b, x)
	lastUpdate = workspace:GetServerTimeNow()
	return (a + ((b - a) * x))
end

function Status_Progress:Process(Frame, playerData, status_images) -- used to get percentage we are at or value
	local Player = game.Players.LocalPlayer
	local Current_UI = Frame:FindFirstChild(Frame_Name)
	local IsActive, Percentage = code:GetEffect("Blessed"), 100
	
	local Current_Screen_Effect = Frame.Parent:WaitForChild('Visual_Display'):FindFirstChild(Frame_Name)
	
	if IsActive and not code:isKiller(Player) then

		if not Current_UI then -- wasn't a ui to be found generate one
			Current_UI = Frame:WaitForChild('Prefabs'):WaitForChild('ExampleBasic'):Clone()
			Current_UI.Name = Frame_Name
			Current_UI.Parent = Frame

			local desired_template = status_images:FindFirstChild(Frame_Name)

			if desired_template then
				Current_UI.Image.Image = desired_template:GetAttribute("Image")
				
				if desired_template:GetAttribute("Color") then
					Current_UI.Timer.Frame1.ImageLabel.ImageColor3 = desired_template:GetAttribute("Color")
					Current_UI.Timer.Frame2.ImageLabel.ImageColor3 = desired_template:GetAttribute("Color")
				else
					Current_UI.Image.BackgroundTransparency = 1
				end
			else
				Current_UI.Image.BackgroundColor3 = Color3.fromRGB(191, 200, 195)
			end
		end
		
		Circle.new(Current_UI.Timer, Percentage)
		
		Current_Screen_Effect.Transparency = lerp(Current_Screen_Effect.Transparency, 0.6, 1 * (workspace:GetServerTimeNow() - lastUpdate))
		Current_Screen_Effect:WaitForChild('Inner_Shade').Transparency = Current_Screen_Effect.Transparency
		
		Current_UI.Visible = true
	else -- not active if there is ui / make invisible (performant)
		Current_Screen_Effect.Transparency = lerp(Current_Screen_Effect.Transparency, 1, 3 * (workspace:GetServerTimeNow() - lastUpdate))
		Current_Screen_Effect:WaitForChild('Inner_Shade').Transparency = Current_Screen_Effect.Transparency
		
		if Current_UI then
			Current_UI.Visible = false
		end
	end
end

return Status_Progress
