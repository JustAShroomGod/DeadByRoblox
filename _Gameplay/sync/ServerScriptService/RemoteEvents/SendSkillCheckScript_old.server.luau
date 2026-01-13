local Https, MemoryService = game:GetService("HttpService"), game:GetService('MemoryStoreService')
local Cross_Ban = MemoryService:GetSortedMap('Bans')

local Data_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))
local RemoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local Remote = RemoteEvents:WaitForChild("SendSkillCheck")

local lastSent = {}
local triggers = {}

Remote.OnServerEvent:Connect(function(Player, SkillCheck, Generator)
	
	if Generator and (Player.Character.HumanoidRootPart.Position - Generator.PrimaryPart.Position).Magnitude <= 19 then
		
		if lastSent[Player.Name] then
			
			if (workspace:GetServerTimeNow() - lastSent[Player.Name].Time) >= 5 then -- if time is more then 5 then reset
				lastSent[Player.Name].Time = workspace:GetServerTimeNow() -- reset time
				lastSent[Player.Name].Count = 0 -- reset count
			end
			
			lastSent[Player.Name].Count += 1 -- add 1 to count
			
			
			
			if lastSent[Player.Name].Count >= 10 and not triggers[Player.Name] then
				triggers[Player.Name] = true
				
				local Data = {
					["content"] = "Anti-Cheat Triggered for "..Player.Name.." was banned for trying to send more then 10 skill checks in less then 5 seconds"
				}

				Data = Https:JSONEncode(Data)
				Https:PostAsync(Https:GetSecret("AntiCheatWebhook"), Data)
				
				Cross_Ban:SetAsync(Player.UserId, {
					PlayerName = Player.Name;
					Reason = "Exploits"
				}, 120)
			end
		else
			lastSent[Player.Name] = {
				Count = 1, -- amount sent in interval
				Time = workspace:GetServerTimeNow(), -- time to compare
			}
		end
		
		if not triggers[Player.Name] then
			local newCheck = Instance.new("IntValue")
			newCheck.Name = tostring(SkillCheck)
			newCheck.Parent = Generator:WaitForChild("Panel"):WaitForChild("SkillChecks")

			local reward, Action = 0, ""

			if SkillCheck == 'Good' then
				reward, Action = 50, 'GOOD SKILL CHECK'
			elseif SkillCheck == 'Great' then
				reward, Action = 300, 'GREAT SKILL CHECK'
			end
			
			
			Data_Module:GiveBlood(Player, reward, "Objectives", Action)
		end
	end
end)