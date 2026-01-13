local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Modules = {
	Data = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'));
	Code = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'));
	Perk = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Fearless'))
}

local remote = {
	Debounces = {}
}

local function GrabRemote()

	for _,r in pairs(RemoteStorage:GetChildren())do

		if string.lower(r.Name) == string.lower(script.Name) then
			return r
		end
	end

	return false
end

function remote.new()
	local self = {}
	setmetatable(self, remote)

	local connection = GrabRemote()

	if connection then

		connection.OnServerEvent:Connect(function(Player)
			local Character = Player.Character
			local Scripts = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
			local playerValues = Scripts:WaitForChild('values')
			local Knife = Character:FindFirstChild('Bone_Knife')
			
			playerValues.Action.Value = 'Stabbing'

			if not remote.Debounces[Player] then
				remote.Debounces[Player] = 0
			end

			if (Knife) and (workspace:GetServerTimeNow() - remote.Debounces[Player]) > 0.5 then
				local Killer, Got_Stun = Modules.Code:getKiller(), false
				
				remote.Debounces[Player] = workspace:GetServerTimeNow()
				
				local Track = Player.Character:WaitForChild('Humanoid'):LoadAnimation(script:WaitForChild('Animation'))
				Track:Play()

				local function StunKiller(Curr_Killer)
					local stun = Curr_Killer:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Stunned')
					local IFrame, AFrame = Modules.Code:GetEffect("IFrame", Curr_Killer), Modules.Code:GetEffect("AFrame", Curr_Killer)

					if (Curr_Killer.Character:GetPivot().Position - Player.Character:GetPivot().Position).Magnitude >= 10 then
						return warn('Too far')
					end

					if not stun.Value
						and (not AFrame or (AFrame and not AFrame.Active))
						and (not IFrame or (IFrame and not IFrame.Active)) then -- No IFrame then
						Got_Stun = true
						
						Modules.Code:Stun_Killer(Curr_Killer, 'Knife')
						
						Modules.Data:GiveBlood(Player, 500, 'Boldness', 'KILLER STAB')
					end
				end

				if Killer then
					
					if typeof(Killer) == "table" then
						
						for _, killer_player in pairs(Killer) do
							StunKiller(killer_player)
						end
					else
						StunKiller(Killer)
					end
				end
				
				if Got_Stun then
					Knife:Remove() -- remove the knife
				end
				
				Track.Stopped:Wait()

				task.wait(0.5)
			end

			playerValues.Action.Value = 'Nothing'
		end)
	elseif script.Name ~= "Template" then
		warn('Remote does not exist:', script.Name)
	end

	return self
end

return remote.new()
