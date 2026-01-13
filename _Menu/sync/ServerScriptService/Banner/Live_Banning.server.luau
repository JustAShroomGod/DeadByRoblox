local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Remotes = ReplicatedStorage:WaitForChild('RemoteEvents')

local New_Data = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local encrypt = require(script:WaitForChild('Encryption'))

Remotes:WaitForChild('Key').OnServerEvent:Connect(function(Player, ...)
	local args = {...}
	local SurvivorData = New_Data:GetRaw(Player).Main
	local command = args[1]

	if command == "Data_Transfer"
		and args[2]
		and type(args[2]) == "string"
		and not SurvivorData.Misc.Transferred then
		
		local Decrypted_Data = encrypt:Decrypt(args[2], Player)

		print(Player, 'data transfer: v2')

		if Decrypted_Data then

			if Decrypted_Data.Player_ID == Player.UserId then
				local Final_Data = Decrypted_Data.Raw_Data
				local Server_Data = require(game:GetService('ServerStorage'):WaitForChild('Data'):WaitForChild('ProfileHandler')):Get(Player)

				Server_Data.Data = Final_Data

				task.wait(5)

				game:GetService('TeleportService'):Teleport(14904820737, Player)
			end
		else
			warn('Data was corrupted!')
		end
	end
end)

-----
local Https, MemoryService = game:GetService("HttpService"), game:GetService('MemoryStoreService')
local Cross_Ban = MemoryService:GetSortedMap('Bans')

local BanLoggerWebhook = if game:GetService("RunService"):IsStudio() then nil else Https:GetSecret("BanLoggerWebhook")
local AntiCheatWebhook = if game:GetService("RunService"):IsStudio() then nil else Https:GetSecret("AntiCheatWebhook")

function CheckBanList()
	local success, Current_Bans = pcall(function()
		return Cross_Ban:GetRangeAsync(Enum.SortDirection.Ascending, 20)
	end)

	if success and Current_Bans then

		for _,ban in pairs(Current_Bans) do
			local key, value = ban.key, ban.value
			local player_in_game = Players:FindFirstChild(value.PlayerName)

			if player_in_game then
				New_Data:Ban(player_in_game, value.Reason, true, true)
				
				local message = {
					["content"] = player_in_game.Name..' has been kicked through a ban!'
				}
				
				message = Https:JSONEncode(message)
				
				Https:PostAsync(AntiCheatWebhook, message)
			end
		end
	end
end

CheckBanList()

while task.wait(30) do
	CheckBanList()
end