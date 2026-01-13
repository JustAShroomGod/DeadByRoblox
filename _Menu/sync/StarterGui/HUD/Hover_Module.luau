local UserInputService, RunService, Players = game:GetService('UserInputService'), game:GetService('RunService'), game:GetService("Players")

local Mouse = Players.LocalPlayer:GetMouse()

local UI = script.Parent:WaitForChild('Hover')
local Handler = {
	Connections = {}
}

local function isInParent(Spesific ) --checks if in view
	if not Spesific then
		return UI.AbsolutePosition.X >= UI.Parent.AbsolutePosition.X and UI.AbsolutePosition.X + UI.AbsoluteSize.X <= UI.Parent.AbsolutePosition.X + UI.Parent.AbsoluteSize.X 
		and UI.AbsolutePosition.Y >= UI.Parent.AbsolutePosition.Y and UI.AbsolutePosition.Y + UI.AbsoluteSize.Y <= UI.Parent.AbsolutePosition.Y + UI.Parent.AbsoluteSize.Y
	else
		
	end
end

local function HoverPosition()
	local Pos = UserInputService:GetMouseLocation()
	local ApsSize_Parent = UI.Parent.AbsoluteSize
	local ApsSize_UI = UI.AbsoluteSize

	local New_PosX = Pos.X + 10
	local New_PosY = Pos.Y + 7
	
	if New_PosX + ApsSize_UI.X > ApsSize_Parent.X then
		New_PosX = ApsSize_Parent.X - ApsSize_UI.X - 20
	end

	if New_PosY + ApsSize_UI.Y > ApsSize_Parent.Y then
		New_PosY = ApsSize_Parent.Y - ApsSize_UI.Y
	end

	-- Update tooltip position
	UI.Position = UDim2.fromOffset(New_PosX, New_PosY)
end

function Handler:Display(Catagory : "Perk" | "Addon" | "Offering" | "Power" | "Item", Module, ...)
	local Args = {...}

	if Catagory == "Item" or Catagory == "Items" then
		UI.Size = UDim2.new(0.4, 0, 0.2, 0) -- size down
		UI:WaitForChild("TitleBackground"):WaitForChild('Title').Text = Module.Name
		UI:WaitForChild('Description').Text = Module.Description
		UI:WaitForChild("TitleBackground"):WaitForChild("UIGradient").Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1,Module.Color)})
		UI:WaitForChild("ProgressBar").Visible = false
	elseif Catagory == "Perk" or Catagory == "Perks" then
		UI.Size = UDim2.new(0.4, 0, 0.2, 0) -- size down
		UI:WaitForChild("TitleBackground"):WaitForChild('Title').Text = Module.Name
		UI:WaitForChild('Description').Text = Module.Description
		UI:WaitForChild("TitleBackground"):WaitForChild("UIGradient").Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1,Module.Colors[Args[1]])})
		UI:WaitForChild("ProgressBar").Visible = false
	elseif Catagory == "Offering" or Catagory == "Offerings" then
		UI.Size = UDim2.new(0.4, 0, 0.2, 0) -- size down
		UI:WaitForChild("TitleBackground"):WaitForChild('Title').Text = Module.Name
		UI:WaitForChild('Description').Text = Module.Description
		UI:WaitForChild("TitleBackground"):WaitForChild("UIGradient").Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1,Module.Color)})
		UI:WaitForChild("ProgressBar").Visible = false
	elseif Catagory == "Addon" or Catagory == "Addons" then
		UI.Size = UDim2.new(0.4, 0, 0.2, 0) -- size down
		UI:WaitForChild("TitleBackground"):WaitForChild('Title').Text = Module.Name
		UI:WaitForChild('Description').Text = Module.Description
		UI:WaitForChild("TitleBackground"):WaitForChild("UIGradient").Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1,Module.Color)})
		UI:WaitForChild("ProgressBar").Visible = false
	elseif Catagory == "Killer" or Catagory == "Power" then
		UI.Size = UDim2.new(0.5, 0, 0.5, 0) -- size up
		UI:WaitForChild("TitleBackground"):WaitForChild('Title').Text = if Catagory == "Killer" then Module.Killer_Name else Module.Power_Name
		UI:WaitForChild('Description').Text = Module.Description
		UI:WaitForChild("TitleBackground"):WaitForChild("UIGradient").Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1,Module.Power_Color)})
		UI:WaitForChild("ProgressBar").Visible = false
	elseif Catagory == "Rank" then
		UI.Size = UDim2.new(0.2, 0, 0.15, 0) -- size up
		UI:WaitForChild("TitleBackground"):WaitForChild('Title').Text = tostring(string.upper(Args[1]) .. " RANK")
		UI:WaitForChild('Description').Text = if Args[1] == "Killer" then Module.Configure(Args[2]).DescriptionKiller else Module.Configure(Args[2]).DescriptionSurvivor
		UI:WaitForChild("TitleBackground"):WaitForChild("UIGradient").Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1,Module.Colors[Args[2]])})
		
		UI:WaitForChild("ProgressBar"):WaitForChild("Bar").Size = UDim2.fromScale(Args[3]/100 ,1)
		UI:WaitForChild("ProgressBar"):WaitForChild("Description").Text = "RANK PROGRESS: " .. Args[3] .. "/100" 
		UI:WaitForChild("ProgressBar").Visible = true
	else
		warn(Catagory, Module, 'Unsupported!')
	end
	
	HoverPosition()
	UI.Visible = true
end

function Handler:Hide()
	UI.Visible = false
end

function Handler.boot()
	
	--[[if not Handler.Connections.Run then
		
		Handler.Connections.Run = Mouse.Move:Connect(function()
			local Pos = UserInputService:GetMouseLocation()

			local New_PosX = Pos.X + 10
			local New_PosY = Pos.y + 7
			
			if isInParent() then
				UI.Position = UDim2.new(0, New_PosX, 0, New_PosY)
				warn("NORMAL!")
			else
				if newX + tooltipSize.X > screenSize.X then
					newX = screenSize.X - tooltipSize.X
				end

				-- Check if the tooltip goes off the bottom edge
				if newY + tooltipSize.Y > screenSize.Y then
					newY = screenSize.Y - tooltipSize.Y
				end
	
				UI.Position = UDim2.new(0, Pos.X - 500, 0, Pos.Y + 7)
				warn("NOT NORMAL")
			end
		end)
		
		Handler.Connections.Run = RunService.Heartbeat:Connect(function()
			local Pos = UserInputService:GetMouseLocation()
			local DefaultOffset = UDim2.new(0, Pos.X + 15, 0, Pos.Y + 7)
			
			
			if isInParent() then
				UI.Position = DefaultOffset	
			else
				UI.Position = UDim2.new(0, Pos.X - 100, 0, Pos.Y + 7)
			end
		end)
	end]]
	
	return Handler
end

return Handler.boot()