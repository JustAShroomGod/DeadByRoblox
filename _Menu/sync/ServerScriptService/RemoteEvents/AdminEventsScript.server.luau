local Https = game:GetService("HttpService")

local GroupId = 3863491

local BanLoggerWebhook = if game:GetService("RunService"):IsStudio() then nil else Https:GetSecret("BanLoggerWebhook")
local AntiCheatWebhook = if game:GetService("RunService"):IsStudio() then nil else Https:GetSecret("AntiCheatWebhook")

game.ReplicatedStorage.RemoteEvents.DevEvents.OnServerEvent:Connect(function(Player, Context, ...)
	local Args = {...}
	
	if Player:GetRankInGroupAsync(GroupId) >= 210 then
		if Context == 'Rain' then
			require(script:WaitForChild('Blood_Rain')):Cast(Player, 1000)
		elseif Context == "Title" then
			require(Player.Character:WaitForChild("CharacterStuff"):WaitForChild("TitleHandler"):WaitForChild("Title")):Title_Display_Rank(Player, Args[1])
		end
	else
		local Data = {
		["content"] = "Hey! Fake Dev: "..Player.Name.." Tried to use the dev menu"
		}

		Data = Https:JSONEncode(Data)
		Https:PostAsync(BanLoggerWebhook, Data)
	end
end)