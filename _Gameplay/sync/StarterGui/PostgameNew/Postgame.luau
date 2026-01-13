














localPlayer = game:GetService("Players").LocalPlayer
localPlayer:WaitForChild("PlayerGui")
screen = script.Parent
screen.Enabled = true
screen.Parent = nil
screen_body = screen.Body

local Backpack = localPlayer:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")
local values = Scripts:WaitForChild("values")
local BPFolder = values:WaitForChild("Match"):WaitForChild("BloodPoints")


local module = {}

function CreateHover(instance)
	local self = {
		is_clickable = true
	}

	local BODYTRANSPARENCY = instance.Body.ImageTransparency
	local TRANSPARENCY = instance.Body.Outline.ImageTransparency
	local hover = instance.Body.Hover
	local IMAGERECTSIZE = hover.ImageRectSize
	instance.Button.MouseEnter:Connect(function ()
		if not self.is_clickable then return end
		hover.Size = UDim2.new(0, 0, 1, 0)
		hover.ImageRectOffset = Vector2.new()
		hover.ImageRectSize = IMAGERECTSIZE*Vector2.new(0, 1)
		local goal = {
			--ImageRectOffset = IMAGERECTSIZE,
			ImageRectSize = IMAGERECTSIZE,
			Size = UDim2.new(1, 0, 1, 0),
			ImageTransparency = 0
		}
		local tweeninfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
		local tween = game:GetService("TweenService"):Create(hover, tweeninfo, goal)
		tween:Play()

		instance.Body.Outline.ImageTransparency = 0
		instance.Body.ImageTransparency = 0
		instance.Label.TextTransparency = 0
	end)
	local function fadeout()
		instance.Label.TextTransparency = TRANSPARENCY
		instance.Body.ImageTransparency = BODYTRANSPARENCY
		instance.Body.Outline.ImageTransparency = TRANSPARENCY

		local tweeninfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
		local tween = game:GetService("TweenService"):Create(hover, tweeninfo, {ImageTransparency = 1})
		tween:Play()
	end
	fadeout()
	instance.Button.MouseLeave:Connect(function ()
		if not self.is_clickable then return end
		fadeout()
	end)

	function self:SetClickable(bool)
		self.is_clickable = bool
		if bool then
			instance.Label.TextTransparency = TRANSPARENCY
		else
			instance.Label.TextTransparency = 0.8
		end
		instance.Body.Visible = bool
	end

	self:SetClickable(true)
	return self
end
--Upgrade and Continue Buttons
local Continue do
	local instance = screen.BottomNavegator.Continue
		local self = {
		instance = instance,
		hover = CreateHover(instance),
	}

	local has_teleported = false
	instance.Button.MouseButton1Down:Connect(function ()
		if has_teleported then return end
		has_teleported = true
		game:GetService("TeleportService"):Teleport(14904820737, localPlayer)
	end)
end
local Upgrade do
	local instance = screen.BottomNavegator.Upgrade
		local self = {
		instance = instance,
		hover = CreateHover(instance),
	}

	local has_teleported = false
	instance.Button.MouseButton1Down:Connect(function ()
		if has_teleported then return end
		has_teleported = true
		game:GetService("TeleportService"):Teleport(14904820737, localPlayer, "SpendBloodpoints")
	end)
end






Prefab = require(script.PostgamePrefab)
require(script.PostgameWireframe)




--	Bloodpoints Earned
Category = {}
Category.__index = Category

