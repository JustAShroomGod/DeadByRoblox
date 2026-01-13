local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rank_Update = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Rank_Update")
local Rank_Module = require(ReplicatedStorage:WaitForChild("Game_Data"):WaitForChild("Ranks"):WaitForChild("Global"))

local Container = script.Parent:WaitForChild("Container")
local Survivor_Container = Container:WaitForChild("Survivor")
local Killer_Container = Container:WaitForChild("Killer")

local RomanNumerals = {
	{5, 'V'},
	{4, 'IV'},
	{1, 'I'}
}

local function CalculateAmount(Table)
	local Amount = 0
	
	for i,v in pairs(Table) do
		Amount += (Rank_Module.Rewards[i] * v)
	end
	
	return Amount
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

Rank_Update.OnClientEvent:Connect(function(Data)
	Survivor_Container:WaitForChild("Currency"):WaitForChild("Number").Text = Rank_Module.Rewards[Data.Survivor]
	Killer_Container:WaitForChild("Currency"):WaitForChild("Number").Text = CalculateAmount(Data.Killer)
	
	Survivor_Container:WaitForChild("Rank"):WaitForChild("Icon"):WaitForChild("Grade").Image = Rank_Module.Images[Data.Survivor]
	Survivor_Container:WaitForChild("Rank"):WaitForChild("Icon"):WaitForChild("Roman").Text = TranslateRank(Data.Highest_Survivor_Rank)[2]
	
	Killer_Container:WaitForChild("Rank"):WaitForChild("Icon"):WaitForChild("Grade").Image = Rank_Module.Images[Data.Survivor]
	Killer_Container:WaitForChild("Rank"):WaitForChild("Icon"):WaitForChild("Roman").Text = TranslateRank(Data.Highest_Killer_Rank)[2]
	script.Parent.Enabled = true
end)

script.Parent:WaitForChild("Continue"):WaitForChild("Button").MouseButton1Click:Connect(function()
	script.Parent.Enabled = false
end)