local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')
local Sound_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Assets'):WaitForChild('Sounds')

local Global = {
	Images = {
		Red = "rbxassetid://89912015471223";
		Green = "rbxassetid://94869744700721";
		Yellow = "rbxassetid://98738804461400";
		Gray = "rbxassetid://101762998463619"
	};
	
	Colors = {
		Red = Color3.fromRGB(206, 41, 41);
		Green = Color3.fromRGB(92, 130, 35);
		Yellow = Color3.fromRGB(200, 169, 56);
		Gray = Color3.fromRGB(141, 141, 141)
	};
	
	Multiplier = {
		Red = 1.5;
		Green = 1.3;
		Yellow = 1.2;
		Gray = 1;
	};
	
	Rewards = {
		Red = 250000;
		Green = 100000;
		Yellow = 50000;
		Gray = 25000;
	};
	

	DescriptionKiller = "This is your killer rank. ";
	DescriptionSurvivor = "This is your survivor rank.";
}


function Global.Configure(Rank)
	if Rank then
		Global.DescriptionKiller = "This is your killer rank. You gain <b><font color='#c2b00e'> " ..  (tostring(Global.Multiplier[Rank] * 100)) .. "</font></b>% Blood from matches!";
		Global.DescriptionSurvivor = "This is your survivor rank. You gain <b><font color='#c2b00e'> " ..  (tostring(Global.Multiplier[Rank] * 100)) .. "</font></b>% Blood from matches!";
	end

	return Global
end

return Global.Configure()
