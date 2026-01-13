local ReplicatedStorage, PlayerService = game:GetService('ReplicatedStorage'), game:GetService('Players')
local Folder = ReplicatedStorage:WaitForChild('Match')
local playerFolder = Folder:WaitForChild('Players')

local Game_Data = ReplicatedStorage:WaitForChild('Game_Data')
local Perk_Data = Game_Data:WaitForChild('Perks'):WaitForChild('Survivor')

local match = {
	['Settings'] = {
		['Started_Game'] = Folder:WaitForChild('Started');
	}
	
}

match.__index = match

function match:Search(player : Player) : "Returns if player is in catagory" -- a function to see if a player is in players folder
	
	--[[if searchRange == 'Survivor' then
		
		for _,stringval in pairs(match.Players.Survivors) do
			if stringval.Value == tostring(player) then
				return stringval
			end
		end
	elseif searchRange == 'Killer' then
		
		for _,stringval in pairs(match.Players.Killers) do
			if stringval.Value == tostring(player) then
				return stringval
			end
		end
	elseif searchRange == 'All' then
		
		for _,stringval in pairs(match.Players.Survivors) do -- search through survivors first
			if stringval.Value == tostring(player) then
				return stringval
			end
		end
		

		for _,stringval in pairs(match.Players.Killers) do -- check killers next
			if stringval.Value == player.Name then
				return stringval
			end
		end
	end]]--
	
	if playerFolder:FindFirstChild(player.Name) then
		return playerFolder:WaitForChild(player.Name)
	end
	
	return false
end

function CalculateObsessionOdds(Player : Player)
	local Perks = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')):GetPerks("Survivor", Player)
	local odds : number = 1
	
	for perk, _ in pairs(Perks) do
		if not Perk_Data:FindFirstChild(perk) then warn(perk, 'not in perk data!') continue end
		perk = require(Perk_Data:WaitForChild(perk))
		
		if perk.Obsession_Boost then
			odds += perk.Obsession_Boost
		end
	end
	
	return odds
end

function match:Assign_Obsession()
	local survivors = game.Teams:WaitForChild('Survivor'):GetPlayers()
	local obsession_matrix = {}
	
	for _, player in pairs(survivors) do
		local player_string = match:Search(player)
		
		if player and player.Parent and player_string and player_string:GetAttribute("Connected") then
			table.insert(obsession_matrix, {player_string, CalculateObsessionOdds(player)})
		end
	end
	
	if #obsession_matrix >= 1 then
		table.sort(obsession_matrix, function(survivor_1, survivor_2)
			return survivor_1[2] > survivor_2[2] -- should sort from greatest chance of being obsession to least
		end)
		
		obsession_matrix[1][1]:SetAttribute("Obsession", true) -- assign the first survivor to be obsession since they should be the highers or only one always
	end
end

function match:ConnectPlayer(Player : Player, Team : string) : "Connects player to this value"
	local Player_Value = Instance.new('ObjectValue', playerFolder)
	
	Player_Value.Value = Player.Character
	Player_Value.Name = Player.Name
	
	if Team == 'Killer' then
		Player_Value:SetAttribute("Connected", true)
		Player_Value:SetAttribute('Team', 'Killer')
	else
		Player_Value:SetAttribute('Team', 'Survivor')
		Player_Value:SetAttribute("Dead", false)
		Player_Value:SetAttribute("Escaped", false)
		Player_Value:SetAttribute("Obsession", false)
		Player_Value:SetAttribute("Connected", true)
	end
end

function match:Update() : "Updates match count"
--	print('Updated:', #PlayerService:GetChildren())
	playerFolder:SetAttribute("Amount", #PlayerService:GetChildren())
	-- match.Players.Amount = #PlayerService:GetChildren() -- makes amount equal to people in server (should change)
end

return match
