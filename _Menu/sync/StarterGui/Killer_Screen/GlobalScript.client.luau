local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local teleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = game:GetService("Players").LocalPlayer

local remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local requestTestServer = remoteEvents:WaitForChild("RequestTestServer")
local Bloodweb = require(game.Players.LocalPlayer:WaitForChild('PlayerGui'):WaitForChild("Blood_Shop"):WaitForChild("Shop_Client"))

local screenGui = script.Parent
local JoinInProgress = false

local Character_Module = require(script:WaitForChild('Characters'))
local Loadout_Module = require(script:WaitForChild('Loadout'))
local Customization_Module = require(script:WaitForChild('Customization'))
local Cosmetics_Module = require(script:WaitForChild("Cosmetics"))
local PlayerLoadouts_Module = require(script:WaitForChild("PlayerLoadouts"))

local Content = script.Parent:WaitForChild('Content')
local Navigation = script.Parent:WaitForChild('Navigation')
local Loadouts = Content:WaitForChild('Loadout'):WaitForChild("Loadouts_Frame"):WaitForChild("Loadouts")

Character_Module:Update() -- first time update for free

local Side_Buttons = {
	Character = script.Parent:WaitForChild('Navigation'):WaitForChild('Tabs'):WaitForChild('Character');
	Custom =  script.Parent:WaitForChild('Navigation'):WaitForChild('Tabs'):WaitForChild('Customization');
	Loadout = script.Parent:WaitForChild('Navigation'):WaitForChild('Tabs'):WaitForChild('Loadout');
	Bloodshop = script.Parent:WaitForChild('Navigation'):WaitForChild('Tabs'):WaitForChild('Bloodshop');
	Cosmetics = script.Parent:WaitForChild('Navigation'):WaitForChild('Tabs'):WaitForChild('Cosmetics');
}

local Loading_Cosmetics = false

Side_Buttons.Custom:WaitForChild('Button').MouseButton1Click:Connect(function()
	Customization_Module:Update()
	Content:WaitForChild('Customization').Visible = true
	Content:WaitForChild('Characters').Visible = false
	Content:WaitForChild('Loadout').Visible = false
	Content:WaitForChild('Cosmetics').Visible = false

	script.Parent.Parent:WaitForChild('Blood_Shop').Enabled = false
end)

Side_Buttons.Character:WaitForChild('Button').MouseButton1Click:Connect(function()
	Character_Module:Update()
	Content:WaitForChild('Characters').Visible = true
	Content:WaitForChild('Loadout').Visible = false
	Content:WaitForChild('Customization').Visible = false
	Content:WaitForChild('Cosmetics').Visible = false
	Content:WaitForChild('PlayerLoadouts').Visible = false

	script.Parent.Parent:WaitForChild('Blood_Shop').Enabled = false
end)

Side_Buttons.Loadout:WaitForChild('Button').MouseButton1Click:Connect(function()
	Loadout_Module:Update()
	Content:WaitForChild('Loadout').Visible = true
	Content:WaitForChild('Characters').Visible = false
	Content:WaitForChild('Customization').Visible = false
	Content:WaitForChild('Cosmetics').Visible = false
	script.Parent.Parent:WaitForChild('Blood_Shop').Enabled = false
end)

Side_Buttons.Cosmetics:WaitForChild('Button').MouseButton1Click:Connect(function()
	if not script.Parent:WaitForChild('Content'):WaitForChild('Cosmetics').Visible and Loading_Cosmetics == false then
		Loading_Cosmetics = true
		Cosmetics_Module.Create()
		Loading_Cosmetics = false
	end
	
	script.Parent.Parent:WaitForChild('Blood_Shop').Enabled = false
	Content:WaitForChild('Loadout').Visible = false
	Content:WaitForChild('Characters').Visible = false
	Content:WaitForChild('Customization').Visible = false
	Content:WaitForChild('PlayerLoadouts').Visible = false
	Content:WaitForChild('Cosmetics').Visible = true
end)

Side_Buttons.Bloodshop:WaitForChild('Button').MouseButton1Click:Connect(function()
	if JoinInProgress then return end
	
	--script.Parent.Enabled = false
	script.Parent.Parent:WaitForChild('Blood_Shop').Enabled = true
	Content:WaitForChild('Characters').Visible = false
	Content:WaitForChild('Loadout').Visible = false
	Content:WaitForChild('Customization').Visible = false
	Content:WaitForChild('PlayerLoadouts').Visible = false
	Content:WaitForChild('Cosmetics').Visible = false
	
	Bloodweb:Update('Killer')
end)

Loadouts:WaitForChild("Button").MouseButton1Click:Connect(function()
	
	PlayerLoadouts_Module:Connect()
	
	script.Parent.Parent:WaitForChild('Blood_Shop').Enabled = false
	Content:WaitForChild('Characters').Visible = false
	Content:WaitForChild('Customization').Visible = false
	Content:WaitForChild('PlayerLoadouts').Visible = not Content:WaitForChild('PlayerLoadouts').Visible
	Content:WaitForChild('Cosmetics').Visible = false
	
	PlayerLoadouts_Module:RequestLoadouts()
end)

