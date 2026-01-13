local TweenService : TweenService = game:GetService("TweenService")

local UI_SETTINGS = game:GetService('ReplicatedStorage'):WaitForChild('UI_SETTINGS')
local Points_Images = UI_SETTINGS:WaitForChild("Points")

local Circle = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Circle_Dependency')) -- used to fill radials

local Module = {}

local ImageIds = { --TODO: need new images
	["Altruism"] = "rbxassetid://84128172315397";
	["Boldness"] = "rbxassetid://93617891072498";
	["Objectives"] = "rbxassetid://123778984343997";
	["Survival"] = "rbxassetid://125214886220351";
	["Brutality"] = "rbxassetid://97856126808497";
	["Deviousness"] = "rbxassetid://122748953527375";
	["Hunter"] = "rbxassetid://138012984512163";
	["Sacrifice"] = "rbxassetid://92768670931975";
}

local function TweenUI(Current_UI : Frame,FadeOrder)--since there is no frame.transparency we have to do it this way
	for _,Element in pairs(FadeOrder) do
		if Element:IsA("TextLabel") then
			TweenService:Create(Element,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
		else
			TweenService:Create(Element,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()
		end		
	end
	
	task.wait(2.5)
	
	for _,Element in pairs(FadeOrder) do
		if Element:IsA("TextLabel") then
			TweenService:Create(Element,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextTransparency = 1}):Play()
		else
			TweenService:Create(Element,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
		end
	end
	
	task.wait(1)
	
	Current_UI:Destroy()
end

function Module:Add(Frame ,...) : "Creates Score Points Ui"
	local args = {...}

	local Category : string, NewTotal : number, Increment : number, Action : string = args[1], args[2], args[3], args[4]

	local Percentage = (NewTotal/12000) * 100
	
	local Current_UI = Frame:WaitForChild("Prefab"):Clone()
	local FadeOrder = {Current_UI.Amount,Current_UI.FlavorText}
	
	Current_UI.Name = Category
	Current_UI.Parent = Frame
	Current_UI.FlavorText.Text = Action
	Current_UI.Amount.Text = if NewTotal == 12000 then "MAX" else "+" .. tostring(math.round(Increment))
	Current_UI.Image.Image = ImageIds[Category]
	Current_UI.Visible = true
	Current_UI.Parent = Frame

	Circle.new(Current_UI.Timer, Percentage)

	for _,Image in pairs(Current_UI:GetDescendants()) do
		if Image:IsA("ImageLabel") then
			table.insert(FadeOrder,Image)
		end
	end

	task.spawn(function()
		TweenUI(Current_UI,FadeOrder)
	end)
end

return Module
