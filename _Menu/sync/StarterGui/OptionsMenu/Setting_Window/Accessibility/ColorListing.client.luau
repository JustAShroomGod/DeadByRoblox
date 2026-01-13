local Data = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))

local ColorPrefab = script.ColorPrefab
local MainFrame = script.Parent.Selection

local TeamButton = MainFrame.Team
local ScrollFrame = MainFrame.ScrollingFrame

local Customizaton = MainFrame.Parent.Customization
local ColorCustomization = require(Customizaton.ColorCustomization)

local Colors = {}
local Prefabs = {}

local Settings = nil
local Team = "Survivor"

function GrabColors()
	
	repeat task.wait()
	until game.Players.LocalPlayer:FindFirstChild("Data") ~= nil
	
	if (Settings == nil) then
		Settings = Data:GetSettings()
	end

	Colors = Settings.COLORS
	
	CreateSettings()
end

function CreateSettings()
	
	local order = 1
	
	Prefabs["Killer"] = {}
	Prefabs["Survivor"] = {}
	
	for category, color in pairs(Colors.Survivor) do
		
		local newColorPrefab = ColorPrefab:Clone()
		newColorPrefab.Name = category
		newColorPrefab.Parent = ScrollFrame
		newColorPrefab.LayoutOrder = order
		
		newColorPrefab.Title.Text = `{category}`
		newColorPrefab.FillColor.BackgroundColor3 = Color3.fromRGB(color.Fill[1], color.Fill[2], color.Fill[3])
		newColorPrefab.OutlineColor.BackgroundColor3 = Color3.fromRGB(color.Outline[1], color.Outline[2], color.Outline[3])
		
		table.insert(Prefabs["Survivor"], newColorPrefab)
		order += 1
	end
	
	order = 1
	
	for category, color in pairs(Colors.Killer) do

		local newColorPrefab = ColorPrefab:Clone()
		newColorPrefab.Name = category
		newColorPrefab.Parent = ScrollFrame
		newColorPrefab.LayoutOrder = order

		newColorPrefab.Title.Text = `{category}`
		newColorPrefab.FillColor.BackgroundColor3 = Color3.fromRGB(color.Fill[1], color.Fill[2], color.Fill[3])
		newColorPrefab.OutlineColor.BackgroundColor3 = Color3.fromRGB(color.Outline[1], color.Outline[2], color.Outline[3])

		table.insert(Prefabs["Killer"], newColorPrefab)
		order += 1
	end
	
	SwapTeam()
	HookButtons()
	
	TeamButton.MouseButton1Click:Connect(SwapTeam)
	Customizaton.Reset.MouseButton1Click:Connect(Reset)
	Customizaton.Save.MouseButton1Click:Connect(Save)
end

function HookButtons()
	
	local sides = {"Survivor", "Killer"}
	
	for count = 1, #sides do
		for _, prefab in pairs(Prefabs[sides[count]]) do
			
			prefab.OutlineColor.MouseButton1Click:Connect(function()
				ToggleSelection(false)
				ColorCustomization.SetCustomize(prefab, sides[count], "Outline", Colors[sides[count]][prefab.Name]["Outline"])
			end)
			
			prefab.FillColor.MouseButton1Click:Connect(function()
				ToggleSelection(false)
				ColorCustomization.SetCustomize(prefab, sides[count], "Fill", Colors[sides[count]][prefab.Name]["Fill"])
			end)
		end
	end

	ToggleSelection(true)
	
end

function ToggleSelection(statement: boolean)
	
	for i, v in pairs(MainFrame:GetChildren()) do
		if (v:IsA("ModuleScript") or v:IsA("LocalScript")) then
			continue
		end
		
		v.Visible = statement
	end
	
	for i, v in pairs(Customizaton:GetChildren()) do
		if (v:IsA("ModuleScript") or v:IsA("LocalScript")) then
			continue
		end
		
		v.Visible = not statement
	end
	
end

function Save()
	ToggleSelection(true)
	ColorCustomization.SaveCustomization()
end

function Reset()
	ToggleSelection(true)
	ColorCustomization.ResetCustomization()
end

function SwapTeam()
	
	Team = if (Team == "Killer") then "Survivor" else "Killer"
	
	for i, v in pairs(Prefabs["Survivor"]) do
		v.Visible = false
	end
	
	for i, v in pairs(Prefabs["Killer"]) do
		v.Visible = false
	end
	
	for i, v in pairs(Prefabs[Team]) do
		v.Visible = true
	end
	
	TeamButton.TextLabel.Text = Team
end

GrabColors()