-----

function ProJoinPressed()
	if JoinInProgress then return end
	JoinInProgress = true

	local sound = Instance.new("Sound", game.Players.LocalPlayer.PlayerGui.Sounds)
	sound.SoundId = "rbxassetid://" .. tostring(15088520844)
	sound.PlaybackSpeed = 1
	sound.Volume = 0.9
	sound.Name = "ReadySound"
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)

	teleportService:SetTeleportSetting("MatchmakingData", {"Killer"})
	teleportService:SetTeleportSetting("GlobalGameContext", "in_game_killer")

	requestTestServer:FireServer("Normal", "Killer", "Pro")

	script.Parent.Enabled = false
	script.Parent.Parent:WaitForChild('Blood_Shop').Enabled = false
	script.Parent:WaitForChild("Start_Match"):WaitForChild("MatchMaking").Visible = true
	
	--[[script.Parent:WaitForChild('Start_Match'):WaitForChild('Normal').Visible = false
	script.Parent:WaitForChild('Start_Match'):WaitForChild('Pro').Visible = false
	script.Parent:WaitForChild('Back').Visible = false]]--
end

function JoinPressed()
	if JoinInProgress then return end
	JoinInProgress = true
	
	local sound = Instance.new("Sound", game.Players.LocalPlayer.PlayerGui.Sounds)
	sound.SoundId = "rbxassetid://" .. tostring(15088520844)
	sound.PlaybackSpeed = 1
	sound.Volume = 0.9
	sound.Name = "ReadySound"
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)

	--frame.Visible = false
	--screenGui.BottomNavegator.KillerStatus.Visible = true

	--local hi = TweenService:Create(screenGui.BottomNavegator.KillerStatus, TweenInfo.new(17/10, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true, 1/2), {TextTransparency = 1}):Play()
	--screenGui.BottomNavegator.Back.Visible = false

	teleportService:SetTeleportSetting("MatchmakingData", {"Killer"})
	teleportService:SetTeleportSetting("GlobalGameContext", "in_game_killer")
	
	requestTestServer:FireServer("Normal", "Killer", "Normal")
	
	--task.wait(5)
	
	-- give pressed feed back --
	script.Parent.Enabled = false
	script.Parent.Parent:WaitForChild('Blood_Shop').Enabled = false
	script.Parent.Parent:WaitForChild("HUD"):WaitForChild("MatchMaking").Visible = true
	--[[script.Parent:WaitForChild('Start_Match'):WaitForChild('Normal').Visible = false
	script.Parent:WaitForChild('Start_Match'):WaitForChild('Pro').Visible = false
	script.Parent:WaitForChild('Back').Visible = false]]--
	
	--local script_source = require(game:GetService("ReplicatedFirst").Load)
	--local screen = script_source.load()
end

function ExitPressed()
	if JoinInProgress then return end
	
	script.Parent.Enabled = false
	script.Parent.Parent:WaitForChild('Blood_Shop').Enabled = false
	script.Parent.Parent:WaitForChild('ChooseBand').Enabled = true
	game.Players.LocalPlayer.Character.PrimaryPart.Anchored = false
end

script.Parent:WaitForChild('Back'):WaitForChild('Button').MouseButton1Click:Connect(ExitPressed)
script.Parent:WaitForChild('Start_Match'):WaitForChild('Normal'):WaitForChild('Button').MouseButton1Click:Connect(JoinPressed)
script.Parent:WaitForChild('Start_Match'):WaitForChild('Pro'):WaitForChild('Button').MouseButton1Click:Connect(ProJoinPressed)

function Update_Pro_Button()
	local amount = game.Players.LocalPlayer.Character:GetAttribute("Kills")
	local enabled = game.Players.LocalPlayer.Character:GetAttribute("Pro_Enabled")
	
	if amount >= 25 and enabled then
		script.Parent:WaitForChild('Start_Match'):WaitForChild('Pro').Visible = true
	else
		script.Parent:WaitForChild('Start_Match'):WaitForChild('Pro').Visible = false
	end
end

local function SetTeam()
	if not script.Parent.Enabled then return end

	if not (LocalPlayer.Character:GetAttribute("Team") == "Killer") then
		require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')):SetTeamAttribute("Killer",LocalPlayer)
	end
end

script.Parent.Changed:Connect(SetTeam)

game.Players.LocalPlayer.Character:GetAttributeChangedSignal('Kills'):Connect(Update_Pro_Button)
game.Players.LocalPlayer.Character:GetAttributeChangedSignal('Pro_Enabled'):Connect(Update_Pro_Button)
Update_Pro_Button()

--[[back.MouseEnter:Connect(BackHovered)
back.MouseLeave:Connect(backunHovered)
readyframe.MouseEnter:Connect(readyhovered)
readyframe.MouseLeave:Connect(readyunhovered)
]]