function Category.new(name, imageid)
	local instance = Prefab.CategoriesPrefab:Clone()
	instance.Name = name:upper()
	instance.Category.Text = name:upper()
	instance.Icon.Image = "rbxassetid://".. tostring(imageid)
	instance.Parent = screen_body.BloodpointsEarned.Categories

	screen_body.BloodpointsEarned.Points.Match.Text = isKiller(localPlayer.Name) and BPFolder.Deviousness.Value + BPFolder.Hunter.Value + BPFolder.Sacrifice.Value + BPFolder.Brutality.Value or BPFolder.Altruism.Value + BPFolder.Boldness.Value + BPFolder.Survival.Value + BPFolder.Objectives.Value
	local testing = game:GetService("RunService"):IsStudio()

	if testing then
		BPFolder.Altruism.Value = 500
		BPFolder.Objectives.Value = 643
		BPFolder.Boldness.Value = 4255
		BPFolder.Survival.Value = 2000
		BPFolder.Deviousness.Value = 3456
		BPFolder.Hunter.Value = 6531
		BPFolder.Sacrifice.Value = 352
		BPFolder.Brutality.Value = 2456
	end

	if instance.Name == "ALTRUISM" then
		instance.Points.Text =  BPFolder.Altruism.Value
	elseif instance.Name == "BOLDNESS" then
		instance.Points.Text =  BPFolder.Boldness.Value
	elseif instance.Name == "OBJECTIVES" then
		instance.Points.Text =  BPFolder.Objectives.Value
	elseif instance.Name == "SURVIVAL" then
		instance.Points.Text =  BPFolder.Survival.Value
	elseif instance.Name == "SACRIFICE" then
		instance.Points.Text =  BPFolder.Sacrifice.Value
	elseif instance.Name == "HUNTER" then
		instance.Points.Text =  BPFolder.Hunter.Value
	elseif instance.Name == "BRUTALITY" then
		instance.Points.Text =  BPFolder.Brutality.Value
	elseif instance.Name == "DEVIOUSNESS" then
		instance.Points.Text =  BPFolder.Deviousness.Value
	end
end


InventoryUtility = require(script.UInventoryUtility)
PREFIX = "rbxassetid://"
local code = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Code"))
data = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Data"))

--	Online Grade
Emblem = {}
Emblem.__index = Emblem

function Emblem.new()
	local instance = Prefab.EmblemsPrefab:Clone()
	instance.Parent = screen_body.OnlineGrade.Emblems
end

Pip = {
	count = 0
}
Pip.__index = Pip

function Pip.new()
	Pip.count += 1

	local instance = Prefab.CheckboxesPrefab:Clone()
	instance.Parent = screen_body.OnlineGrade.Rank.Checkboxes[string.format("P%i", Pip.count)]
end


PlayerManager = {}
PlayerManager.__index = PlayerManager

function PlayerManager.new(playerValue)
	local self = {
		playerValue = playerValue
	}
	setmetatable(self, PlayerManager)
	local player = game:GetService("Players"):FindFirstChild(playerValue.Value)	
	self.DataStorage = player.Data
	
	return self
end

function PlayerManager:doMethod()
	
end

--	Scoreboard	
SurvivorBox = {
	list = {},
	count = 0,
}
SurvivorBox.__index = SurvivorBox


--local replicatedPlayers = game.ReplicatedStorage.Match.Players
--local playerList = {"Player(I)", "Player(II)", "Player(III)", "Player(IV)"}

--for _, playerName in ipairs(playerList) do
--	_G.currentPlayer = replicatedPlayers[playerName]
--end

