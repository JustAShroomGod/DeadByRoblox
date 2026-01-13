local plr : Player = game:GetService("Players").LocalPlayer
local PlayerGui : PlayerGui = plr:WaitForChild("PlayerGui")

local Chooseband = script.Parent
local Selector = Chooseband.Selector

local testing = script:GetAttribute("TESTING")


local children1 = Selector.Upper:GetChildren()
local children2 = Selector.Lower:GetChildren()

local CustomGameUI = PlayerGui:WaitForChild("CustomGame")

local killerButton = Selector.Upper.Killer.Button
local survivorButton = Selector.Upper.Survivor.Button
local swfButton = Selector.Upper.Customgame.Button
local storeButton = Selector.Upper.Shop.Button
local credits = Selector.Lower.Credits.Button
local news = Selector.Upper.News.Button
local settingsbutton = Selector.Lower.Settings.Button
local rulesbutton = Selector.Lower.Rules.Button
local creditsBut = Selector.Lower.Credits.Button
local quests = Selector.Lower.Quests.Button
local statistic = Selector.Upper["Statistic"].Button
local testingmenu = Selector.Upper.TestingMenu.Button
local pass = Selector.Upper.Pass.Button

local sounds = {
	[1] = PlayerGui:WaitForChild("Sounds"):WaitForChild("Ui"):WaitForChild("Pressed"),
	[2] = PlayerGui:WaitForChild("Sounds"):WaitForChild("Ui"):WaitForChild("Hover")
}


local selectioninfo = {
	Credits = "The collection of fine people who made Dead by Roblox possible, served in a handy list.";
	Rules = "Read the in-game rules.";
	Customgame = "Create custom matches against friends or play together as teams against killers.";
	Survivor = "Play as Survivor in ranked Matches and escape the Killer to live another day.";
	Killer = "Play as a brutal Killer in ranked matches. Sacrifice Survivors to please the Entity.";
	Shop = "Purchase characters, outfits customization items using Blood.";
	Settings = "Various options to customize your game experience.";
	News = "The latest news, developer posts and patch notes.";
	Quests = "Quests which on completion reward you with Blood";
	Statistic = "Check out all of your statistics.";
	TestingMenu = "Move to Testing Menu.";
	Pass = "Seasonal Halloween pass.";
}

local selectiontitles = {
	Credits = "Credits";
	Customgame = "Play With Friends";
	Survivor = "Play as Survivor";
	Killer = "Play as Killer";
	Shop = "Store";
	Settings = "Settings";
	Rules = "Rules";
	News = "News";
	Quests = "Quests";
	Statistic = "Statistics";
	TestingMenu = "Testing Menu";
	Pass = "Halloween Pass";
}

local sb = nil
if workspace.CurrentCamera:FindFirstChild("StartBlur") == nil then
	sb = Instance.new("BlurEffect",workspace.CurrentCamera)
	sb.Name = "StartBlur"
	sb.Size = 5
	sb.Enabled = true
else
	sb = workspace.CurrentCamera:FindFirstChild("StartBlur")
	sb.Size = 5
	sb.Enabled = true
end

if workspace.CurrentCamera:FindFirstChild("SWFBlur") == nil then
	blurEffect = Instance.new("BlurEffect", workspace.CurrentCamera)
	blurEffect.Name = "SWFBlur"
	blurEffect.Enabled = false
	blurEffect.Size = 32
else
	blurEffect = workspace.CurrentCamera:FindFirstChild("SWFBlur")
	blurEffect.Enabled = false
end

function SwfButtonPressed()
	PlayerGui:WaitForChild("ChooseBand").Enabled = false
	CustomGameUI.Enabled = true
	blurEffect.Enabled = true

	sounds[1]:Play()
end

function KillerButtonPressed()
	--plr.Character.PrimaryPart.Anchored = true

	if not plr:WaitForChild("Data"):WaitForChild("Stats"):WaitForChild("Tutorial"):WaitForChild("Killer").Value then
		PlayerGui:WaitForChild("ChooseBand").Enabled = false
		
		require(script.Parent.Parent:WaitForChild("Tutorials"):WaitForChild("Container"):WaitForChild("Handler")).Open("Killer")
		return
	end

	if PlayerGui:WaitForChild("Killer_Screen").Enabled == false then

		sounds[1]:Play()

		PlayerGui:WaitForChild("ChooseBand").Enabled = false
		PlayerGui:WaitForChild("Killer_Screen").Enabled = true
	end
end

function SurvivorButtonPressed()
	--plr.Character.PrimaryPart.Anchored = true

	if not plr:WaitForChild("Data"):WaitForChild("Stats"):WaitForChild("Tutorial"):WaitForChild("Survivor").Value then
		PlayerGui:WaitForChild("ChooseBand").Enabled = false
		
		require(script.Parent.Parent:WaitForChild("Tutorials"):WaitForChild("Container"):WaitForChild("Handler")).Open("Survivor")
		return
	end

	if PlayerGui:WaitForChild("Survivor_Screen").Enabled == false then
		sounds[1]:Play()

		PlayerGui:WaitForChild("ChooseBand").Enabled = false
		PlayerGui:WaitForChild("Survivor_Screen").Enabled = true
	end
end

function ShopButtonPressed()
	--plr.Character.PrimaryPart.Anchored = true

	if PlayerGui:WaitForChild("Shop").Enabled == false then
		sounds[1]:Play()

		PlayerGui:WaitForChild("ChooseBand").Enabled = false
		PlayerGui:WaitForChild("Shop").Enabled = true
	end
