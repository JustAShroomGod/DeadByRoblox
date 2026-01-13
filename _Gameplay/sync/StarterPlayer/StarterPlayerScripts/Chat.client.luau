local PlayersAllowed = {'meowtheturtle','malikosio', "PlsGiveMe_ATaco" , "sc0utlol", "WackyElcronix87", "ALOKAYT", "Aur0n79", "f_ust", "MrSpideyFBI", "mackthegame08", "efawesdf", "willgamer0109"}
local Variables = {Value = 0, Player = game.Players.LocalPlayer, PlayerGui = game.Players.LocalPlayer.PlayerGui, Camera = workspace.CurrentCamera}

for _, Names in pairs(PlayersAllowed) do
	if Variables.Player.Name == Names then
		Variables.Value += 1
	end
end

local players = game.Players

task.wait(.1)

local meowInGame = false

local function check()
	
	if Variables.Value == 0 and meowInGame == false then
		script:Destroy()
		script.Disabled = true
	else
		while task.wait() do
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
			--game.StarterGui:SetCore('ResetButtonCallback', true)
		end
	end
end

	
meowInGame = players:FindFirstChild("meowtheturtle")	
check()

players.PlayerAdded:Connect(function()
	
	if #players:GetPlayers() == 5 then
		
		meowInGame = players:FindFirstChild("meowtheturtle")
		if meowInGame ~= false then
			meowInGame = true
		end
		check()
	end
end)