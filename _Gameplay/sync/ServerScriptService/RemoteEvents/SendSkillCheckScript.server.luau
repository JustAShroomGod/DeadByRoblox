local Https, MemoryService, Players = game:GetService("HttpService"), game:GetService('MemoryStoreService'), game:GetService("Players")
local Cross_Ban = MemoryService:GetSortedMap('Bans')

local Data_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))
local RemoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local Remote = RemoteEvents:WaitForChild("SendSkillCheck")

local lastSent = {}
local triggers = {}


Remote.OnServerEvent:Connect(function(Player, ...)
	local args = {...} --[1] = skill check,[2] = context, [3] = generator (if needed)
	
	local SkillCheck = args[1]
	
	if args[2] == "Generator" then
		local Generator = args[3]
		
		if Generator and (Player.Character.HumanoidRootPart.Position - Generator.PrimaryPart.Position).Magnitude <= 19 then

			if lastSent[Player.Name] then

				if (workspace:GetServerTimeNow() - lastSent[Player.Name].Time) >= 5 then -- if time is more then 5 then reset
					lastSent[Player.Name].Time = workspace:GetServerTimeNow() -- reset time
					lastSent[Player.Name].Count = 0 -- reset count
				end

				lastSent[Player.Name].Count += 1 -- add 1 to count



				if lastSent[Player.Name].Count >= 10 and not triggers[Player.Name] then
					triggers[Player.Name] = true

					--[[local Data = {
						["content"] = "Anti-Cheat Triggered for "..Player.Name.." was banned for trying to send more then 10 skill checks in less then 5 seconds (GENERATOR)"
					}

					Data = Https:JSONEncode(Data)
					Https:PostAsync(Https:GetSecret("AntiCheatWebhook"), Data)

					Cross_Ban:SetAsync(Player.UserId, {
						PlayerName = Player.Name;
						Reason = "Exploits"
					}, 120)]]
					
					local BanConfig:BanConfigType = {
						UserIds = {Player.UserId};
						Duration = -1;
						DisplayReason = "Exploits";
						PrivateReason = "AntiCheat has been triggered";
						ExcludeAltAccounts = false;
						ApplyToUniverse = true
					}

					local Success,Error = pcall(function()
						Players:BanAsync(BanConfig,Player.UserId)
					end)

					if Success then
						local Message = {
							["content"] = 
								"ANTICHEAT HAS USED THE BAN HAMMER \n" ..
								"Name/UserId: " .. Players:GetNameFromUserIdAsync(Player.UserId) .. " / " .. Player.UserId .. "\n" ..
								"Duration: Permanent \n" ..
								"Display Reason: Exploits \n" ..
								"Private Reason: AntiCheat has been triggered for trying to send more then 10 skill checks in less then 5 seconds \n" ..
								"ExcludeAltAccounts: false \n" ..
								"ApplyToUniverse: true \n" 

						}

						Https:PostAsync(Https:GetSecret("AntiCheatWebhook"), Https:JSONEncode(Message))
					elseif not Success or Error then
						local Message = {
							["content"] = {
								"SOMETHING WENT WRONG WHILE BANNING A PLAYER NAMED " .. Players:GetNameFromUserIdAsync(Player.UserId) .. " / " .. Player.UserId .. "BY THE ANTICHEAT"
							}
						}

						Https:PostAsync(Https:GetSecret("AntiCheatWebhook"), Https:JSONEncode(Message))
					end
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
	elseif args[2] == "Heal" then
		if lastSent[Player.Name] then

			if (workspace:GetServerTimeNow() - lastSent[Player.Name].Time) >= 5 then -- if time is more then 5 then reset
				lastSent[Player.Name].Time = workspace:GetServerTimeNow() -- reset time
				lastSent[Player.Name].Count = 0 -- reset count
			end

			lastSent[Player.Name].Count += 1 -- add 1 to count

			if lastSent[Player.Name].Count >= 10 and not triggers[Player.Name] then
				triggers[Player.Name] = true

				local Data = {
					["content"] = "Anti-Cheat Triggered for "..Player.Name.." was banned for trying to send more then 10 skill checks in less then 5 seconds (HEALING) NOT BANNED!"
				}

				Data = Https:JSONEncode(Data)
				Https:PostAsync(Https:GetSecret("AntiCheatWebhook"), Data)

				--[[Cross_Ban:SetAsync(Player.UserId, {
					PlayerName = Player.Name;
					Reason = "Exploits"
				}, 120)]]
			end
		else
			lastSent[Player.Name] = {
				Count = 1, -- amount sent in interval
				Time = workspace:GetServerTimeNow(), -- time to compare
			}
		end

		if not triggers[Player.Name] then
			local reward, Action = 0, ""

			if SkillCheck == 'Good' then
				reward, Action = 30, 'GOOD SKILL CHECK'
			elseif SkillCheck == 'Great' then
				reward, Action = 250, 'GREAT SKILL CHECK'
			end

			Data_Module:GiveBlood(Player, reward, "Altruism", Action)
		end
	end
end)
