local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rank_Update = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Rank_Update")

local Rank_Module = require(ReplicatedStorage:WaitForChild("Game_Data"):WaitForChild("Ranks"):WaitForChild("Global"))
local Data = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local Container = script.Parent
local Survivor_Container = Container:WaitForChild("Survivor")
local Killer_Container = Container:WaitForChild("Killer")


local module = {}

function module.Open(Side)
	Container:FindFirstChild(Side).Visible = true
	Container.Parent.Enabled = true
	
	Container.Parent:WaitForChild("Continue"):WaitForChild("Button").MouseButton1Click:Once(function()
		Container.Parent.Enabled = false
		Container:FindFirstChild(Side).Visible = false
		Data:SetTutorial(Side)
		
		Container.Parent.Parent:WaitForChild(Side .. "_Screen").Enabled = true
	end)
end

return module