function SurvivorBox.new(playerValue : StringValue)
	local playerManager = PlayerManager.new(playerValue)


	local self = {}
	setmetatable(self, SurvivorBox)
	local loadout = {
		Item = {
			name = playerManager.DataStorage.Item.Value,
		},
		Addons = {nil, nil},
		Perks = {nil, nil, nil, nil},
		Offering = nil,
		--Rank = playerManager.DataStorage.Stats.Rank.Value,
		Nickname = --[[playerManager.DataStorage.Stats.NickName.Value ~= "" and playerManager.DataStorage.Stats.NickName.Value or--]] playerValue.Value,
		
	}
	
	for i = 1, 2 do
		local addonslot = playerManager.DataStorage.Addons.Survivor["Slot".. tostring(i)]
		if addonslot.Value ~= "" then
		loadout.Addons[i] = {
			name = addonslot.Value
		}
		end
	end
	
	for i = 1, 4 do
		local perkslot = playerManager.DataStorage.Perks.Survivor:WaitForChild(data:GetPerks()):GetAttribute("Slot")
		if perkslot ~= "" then
			loadout.Perks[i] = {
				name = perkslot.Value,
				tier = playerManager.DataStorage.Perks.Survivor[perkslot.Value].Value
			}
		end
	end

	local instance = Prefab.SurvivorPrefab:Clone()
	instance.Parent = screen_body.Scoreboard.Survivors
	self.instance = instance


	local brainids = {
		biggest = 9644486741,
		big = 9644483194,
		medium = 9644482762,
		small = 9644482406,
		smallest = 9644481990,
	}

	local gradeids = {
		Red = brainids.biggest,
		Purple = brainids.big,
		Green = brainids.medium,
		Yellow = brainids.small,
		Gray = brainids.smallest,
	}
	--local rank = loadout.Rank

	--local grade = "None"
	--if rank > 16 then
	--	grade = "Gray"
	--else if rank > 12 then
	--		grade = "Yellow"

	--	else if rank > 8 then
	--			grade = "Green"

	--		else if rank > 4 then
	--				grade = "Purple"

	--			else if rank > 0  then
	--					grade = "Red"
	--				end
	--			end
	--		end
	--	end
	--end
	instance.PlayerName.Text = loadout.Nickname
	--instance.Rank.image.Image = "rbxassetid://".. tostring(gradeids[grade])


	--TODO loadup items, addons, offering, perks playername
	local Prefab2 = require(script.PostgameUIPrefab)

	local item do
		local data = loadout.Item
		if data then
			local instance = Prefab2.ItemPrefab:Clone()
			instance.Parent = self.instance.Item
			instance.InputButton.Visible = false
			InventoryUtility.DesignLoadersList.Item(instance, data)
		end
	end

	local function addon(i)
		local data = loadout.Addons[i]
		if data then
			local instance = Prefab2.AddonsPrefab:Clone()
			instance.Parent = self.instance.Addons[string.format("P%i", i)]
			InventoryUtility.DesignLoadersList.Addon(instance, data)
		end
	end
	for i = 1, 2 do addon(i) end
	
	local offering do
		local data = loadout.Offering
		if data then
			local instance = Prefab.OfferingPrefab:Clone()
			instance.Parent = self.instance.Offering
			InventoryUtility.DesignLoadersList.Offering(instance, data)
		end
	end

	local function perk(i)
		local data = loadout.Perks[i]
		if data then
			local instance = Prefab2.PerksPrefab:Clone()
			instance.Parent = self.instance.Perks[string.format("P%i", i)]
			InventoryUtility.DesignLoadersList.Perk(instance, data)
		end
	end
	for i = 1, 4 do perk(i) end
end

Navegator = {
	list = {},
	count = 0,
	current = 1
}
Navegator.__index = Navegator
function Navegator.new(page, name)
	Navegator.count += 1
	
	local self = {}
	setmetatable(self, Navegator)
	screen_body.Navegator.Checkboxes.Grid.CellSize = UDim2.new(1/Navegator.count, 0, 1, 0)

	local checkbox = Prefab.NavegatorCheckboxesPrefab:Clone()
	checkbox.Parent = screen_body.Navegator.Checkboxes

	self.checkbox = checkbox
	self.page = page
	self.name = name

	Navegator.list[Navegator.count] = self

	if Navegator.count == 1 then 
		self:select()
	else
		self:unselect()
	end

	return self
end

function Navegator:select()
	self.page.Visible = true
	self.checkbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	screen_body.Title.Text = self.name:upper()

	if self.page == screen_body.OnlineGrade or self.page == screen_body.PlayerLevel then
		screen_body.Title.Top.Text = "YOUR"
	else
		screen_body.Title.Top.Text = "MATCH"
	end
end

function Navegator:unselect()
	self.page.Visible = false
	self.checkbox.BackgroundColor3 = Color3.fromRGB()
end

