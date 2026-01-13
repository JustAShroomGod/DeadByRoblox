local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local teleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = game:GetService("Players").LocalPlayer

local remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local requestTestServer = remoteEvents:WaitForChild("RequestTestServer")
local Bloodweb = require(game.Players.LocalPlayer:WaitForChild('PlayerGui'):WaitForChild("Blood_Shop"):WaitForChild("Shop_Client"))

local MatchMakingText = script.Parent.Parent:WaitForChild("HUD"):WaitForChild("MatchMaking")


local Loadout_Module = require(script:WaitForChild('Loadout'))
local Customization_Module = require(script:WaitForChild('Customization'))
local Cosmetics_Module = require(script:WaitForChild("Cosmetics"))
local PlayerLoadouts_Module = require(script:WaitForChild("PlayerLoadouts"))

local Content = script.Parent:WaitForChild('Content')
local Navigation = script.Parent:WaitForChild('Navigation')
local Loadouts = Content:WaitForChild('Loadout'):WaitForChild("Loadouts_Frame"):WaitForChild("Loadouts")
Loadout_Module:Update() -- first screen

Cosmetics_Module.Create()

local screenGui = script.Parent
local JoinInProgress = false

local Side_Buttons = {
	Custom =  script.Parent:WaitForChild('Navigation'):WaitForChild('Tabs'):WaitForChild('Customization');
	Loadout = script.Parent:WaitForChild('Navigation'):WaitForChild('Tabs'):WaitForChild('Loadout');
	Bloodshop = script.Parent:WaitForChild('Navigation'):WaitForChild('Tabs'):WaitForChild('Bloodshop');
	Cosmetics = script.Parent:WaitForChild('Navigation'):WaitForChild('Tabs'):WaitForChild('Cosmetics');
}

Side_Buttons.Custom:WaitForChild('Button').MouseButton1Click:Connect(function()
	Customization_Module:Update()
	
	Content:WaitForChild('PlayerLoadouts').Visible = false
	Content:WaitForChild('Customization').Visible = true
	Content:WaitForChild('Loadout').Visible = false
	Content:WaitForChild('Cosmetics').Visible = false
	script.Parent.Parent:WaitForChild('Blood_Shop').Enabled = false
end)

Side_Buttons.Loadout:WaitForChild('Button').MouseButton1Click:Connect(function()
	Loadout_Module:Update()
	Content:WaitForChild('PlayerLoadouts').Visible = false
	Content:WaitForChild('Loadout').Visible = true
	Content:WaitForChild('Customization').Visible = false
	Content:WaitForChild('Cosmetics').Visible = false
	script.Parent.Parent:WaitForChild('Blood_Shop').Enabled = false
end)

Side_Buttons.Bloodshop:WaitForChild('Button').MouseButton1Click:Connect(function()
	script.Parent.Parent:WaitForChild('Blood_Shop').Enabled = true
	Content:WaitForChild('Customization').Visible = false
	Content:WaitForChild('PlayerLoadouts').Visible = false
	Content:WaitForChild('Loadout').Visible = false
	Content:WaitForChild('Cosmetics').Visible = false
	
	Bloodweb:Update('Survivor')
end)

Side_Buttons.Cosmetics:WaitForChild('Button').MouseButton1Click:Connect(function()
	script.Parent.Parent:WaitForChild('Blood_Shop').Enabled = false
	Content:WaitForChild('Cosmetics').Visible = true
	Content:WaitForChild('Customization').Visible = false
	Content:WaitForChild('PlayerLoadouts').Visible = false
	Content:WaitForChild('Loadout').Visible = false
end)

Loadouts:WaitForChild("Button").MouseButton1Click:Connect(function()

	PlayerLoadouts_Module:Connect()

	script.Parent.Parent:WaitForChild('Blood_Shop').Enabled = false
	Content:WaitForChild('Customization').Visible = false
	Content:WaitForChild('PlayerLoadouts').Visible = not Content:WaitForChild('PlayerLoadouts').Visible
	Content:WaitForChild('Cosmetics').Visible = false

	PlayerLoadouts_Module:RequestLoadouts()
end)


local function JoinPressed()
	if JoinInProgress then return end
	JoinInProgress = true
	
	local sound = Instance.new("Sound", game.Players.LocalPlayer.PlayerGui.Sounds)
	sound.SoundId = "rbxassetid://15088520844"
	sound.PlaybackSpeed = 1
	sound.Volume = 0.9
	sound.Name = "ReadySound"
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)

	teleportService:SetTeleportSetting("MatchmakingData", {"Survivor"})
	teleportService:SetTeleportSetting("GlobalGameContext", "in_game_survivor")
	
	requestTestServer:FireServer("Normal", "Survivor", 'Normal')

	script.Parent:WaitForChild("Start_Match"):WaitForChild("Normal").Visible = false
	script.Parent:WaitForChild("Start_Match"):WaitForChild("Cancel").Visible = true
	
	script.Parent.Parent:WaitForChild("Killer_Screen"):WaitForChild("Start_Match"):WaitForChild("Normal").Visible = false
	
	MatchMakingText.Visible = true
end

local function CancelPressed()
	if not JoinInProgress then return end
	JoinInProgress = false

	requestTestServer:FireServer("Remove")

	script.Parent:WaitForChild("Start_Match"):WaitForChild("Normal").Visible = true
	script.Parent:WaitForChild("Start_Match"):WaitForChild("Cancel").Visible = false
	
	script.Parent.Parent:WaitForChild("Killer_Screen"):WaitForChild("Start_Match"):WaitForChild("Normal").Visible = true
	
	MatchMakingText.Visible = false
end


local function ExitPressed()	
	script.Parent.Enabled = false
	script.Parent.Parent:WaitForChild('Blood_Shop').Enabled = false
	script.Parent.Parent:WaitForChild('ChooseBand').Enabled = true
	game.Players.LocalPlayer.Character.PrimaryPart.Anchored = false
end

local function SetTeam()
	if not script.Parent.Enabled then return end
	
	if not (LocalPlayer.Character:GetAttribute("Team") == "Survivor") then
		require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')):SetTeamAttribute("Survivor",LocalPlayer)
	end
end

script.Parent:WaitForChild('Back'):WaitForChild('Button').MouseButton1Click:Connect(ExitPressed)
script.Parent:WaitForChild('Start_Match'):WaitForChild('Normal'):WaitForChild('Button').MouseButton1Click:Connect(JoinPressed)
script.Parent:WaitForChild('Start_Match'):WaitForChild('Cancel'):WaitForChild('Button').MouseButton1Click:Connect(CancelPressed)

script.Parent.Changed:Connect(SetTeam)
