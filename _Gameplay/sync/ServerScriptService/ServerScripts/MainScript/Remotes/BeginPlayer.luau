local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RemoteStorage = ReplicatedStorage:WaitForChild('RemoteEvents')

local Data_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))

local remote = {}

local function GrabRemote()

	for _,r in pairs(RemoteStorage:GetChildren())do

		if string.lower(r.Name) == string.lower(script.Name) then
			return r
		end
	end

	return false
end

function GetKillers()
	local i = 0
	
	for _, p in pairs(game.Players:GetPlayers()) do
		
		if p:GetAttribute("Team") == "Killer" then
			i += 1
		end
	end
	
	return i
end

function GetSurvivors()
	local i = 0

	for _, p in pairs(game.Players:GetPlayers()) do

		if p:GetAttribute("Team") == "Survivor" then
			i += 1
		end
	end

	return i
end

function remote.new()
	local self = {}
	setmetatable(self, remote)

	local connection = GrabRemote()

	if connection then

		connection.OnServerEvent:Connect(function(Player, mode)
			local Current_Data = Data_Module:GetRaw(Player, 'Survivor') -->> get our mmk data
			Current_Data = Current_Data.Misc.MMK -->> grab mmk data

			if game["Run Service"]:IsStudio() then
				if Player.Name == "Player2" then
					Player:SetAttribute("Team", 'Survivor')
				else
					Player:SetAttribute("Team", if workspace:GetAttribute("TestingSurvivor") then "Survivor" else "Killer")
				end
			else
				
				if workspace:GetAttribute("CUSTOM_MODE") == "2 Killers" then
					
					if GetKillers() <= 1 then
						Player:SetAttribute("Team", "Killer")
					else
						Player:SetAttribute("Team", "Survivor")
					end
				elseif workspace:GetAttribute("CUSTOM_MODE") == "TOURNAMENT" then
					
					if GetKillers() >= 1 and GetSurvivors() >= 4 then
						Player:SetAttribute('Team', 'Spectator')
					else
						Player:SetAttribute("Team", Current_Data.Team)
					end
				else
					Player:SetAttribute("Team", Current_Data.Team)
				end
			end
			
			-- 	Player:SetAttribute("Team", mode) OLD CODE
		end)
	else
		warn('Remote does not exist:', script.Name)
	end

	return self
end

return remote.new()
