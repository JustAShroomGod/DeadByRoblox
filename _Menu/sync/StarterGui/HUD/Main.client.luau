local Players : Players, ReplicatedStorage : ReplicatedStorage = game:GetService("Players"), game:GetService("ReplicatedStorage")

local Player = game:GetService("Players").LocalPlayer
local Data = Player:WaitForChild('Data')

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Data_Module = require(Modules:WaitForChild("Data"))

local Rank_Module = require(ReplicatedStorage:WaitForChild("Game_Data"):WaitForChild("Ranks"):WaitForChild("Global"))
local Hover_Module = require(script.Parent:WaitForChild("Hover_Module"))

local RankIcon = script.Parent:WaitForChild("Rank"):WaitForChild("Icon")
local RankNumerals = script.Parent:WaitForChild("Rank"):WaitForChild("Icon"):WaitForChild("Roman")

local RankContainer = script.Parent:WaitForChild("Rank")

local Killer_Screen = script.Parent.Parent:WaitForChild("Killer_Screen")
local Survivor_Screen = script.Parent.Parent:WaitForChild("Survivor_Screen")

local Number_Abbrev = {"K", "M", "B"}

local RomanNumerals = {
	{5, 'V'},
	{4, 'IV'},
	{1, 'I'}
}

local function AbbrievateNumber(Amount : number) : string
	if Amount < 1000 then return Amount end -- return amount if not available for num abbrev
	local string_var = tostring(math.floor(Amount))

	return tonumber((string.sub(string_var, 1, ((#string_var + 2)%3) + 3))/100) .. Number_Abbrev[math.floor((#string_var-1)/3)]
end

local function UpdateBP()
	script.Parent:WaitForChild('Currency'):WaitForChild('Number').Text = AbbrievateNumber(Data:WaitForChild('Currency'):WaitForChild('Blood').Value)
end

local function TranslateNumerals(Value)	
	 if Value == RomanNumerals[1][1] then
		return RomanNumerals[1][2]
	 elseif Value == RomanNumerals[2][1] then
		return RomanNumerals[2][2]
	 else
		return string.rep(RomanNumerals[3][2],Value)
	 end
end

local function TranslateRank(Value)
	if Value <= 5 then
		return {"Red",TranslateNumerals(Value)}
	elseif Value <= 10 then
		return {"Yellow",TranslateNumerals(Value - 5)}
	elseif Value <= 15 then
		return {"Green",TranslateNumerals(Value - 10)}
	else
		return {"Gray",TranslateNumerals(Value - 15)}
	end
end

UpdateBP()

if Data_Module:IsWeekend() then
	script.Parent:WaitForChild("Currency"):WaitForChild("Icon"):WaitForChild("DesBG"):WaitForChild("BonusTxt").Visible = true
end

local function Update_Lobbies()	
	local Amount = workspace:GetAttribute("Server_Amount")

	if not Amount then Amount = 0 end
	
	if tonumber(Amount) >= 1 then
		script.Parent:WaitForChild("Normal_Counter").Text = "LOBBIES: " ..Amount
	else
		script.Parent:WaitForChild("Normal_Counter").Text = "LOBBIES "
	end
end

local function UpdateRank()
	local Rank = Data:WaitForChild("Stats"):WaitForChild("Ranks"):WaitForChild(if Player.Character:GetAttribute("Team") == "Survivor" then "Survivor" else Data:WaitForChild("Loadout"):WaitForChild("Killer").Value)

	local Rank_Translated = TranslateRank(Rank.Value)

	RankNumerals.Text = Rank_Translated[2]
	RankIcon.Grade.Image = Rank_Module.Images[Rank_Translated[1]]
end

Player.Character:GetAttributeChangedSignal('Kills'):Connect(Update_Lobbies)
Player.Character:GetAttributeChangedSignal('Escapes'):Connect(Update_Lobbies)
Data:WaitForChild('Loadout'):WaitForChild('Killer').Changed:Connect(UpdateRank)
workspace:GetAttributeChangedSignal('Server_Amount'):Connect(Update_Lobbies)
Data:WaitForChild('Currency'):WaitForChild('Blood').Changed:Connect(UpdateBP)


RankContainer.MouseEnter:Connect(function()
	local Rank = Data:WaitForChild("Stats"):WaitForChild("Ranks"):WaitForChild(if Player.Character:GetAttribute("Team") == "Survivor" then "Survivor" else Data:WaitForChild("Loadout"):WaitForChild("Killer").Value)
	local RankProgress = Data:WaitForChild("Stats"):WaitForChild("Rank_Progress"):WaitForChild(if Player.Character:GetAttribute("Team") == "Survivor" then "Survivor" else Data:WaitForChild("Loadout"):WaitForChild("Killer").Value)

	Hover_Module:Display("Rank",Rank_Module,Player.Character:GetAttribute("Team"),TranslateRank(Rank.Value)[1],RankProgress.Value)
end)

RankContainer.MouseLeave:Connect(function()
	Hover_Module:Hide()
end)

Killer_Screen:GetPropertyChangedSignal("Enabled"):Connect(function()
	if Killer_Screen.Enabled then 
		UpdateRank()
	end
	
	RankContainer.Visible = Killer_Screen.Enabled
end)

Survivor_Screen:GetPropertyChangedSignal("Enabled"):Connect(function()
	if Survivor_Screen.Enabled then 
		UpdateRank()
	end
	
	RankContainer.Visible = Survivor_Screen.Enabled
end)

Update_Lobbies()

require(Player.PlayerGui:WaitForChild("Pass"):WaitForChild("Loader"))