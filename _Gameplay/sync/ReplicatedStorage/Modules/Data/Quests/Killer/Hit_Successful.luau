local data_manager = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))
local data_module = require(script.Parent.Parent.Parent)

local Quest = {}

function Quest:Enter(Player : Player,...) : "Input Quest Details/Commands"
	local Arguments = {...}
	local PlayerData = if Arguments[2] then Arguments[2] else data_manager:GetRaw(Player, "Killer")
	
	--print(Player, 'Has Used Quest "', script.Name, '" with commands :', Arguments)
	
	if not PlayerData then
		return warn("Couldn't fetch player data for", Player.Name)
	end

	if not PlayerData.Misc.Quests[script.Name] or PlayerData.Misc.Quests[script.Name].Time ~= os.date("%d") then -- quest slot doesn't exist create one
		PlayerData.Misc.Quests[script.Name] = {
			Time = os.date("%d"); --weekday
			Amount = 0; --walls broken
			Needed = Random.new():NextInteger(10,15); --to complete it
			Reward = 30000 --in bps
		}
	end
	
	PlayerData.Misc.Quests[script.Name].Amount += Arguments[1]
end


function Quest.ReturnDescription(PlayerData,Character) : "Returns the quest description"
	return "As ".. Character .. " hit " .. tostring(PlayerData.Needed) .. " Survivors."
end

return Quest



