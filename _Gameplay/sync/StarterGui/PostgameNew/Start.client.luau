local player = game:GetService("Players").LocalPlayer
local replicatedPlayers = game.ReplicatedStorage.Match.Players
local Postgame = require(script.Parent.Postgame)
local gui = script.Parent

local function checkAndStartPostgame(value, status)
	if player.Name == value.Name and value:GetAttribute(status) then
		Postgame:Startup()
		gui.PostgameStarted.Value = true
		gui.Enabled = true
	end
end

for _, playerValue in ipairs(replicatedPlayers:GetChildren()) do
	if playerValue:IsA("StringValue") then
		playerValue:GetAttributeChangedSignal("Dead"):Connect(function()
			checkAndStartPostgame(playerValue, "Dead")
			--script.MatchResult_Lost:Play()
		end)

		playerValue:GetAttributeChangedSignal("Escaped"):Connect(function()
			checkAndStartPostgame(playerValue, "Escaped")
			--script.MatchResult_Won:Play()
		end)
	end
end

gui.Changed:Connect(function()
	if gui.Enabled == true and gui.PostgameStarted.Value == false then
		gui.Enabled = false
	elseif gui.Enabled == true and gui.PostgameStarted.Value == true then
		gui.Enabled = true
	end
end)