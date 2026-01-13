--[[ARGUMENTS: 
[1] - UserId (of the player you want to ban)
[2] - Duration (of the ban; perma is -1)
[3] - Display reason (reason the banned player sees)
[4] - Private reason (reason moderators can see)
[5] - ExcludeAltAccounts (include their alts)
[6] - ApplyToUniverse (apply to all places in a universe)
]]

local Players : Players, ReplicatedStorage : ReplicatedStorage, HttpService : HttpService = game:GetService("Players"), game:GetService("ReplicatedStorage"), game:GetService("HttpService")

local RemoteEvents : Folder = ReplicatedStorage:WaitForChild("RemoteEvents")
local AdminEvents : RemoteEvent = RemoteEvents:WaitForChild("AdminEvents")

local BanLoggerWebhook = if game:GetService("RunService"):IsStudio() then nil else HttpService:GetSecret("BanLoggerWebhook")
local AntiCheatWebhook = if game:GetService("RunService"):IsStudio() then nil else HttpService:GetSecret("AntiCheatWebhook")

local Banned_Groups = {
	34035150, -- exploiting group
}

local MinAccAge = 0


Players.PlayerAdded:Connect(function(Player : Player)
	local GroupRank = Player:GetRankInGroupAsync(3863491)

	if GroupRank >= 210 then
		local newPanel = script:FindFirstChild("AdminPanel"):Clone()
		newPanel.Parent = Player:WaitForChild("PlayerGui")
		newPanel.PanelCore.Enabled = true
	end
	
	for _, group_id in pairs(Banned_Groups) do
		if Player:IsInGroupAsync(group_id) then
			Player:Kick("Alt-Prevention: Compromised account!")
		end
	end

	--if Player.AccountAge <= MinAccAge then
		--Player:Kick("Alt-Prevention: Come back tomarrow!")
	--end
end)

AdminEvents.OnServerEvent:Connect(function(Player, Context, ...)
	local args = {...}
	
	if not (Player:GetRankInGroupAsync(3863491) >= 210) then return end
	
	if Context == "Ban" then
		local BanConfig: BanConfigType = {
			UserIds = {args[1]};
			Duration = math.clamp(args[2], -1, math.huge);
			DisplayReason = args[3];
			PrivateReason = args[4];
			ExcludeAltAccounts = args[5];
			ApplyToUniverse = true
		}
		
		local Success,Error = pcall(function()
			Players:BanAsync(BanConfig, args[1])
		end)
		
		if Success then			
			local Message = {
				["content"] = 
					"**A Player has been been Banned!** \n" ..
					"* Moderator: " .. Player.Name .. '\n' ..
					"* Name/UserID: " .. Players:GetNameFromUserIdAsync(args[1]) .. " / " .. args[1] .. "\n" ..
					"* Duration: " .. BanConfig.Duration .. "\n" ..
					"* Display Reason: " .. args[3] .. "\n" ..
					"* Private Reason: "  .. args[4] .. "\n" ..
					"* ExcludeAltAccounts:" .. tostring(args[5]) .. "\n" ..
					"* ApplyToUniverse: false\n" 
			}

			HttpService:PostAsync(BanLoggerWebhook, HttpService:JSONEncode(Message))
		elseif not Success or Error then
			local Message = {
				["content"] = {
					"SOMETHING WENT WRONG WHILE BANNING A PLAYER NAMED " .. Players:GetNameFromUserIdAsync(args[1]) .. " / " .. args[1] .. "BY THE MODERATOR: " .. Player.Name
				}
			}
			
			local Success_Http,Error_Http = pcall(function()
				HttpService:PostAsync(BanLoggerWebhook, HttpService:JSONEncode(Message))
			end)

			warn(Success_Http,Error_Http)
		end
	elseif Context == "Unban" then
		local UnbanConfig:UnbanConfigType = {
			UserIds = {args[1]};
			ApplyToUniverse = true
		}

		local Success,Error = pcall(function()
			Players:UnbanAsync(UnbanConfig)
		end)

		if Success then
			local Message = {
				["content"] = 
					"**A Player has been been Unbanned!** \n" ..
					"* Moderator: " .. Player.Name .. '\n' ..
					"* Name/UserID: " .. Players:GetNameFromUserIdAsync(args[1]) .. " / " .. args[1] .. "\n" 
			}

			HttpService:PostAsync(BanLoggerWebhook, HttpService:JSONEncode(Message))
		elseif not Success or Error then
			local Message = {
				["content"] = {
					"SOMETHING WENT WRONG WHILE UNBANNING A PLAYER NAMED " .. Players:GetNameFromUserIdAsync(args[1]) .. " / " .. args[1] .. "BY THE MODERATOR: " .. Player.Name
				}
			}

			HttpService:PostAsync(BanLoggerWebhook, HttpService:JSONEncode(Message))
		end
	elseif Context == "Kick" then
		local player = game:GetService("Players"):GetPlayerByUserId(args[1])
		
		if (not player) then
			return
		end
		
		local Message = {
			["content"] = 
				"**A Player has been been Kicked!** \n" ..
				"* Moderator: " .. Player.Name .. '\n' ..
				"* Name/UserID: " .. Players:GetNameFromUserIdAsync(args[1]) .. " / " .. args[1] .. "\n" ..
				"* Display Reason: " .. args[3] .. "\n"
		}

		HttpService:PostAsync(BanLoggerWebhook, HttpService:JSONEncode(Message))
		
		player:Kick(args[3])
	end
end)