end


function NewsButtonPressed()
	--plr.Character.PrimaryPart.Anchored = true

	if PlayerGui:WaitForChild("ChooseBand"):WaitForChild("ANNOUNCEMENT").Visible == false then
		sounds[1]:Play()
		PlayerGui:WaitForChild("ChooseBand"):WaitForChild("Selector").Visible = false
		PlayerGui:WaitForChild("ChooseBand"):WaitForChild("ANNOUNCEMENT").Visible = true
	end
end

function SettingsButtonPressed()
	--plr.Character.PrimaryPart.Anchored = true

	if PlayerGui:WaitForChild("OptionsMenu").Enabled == false then
		sounds[1]:Play()

		PlayerGui:WaitForChild("ChooseBand").Enabled = false
		PlayerGui:WaitForChild("OptionsMenu").Enabled = true
	end
end

function CreditButtonPressed()
	--plr.Character.PrimaryPart.Anchored = true

	if PlayerGui:WaitForChild("CreditsScreen").Enabled == false then
		sounds[1]:Play()
		PlayerGui:WaitForChild("ChooseBand").Enabled = false
		PlayerGui:WaitForChild("CreditsScreen").Enabled = true
	end
end

function RulesButtonPressed()
	--plr.Character.PrimaryPart.Anchored = true

	if PlayerGui:WaitForChild("RulesScreen").Enabled == false then
		sounds[1]:Play()

		PlayerGui:WaitForChild("ChooseBand").Enabled = false
		PlayerGui:WaitForChild("RulesScreen").Enabled = true
	end
end


function QuestsButtonPressed()
	--plr.Character.PrimaryPart.Anchored = true

	if PlayerGui:WaitForChild("Quests").Enabled == false then
		sounds[1]:Play()

		PlayerGui:WaitForChild("ChooseBand").Enabled = false
		PlayerGui:WaitForChild("Quests").Enabled = true
	end
end

function StatisticButtonPressed()
	--plr.Character.PrimaryPart.Anchored = true

	--if PlayerGui:WaitForChild("Statistic_Screen").Enabled == false then
		sounds[1]:Play()

		PlayerGui:WaitForChild("ChooseBand").Enabled = false
		require(PlayerGui:WaitForChild("Statistic_Screen"):WaitForChild("Handler")).Connect(plr)
		--PlayerGui:WaitForChild("Statistic_Screen").Enabled = true
	--end
end


function PassButtonPressed()
	--plr.Character.PrimaryPart.Anchored = true

	if PlayerGui:WaitForChild("Pass").Enabled == false then
		sounds[1]:Play()

		PlayerGui:WaitForChild("ChooseBand").Enabled = false
		PlayerGui:WaitForChild("Pass").Enabled = true
	end
end


function TestingMenuButtonPressed()
	sounds[1]:Play()

	PlayerGui:WaitForChild("ChooseBand").Enabled = false

	game:GetService("TeleportService"):Teleport(17105536841, plr)
end

function unselect(frame)
	Selector.Caption.Visible = false
	Selector.Title.Visible = false
end

function selection(frame)
	Selector.Caption.Visible = true
	Selector.Title.Visible = true
	Selector.Caption.Text = selectioninfo[frame.Name]
	Selector.Title.Text = selectiontitles[frame.Name]:upper()

	sounds[2]:Play()
end

for i = 1, #children1 do
	if children1[i]:IsA("Frame") then
		children1[i].MouseEnter:Connect(function()
			selection(children1[i])
			sounds[2]:Play()
		end)
		children1[i].MouseLeave:Connect(function()
			unselect(children1[i])
		end)
		for _, v in ipairs(children1[i]:GetDescendants()) do
			if v:IsA("ImageButton") then
				v.MouseButton1Down:Connect(function()
					unselect(children1[i])
				end)
			end
		end
	end
end

for i = 1, #children2 do
	if children2[i]:IsA("Frame") then
		children2[i].MouseEnter:Connect(function()
			selection(children2[i])
			sounds[2]:Play()
		end)
		children2[i].MouseLeave:Connect(function()
			unselect(children2[i])
		end)
		for _, v in ipairs(children2[i]:GetDescendants()) do
			if v:IsA("ImageButton") then
				v.MouseButton1Click:Connect(function()
					unselect(children2[i])
				end)
			end
		end
	end
end

killerButton.MouseButton1Click:Connect(KillerButtonPressed)
creditsBut.MouseButton1Click:Connect(CreditButtonPressed)
survivorButton.MouseButton1Click:Connect(SurvivorButtonPressed)
swfButton.MouseButton1Click:Connect(SwfButtonPressed)
storeButton.MouseButton1Click:Connect(ShopButtonPressed)
settingsbutton.MouseButton1Click:Connect(SettingsButtonPressed)
rulesbutton.MouseButton1Click:Connect(RulesButtonPressed)
news.MouseButton1Click:Connect(NewsButtonPressed)
quests.MouseButton1Click:Connect(QuestsButtonPressed)
statistic.MouseButton1Click:Connect(StatisticButtonPressed)
pass.MouseButton1Click:Connect(PassButtonPressed)

if (plr:GetRankInGroupAsync(3863491) >= 207 or plr:GetRankInGroupAsync(3863491) == 151) and game.PlaceId == 14904820737 then
	testingmenu.Parent.Visible = true
	testingmenu.MouseButton1Click:Connect(TestingMenuButtonPressed)
end