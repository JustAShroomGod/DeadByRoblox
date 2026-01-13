local data_manager = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))
local data_module = require(script.Parent.Parent)

local Quest = {}

function Quest:Enter(Player : Player, Arguments : "Table") : "Input Quest Details/Commands"
	local player_data = nil
	
	if Player.Team == game.Teams.Killer then
		player_data = data_manager:GetRaw(Player, "Killer")
	else
		player_data = data_manager:GetRaw(Player, "Survivor")
	end
	
	print(Player, 'Has Used Quest "', script.Name, '" with commands :', Arguments)
	
	if not player_data.Misc.Quests[script.Name] then -- quest slot doesn't exist create one
		player_data.Misc.Quests[script.Name] = {
			-- put data needed for this quest here
		}
	end
end

return Quest