function UpdatePage(dir)
	local x = Navegator.current+dir
	if x < 1 or x > Navegator.count then return end

	local previous = Navegator.list[Navegator.current]
	local now = Navegator.list[x]
	previous:unselect()
	now:select()

	Navegator.current = x
end

local Button = function (instance, dir)
	instance.Button.MouseButton1Down:Connect(function ()
		UpdatePage(dir)
	end)
end

Button(screen_body.Navegator.Backward, -1)
Button(screen_body.Navegator.Forward, 1)	

--TODO KillerBox-class



function isKiller(playerName)
	return code:isKiller(playerName)
end

function module:Startup()
	-- Mouse behavior fixment
	game:GetService("RunService").RenderStepped:Connect(function ()
		game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
		game:GetService("UserInputService").MouseIconEnabled = true
	end)

	--	Bloodpoints Earned
	if isKiller(localPlayer.Name)  then
		Category.new("Brutality", 7881420829)
		Category.new("Deviousness", 7881421113)
		Category.new("Hunter", 7881420976)
		Category.new("Sacrifice", 7881420639)
	else
		Category.new("Objectives", 8398945436)
		Category.new("Survival", 8398947082)
		Category.new("Altruism", 8398947395)
		Category.new("Boldness", 8398947257)
	end
	
	--	Online Grade
	for i = 1, 4 do Emblem.new() end
	for i = 1, 3 do Pip.new() end

	--	Scoreboard
	for _, playerValue in pairs (game:GetService("ReplicatedStorage").Match.Players:GetChildren()) do
		if playerValue:IsA("StringValue") and playerValue:GetAttribute("Team") ~= "Killer" and playerValue:GetAttribute("Connected") == true then
			SurvivorBox.new(playerValue)
		end
		
	end
	--	Navegator
	local teammode = isKiller(localPlayer.Name) and "Killer" or "Survivor"
	local onlinegradename = string.format("Online %s Grade", teammode)
	Navegator.new(screen_body.BloodpointsEarned, "Bloodpoints Earned")
	--[[Navegator.new(screen_body.OnlineGrade, onlinegradename)
	Navegator.new(screen_body.PlayerLevel, "Player Level")]]
	Navegator.new(screen_body.Scoreboard, "Scoreboard")


	
	--lighting setup
	local Lighting = game:GetService("Lighting")
	Lighting:FindFirstChildOfClass("Atmosphere"):Destroy()
	Lighting.TimeOfDay = 0
	script.Ambience.Parent = Lighting
	Lighting.Brightness = 1

	--saving OFFSETS so we can move the whole scene far away from the Gameplay visibility
	local function SETOFFSET(offset : CFrame)
		return script.Pivot.CFrame*offset
	end
	local function GETOFFSET(cframe : CFrame)
		return script.Pivot.CFrame:ToObjectSpace(cframe)
	end
	local CAMERAOFFSET = GETOFFSET(script.CameraPosition.CFrame)
	local POSITIONOFFSET = GETOFFSET(script.Position.CFrame)
	local PLATFORMOFFSET = GETOFFSET(script.Platform.CFrame)

	--welding grass positions onto the Platform Model
	local Grass = script.Grass
	local PlatformModel = script.Platform
	PlatformModel.Parent = workspace
	task.wait(0.5)
	Instance.new("Folder", PlatformModel).Name = "welds"
	for _, positionPart : Part in pairs(PlatformModel.Positions:GetChildren()) do
		local offset = PlatformModel.CFrame:ToObjectSpace(positionPart.CFrame)*CFrame.new(0, -positionPart.Size.Y/2, 0)
		local grass = Grass:Clone()
		grass.Anchored = false
		grass.Parent = PlatformModel		
		local weld = Instance.new("Weld", PlatformModel.welds)
		weld.Part0 = PlatformModel
		weld.Part1 = grass
		weld.C0 = offset+Vector3.new(0, grass.Size.Y/2, 0)
		--weld.C1 = offset:inverse()
	end
	PlatformModel.Positions:Destroy()
	task.wait(0.2)
	-- setting back the stored offsets onto the new location cframe
	script.Pivot.CFrame *= CFrame.new(0, -200, 0)
	PlatformModel.CFrame = SETOFFSET(PLATFORMOFFSET)
	script.Position.CFrame = SETOFFSET(POSITIONOFFSET)

	script.Tallytheme:Play()
	

	
	
	local UserApperance = require(script.UserAppearence)
	local Handler = {
		humanoid_settings = {
			Survivor = {
				BodyDepthScale = 0.68;
				BodyHeightScale = 1.2;
				BodyProportionScale = 0;
				BodyTypeScale = 0;
				BodyWidthScale = 0.68;
				HeadScale = 0.88;
			},
			Killer = {
				BodyDepthScale = 0.9;
				BodyHeightScale = 1.52;
				BodyProportionScale = 0;
				BodyTypeScale = 0;
				BodyWidthScale = 0.95;
				HeadScale = 1.2;
			}
		},
	}

	
	local playerNPC = game.Players:CreateHumanoidModelFromUserIdAsync(localPlayer.UserId)
	playerNPC.Parent = workspace

	--[[
	local playerNPC = script.StarterCharacter:Clone()
	playerNPC.Name = "Postgame".. localPlayer.Name
	playerNPC.Parent = workspace
	local useridCopy = Instance.new("NumberValue", playerNPC)
	useridCopy.Name = "UserId"
	useridCopy.Value = localPlayer.UserId
	local Mode = teammode	

	UserApperance.load(playerNPC, Handler.humanoid_settings[Mode])
	]]
	
	--playing the running animtrack
	local animation = Instance.new("Animation", script)	
	animation.AnimationId = isKiller(localPlayer.Name) and "rbxassetid://".. tostring(13988521481) or "rbxassetid://".. tostring(13988521481)
	
	local animtrack = playerNPC.Humanoid:LoadAnimation(animation)
	animtrack:Play()

	--setting the charactet outfit skin

	--setting the cframe of the NPC
	local cframe = script.Position.CFrame+Vector3.new(0, PlatformModel.Size.Y+2.5+playerNPC.Humanoid.HipHeight, 0)
	playerNPC.PrimaryPart.Anchored = true		warn("postgameg cframe has been set")
	playerNPC:PivotTo(cframe)
	
	
	-- platform stuff
	local REFERENCE = PlatformModel.CFrame
	local DEPTH = PlatformModel.Size.Z
	local function create_platform(copy : Part)
		copy = copy or PlatformModel:Clone()
		copy.Parent = workspace 
		return copy
	end
	local Platform = {create_platform(), create_platform(PlatformModel)}
	local START = -DEPTH
	local c = 1
	local TIMETAKEN = 3
	local mytick = tick()

	game:GetService("RunService"):BindToRenderStep("Postgame camera", 305, function ()
		local timelapsed = tick()-mytick
		if timelapsed > TIMETAKEN then
			c = 3-c
			mytick = tick()
		end

		local alpha = math.clamp(timelapsed/TIMETAKEN, 0, 1)
		local z = START+alpha*DEPTH

		local a = Platform[c]
		local b = Platform[3-c]
		a.CFrame = REFERENCE*CFrame.new(0, 0, z) 
		b.CFrame = a.CFrame*CFrame.new(0, 0, DEPTH) 
		
		workspace.CurrentCamera.CFrame = SETOFFSET(CAMERAOFFSET)
		local function disableScreen(myScreen)
			myScreen.Enabled  = false
			myScreen:SetAttribute("whyisdisabled", "Postgame script running")
		end
		disableScreen(localPlayer.PlayerGui.HUD)
		--disableScreen(localPlayer.PlayerGui.MatchGUI)
		--localPlayer.PlayerGui.SetSpectatorGUI.Disabled = true
		--disableScreen(localPlayer.PlayerGui.SpectatorGUI)
	end)
end

return module
