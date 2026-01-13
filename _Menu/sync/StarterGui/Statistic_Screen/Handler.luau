local ReplicatedStorage : ReplicatedStorage, Players : Players =  game:GetService("ReplicatedStorage"), game:GetService("Players")

local LocalPlayer : Player= Players.LocalPlayer
local PlayerGui : PlayerGui = LocalPlayer.PlayerGui

local Container = script.Parent
local Main_Frame = Container:WaitForChild("Main")
local Back_Frame = Container:WaitForChild("Back")

local Game_Data = ReplicatedStorage:WaitForChild("Game_Data")

local Prefab : Frame = Main_Frame:WaitForChild("Prefab"):WaitForChild("Template")

local module = {
	Connections = {
		Mouse1Click = nil;
		ContainerClose = nil;
	};
	CurrentPlayer = nil;
}



local function Destroy(Player)
	Container.Enabled = false
	Container.Parent:WaitForChild('ChooseBand').Enabled = true
	module.CurrentPlayer = nil
	
	for _,Connection in module.Connections do
		Connection:Disconnect()
		Connection = nil
	end
	
	for _,Prefabs in pairs(Main_Frame:WaitForChild("Killers"):GetChildren()) do
		if not Prefabs:IsA("Frame") then continue end
		Prefabs:Destroy()
	end
	
	for _,Prefabs in pairs(Main_Frame:WaitForChild("Survivor"):GetChildren()) do
		Prefabs:Destroy()
	end
end

local function Init(Player : Player)	
	local Data_Folder = Player:WaitForChild("Data")
	module.CurrentPlayer = Player
	
	--[[if Container.Enabled then
		Destroy()
		warn("exists")
	end]]
	
	Destroy()
	
	for _, Killer in pairs(Data_Folder:WaitForChild("Inventory"):WaitForChild("Characters"):GetChildren()) do
		if Killer.Value then
			local Module = require(Game_Data:WaitForChild("Killers"):WaitForChild(Killer.Name))

			if Module.Testing or not Module.Active then continue end

			local Killer_Prefab = Prefab:Clone()
			local Prefab_States = Killer_Prefab:WaitForChild("Stats")
			Killer_Prefab.Name = Killer.Name
			Killer_Prefab:WaitForChild("Name").Text = Killer.Name
			Prefab_States:WaitForChild("Accomplishment").Text = "KILLS: " .. tostring(Killer:GetAttribute("Kills"))
			Prefab_States:WaitForChild("Level").Text = "LEVEL: " .. tostring(Data_Folder:WaitForChild("Stats"):WaitForChild("Levels"):WaitForChild(Killer.Name).Value)
			Prefab_States:WaitForChild("Prestige").Text = "PRESTIGE: " .. tostring(Data_Folder:WaitForChild("Stats"):WaitForChild("Prestige"):WaitForChild(Killer.Name).Value)
			Prefab_States:WaitForChild("Rank").Text = "RANK: " .. tostring(Data_Folder:WaitForChild("Stats"):WaitForChild("Ranks"):WaitForChild(Killer.Name).Value)
			Killer_Prefab:WaitForChild("Image").Image = Module.Killer_Image
			Killer_Prefab.Parent = Main_Frame:WaitForChild("Killers")

			Killer_Prefab.Visible = true
		end
	end

	local Survivor_Prefab = Prefab:Clone()
	local Prefab_States = Survivor_Prefab:WaitForChild("Stats")
	Survivor_Prefab.Name = "RBX SURVIVOR"
	Survivor_Prefab:WaitForChild("Name").Text = "RBX SURVIVOR"
	Prefab_States:WaitForChild("Accomplishment").Text = "ESCAPES: " .. tostring(Player.Character:GetAttribute("Escapes"))
	Prefab_States:WaitForChild("Level").Text = "LEVEL: " .. tostring(Data_Folder:WaitForChild("Stats"):WaitForChild("Levels"):WaitForChild("Survivor").Value)
	Prefab_States:WaitForChild("Prestige").Text = "PRESTIGE: " .. tostring(Data_Folder:WaitForChild("Stats"):WaitForChild("Prestige"):WaitForChild("Survivor").Value)
	Prefab_States:WaitForChild("Rank").Text = "RANK: " .. tostring(Data_Folder:WaitForChild("Stats"):WaitForChild("Ranks"):WaitForChild("Survivor").Value)
	Survivor_Prefab:WaitForChild("Image").Image = "rbxassetid://15027127351"
	Survivor_Prefab.Parent = Main_Frame:WaitForChild("Survivor")

	Survivor_Prefab.Visible = true
	
	module.Connections.Mouse1Click = Back_Frame:WaitForChild('Button').MouseButton1Click:Once(function()
		module.Disconnect(Player)
	end)
	
	module.Connections.ContainerClose = Container.Changed:Connect(function()
		if not Container.Enabled then
			module.Disconnect(Player)
		end
	end)
	
	if not Container.Enabled then
		Container.Enabled = true
	end
end

function module.Connect(Player : Player)
	if not Player:FindFirstChild("Data") then return end
	if module.CurrentPlayer == Player then return end
	
	--coroutine.wrap(function() --band-aid fix ngl, will have to be like this until we rework buttons
	for _, Container in pairs(PlayerGui:GetChildren()) do
		if not (Container:IsA("ScreenGui")) then continue end
		if Container.Name == "HUD" or Container.Name == "Statistic_Screen" or Container.Name == "TouchGui" then continue end
		if string.match(Container.Name, "Related") then continue end

		Container.Enabled = false
	end
	
	Init(Player)
end

function module.Disconnect(Player)
	Destroy(Player)
end


return module
