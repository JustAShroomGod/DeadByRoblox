local PlayerService, TweenService, ReplicatedStorage, ReplicatedFirst, SoundService, RunService, TeleportService, Teams, ServerStorage = game:GetService('Players'), game:GetService('TweenService'), game:GetService('ReplicatedStorage'), game:GetService('ReplicatedFirst'), game:GetService('SoundService'), game:GetService('RunService'), game:GetService('TeleportService'), game:GetService('Teams'), game:GetService("ServerStorage")


local Entity_Module = require(script:WaitForChild('TanglesController'))
local Snippet_Module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Match_Folder : Folder = ReplicatedStorage:WaitForChild('Match')
local Audio_Folder : Folder = script:WaitForChild('Audio')

local MainMenu_ID = 14904820737

local Endgame = {
	Started = false;
}

local Settings = {
	Length = 120;
	Modifiers = {
		Hook = 0.5; -- hook doubles the length
		Down = 0.8; -- down adds 20% more time
	}
}

local Connections = {}

function PlaySound(sound : Sound, Location : Instance) : "Plays sound"
	if not Location then Location = SoundService end
	
	if Location:FindFirstChild(sound.Name) then
		if not Location:FindFirstChild(sound.Name).Playing then
			Location:FindFirstChild(sound.Name):Play(nil)
		end
	else
		local clone = sound:Clone()
		clone.Parent = if Location then Location else SoundService

		clone:Play()
	end
end

function Endgame:Start() : "Start the end game collapse"
	if Endgame.Started then return print("Endgame was already started...") end
	Endgame.Started = true
	
	PlaySound(Audio_Folder:WaitForChild('Start'))
    PlaySound(Audio_Folder:WaitForChild('During'))

	if workspace:FindFirstChild("EGCParticles") then
		if workspace:FindFirstChild("EGCParticles"):FindFirstChild("Sparks") then
			workspace:FindFirstChild("EGCParticles"):FindFirstChild("Sparks").Enabled = true
		end
	end

	for i,object in pairs(workspace:GetChildren()) do
		if string.match(object.Name, "Generator") then
			object:SetAttribute("Blocked", true)
		end
	end
	
	workspace:SetAttribute("Endgame", "0:"..Settings.Length)
	workspace:SetAttribute("Endgame_Modifier","Normal")
	
	local Finished = false
	local function Finish()
		if Connections.Collapse then Connections.Collapse:Disconnect() Connections.Collapse = nil end
		if Connections.Modifier then Connections.Modifier:Disconnect() Connections.Modifier = nil end
		
		if Finished then return end
		Finished = true
		
		PlaySound(Audio_Folder:WaitForChild('End'))
		
		if SoundService:FindFirstChild("Final") then
			SoundService:FindFirstChild("Final"):Destroy()
		end

		if SoundService:FindFirstChild("Slowed") then
			SoundService:FindFirstChild("Slowed"):Destroy()
		end
		
		for _, Player : Player in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do
			if not Player:WaitForChild('Backpack'):FindFirstChild('Scripts') then continue end
			local Our_Value = Match_Folder:WaitForChild('Players'):FindFirstChild(Player.Name)
			
			if Our_Value
				and not Our_Value:GetAttribute('Dead')
				and not Our_Value:GetAttribute('Escaped') then
				
				local success, err = pcall(function ()
					return Entity_Module.KillCharacter(Player.Character)
				end)
				
				Our_Value:SetAttribute("Dead", true)
				Snippet_Module:AddDeath(Player)
			end
		end
	end
	
	Connections.Collapse = RunService.Heartbeat:Connect(function(delta)
		local collapse_info = string.split(workspace:GetAttribute("Endgame"), ':')
		local current_elapsed, total_elapsed = collapse_info[1], collapse_info[2]
		local collapse_adding, modifier = delta, 1
		
		-- check if downed/hooked and apply modifiers to collapse --
		
		for _, Player : Player in pairs(Teams.Survivor:GetPlayers()) do -- should only pull up alive and in-game survivors
			
			if Snippet_Module:IsHooked(Player) and modifier ~= Settings.Modifiers.Hook then
				modifier = Settings.Modifiers.Hook
				workspace:SetAttribute("Endgame_Modifier","Slow")
				break
			elseif Snippet_Module:IsDown(Player) and modifier ~= Settings.Modifiers.Down then
				modifier = Settings.Modifiers.Down
				workspace:SetAttribute("Endgame_Modifier","Slow")
				break
			end
		end
	
		if modifier == 1 and workspace:GetAttribute("Endgame_Modifier") ~= "Normal" then
			workspace:SetAttribute("Endgame_Modifier","Normal")
			
			if SoundService:FindFirstChild("Slowed") then
				SoundService:FindFirstChild("Slowed"):Destroy()
			end
		end

		current_elapsed = tonumber(current_elapsed) + tonumber(delta * modifier)

		if tonumber(current_elapsed) >= tonumber(total_elapsed) then
			workspace:SetAttribute("Endgame", total_elapsed..':'..total_elapsed)
			Finish()
		else -- just add for now
			workspace:SetAttribute("Endgame", current_elapsed..':'..total_elapsed)
		end
		
		if current_elapsed >= (total_elapsed - (total_elapsed * 0.20)) then --the last 20%
			PlaySound(Audio_Folder:WaitForChild("Final"))
		end
	end)
	
	Connections.Modifier = workspace:GetAttributeChangedSignal("Endgame_Modifier"):Connect(function()
		if workspace:GetAttribute("Endgame_Modifier") == "Slow" then
			PlaySound(Audio_Folder:WaitForChild("Slowed"))
		end
	end)
end

return Endgame