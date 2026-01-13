
-- Lines of code to execute if the players actually exist.
local player_list = {"I", "II", "III", "IV", "V"}

for x, roman in ipairs (player_list) do
	player_list[x] = game.ReplicatedStorage.Match.Players["Player(".. roman.. ")"]
end

local player = game:GetService("Players").LocalPlayer
player:WaitForChild("PlayerGui")

local char = player.Character or player.CharacterAdded:Wait()
char:WaitForChild('Humanoid')

local board = script.Parent:WaitForChild("body")

player:WaitForChild("trial_value")

if not player.trial_value.Value then
	player.trial_value.Changed:Wait()
end

local signal = {}

-- Use this function to check if they are alive or show there stuff.
local function check(player_value)
	if game:GetService("Players"):FindFirstChild(player_value.Value)
		and player_value.Connected.Value 
		and not player_value.Scaped.Value 
		and not player_value.Death.Value then
		return true
	end
end

-- This function looks at all the players and sets up the information.
function setup()
	for i,v in ipairs(player_list) do
		if v.Value == nil or not game.Players:FindFirstChild(v.Value) then else
			if game.Players[v.Value].Backpack.Scripts.Killer.Value == true then 
				update(board.main.list.killer.Frame.player, game.Players[v.Value].Name)
				return 
			end

			local clone = board.main.list.template.player:Clone()
			clone.Name =  game.Players[v.Value].Name
			clone.Parent = board.main.list
			clone.Visible = true

			update(clone, game.Players[v.Value].Name)
		end
	end
end

-- Use this function to update a set player.
function update(clone, playerNamed)
	--print(clone)
	clone:FindFirstChild("plrname").Text = string.upper(playerNamed)
	
	local cbp = 0	
	
	for i,v in ipairs(game.Players[playerNamed].Backpack.Scripts.values.Match.BloodPoints:GetChildren()) do
		cbp = cbp + v.Value
	end
	clone:FindFirstChild("points").Text = cbp
	
	if game.Players[playerNamed].trial_value.Value == player_list[5] then
		return
	end
	
	if player.trial_value.Value.Connected then
		clone.status.image.Image = "rbxassetid://1316516325"
	elseif player.trial_value.Value.Death.Value then
		clone.status.image.Image = "rbxassetid://1333274216"
	elseif player.trial_value.Value.Scaped then
		clone.status.image.Image = "rbxassetid://1411125596"
	else
		clone.status.image.Image = "rbxassetid://3109383955"
	end
end

setup()
