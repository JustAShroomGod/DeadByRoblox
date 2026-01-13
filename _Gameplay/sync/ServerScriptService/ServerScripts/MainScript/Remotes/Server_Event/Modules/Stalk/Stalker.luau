local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local PlayerService = game:GetService('Players')
local Cando = false
local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local Addons = require(script.Parent:WaitForChild('Addon'))
local exposed_animation = script.Parent.Parent.Parent:WaitForChild('Animations'):WaitForChild('Stalker_Walk')

local Stalker = {
	Settings = {
		Stalk = {
			Modifiers = {1.2, 1, 0.35};
			MaxRange = 150;
			Accuracy = 0.6;
			Speed = 2.8;
			Drain = 1;
		},
		AnimationSpeeds = {
			Default = 1; -- 2 second animation = 1.5 second cloak time
		},
	},
	Ignorelist = {},
	Characters = {},
}


local Param = RaycastParams.new()
Param.FilterDescendantsInstances = Stalker.Ignorelist
Param.FilterType = Enum.RaycastFilterType.Exclude

-- Adding Sound Effects --
function PlaySound(id : number, volume : number, pitch : number) : "Play Sound"

end

function GenerateData(Character : Model) : "Create Tweening Data"
	if Stalker.Characters[Character.Name] then return end

	Stalker.Characters[Character.Name] = {} -- create character/tween data for this character

	Stalker.Characters[Character.Name].State = "Nothing"

	Stalker.Characters[Character.Name].AnimationTrack = Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(exposed_animation)
end

--

function Stalker:Stalk(Character) : "Does Stalk"
	if not Stalker.Characters[Character.Name] then GenerateData(Character) end
	local Player = PlayerService:GetPlayerFromCharacter(Character)

	Stalker.Characters[Character.Name].State = "Stalking"

	code_module:SetEffect("Slow", Player, {-1, 80}, "Power_Stalk")

	coroutine.wrap(function()
		Player.Character:SetAttribute("Power_State", "Stalking") -- stalk mode

		--[[Stalker.Characters[Character.Name].StalkLoop = game:GetService('RunService').Heartbeat:Connect(function(step)
			Character.Humanoid.WalkSpeed = code_module:GetSpeed("Stalking", Player)
			
			if tonumber(Progress.Value) < 100 then
				
				for _, Survivor : Player in pairs(game:GetService('Teams'):WaitForChild('Survivor'):GetPlayers()) do
					if tonumber(Progress.Value) >= 100 then break end
					if code_module:IsDown(Survivor) or code_module:IsHooked(Survivor) then continue end
					
					local Direction = (Survivor.Character:GetPivot().Position - Character:WaitForChild('Head').Position).Unit
					local Dot = Direction:Dot(Character:WaitForChild('Head').CFrame.LookVector)
					local Distance = (Survivor.Character:GetPivot().Position - Character:GetPivot().Position).Magnitude

					if Dot > Stalker.Settings.Stalk.Accuracy and Distance <= Stalker.Settings.Stalk.MaxRange then
						local Range_Bracket = math.clamp(math.floor(Distance/40 + 1), 1, 3)
						local CanSee = Cast(Character, Survivor.Character)
						local Modifier = step * Stalker.Settings.Stalk.Modifiers[Range_Bracket]

						if Evil.Value <= 1 then
							Modifier *= 1.8
						end

						if CanSee then
							Progress.Value = math.clamp(tonumber(Progress.Value) + (Stalker.Characters[Character.Name].StalkSpeed * Modifier), 0, 100)

							if tonumber(Progress.Value) >= 100 then
								Evil.Value = math.clamp(Evil.Value + 1, 1, 3)

								if Evil.Value <= 2 then
									PlaySound(4307069862, 1, .5)
									Progress.Value = 0
								end
								
								data_module:GiveBlood(Player, 500, "Deviousness", "STALK")
							end
						end
					end
				end
			end
		end)]]--

		repeat task.wait()
		until Stalker.Characters[Character.Name].State == "Cancel" -- or we go over evil within 3

		--if Stalker.Characters[Character.Name].StalkLoop then Stalker.Characters[Character.Name].StalkLoop:Disconnect() Stalker.Characters[Character.Name].StalkLoop = nil end

		code_module:SetEffect("Slow", Player, nil, "Power_Stalk")

		Stalker.Characters[Character.Name].Power_Tier_Up = Character:GetAttributeChangedSignal("Power_Tier"):Connect(function()
			PlaySound(4307069862, .5, 1)
		end)
		if Player.Character:GetAttribute("Power_Tier") == 1 then
			code_module:SetEffect("Hidden", Player, -1, "Power_Tier")
		end

		if Player.Character:GetAttribute("Power_Tier") == 2 then
			code_module:SetEffect("Hidden", Player, nil, "Power_Tier")
		end

		if Player.Character:GetAttribute("Power_Tier") >= 3 then
			PlaySound(4307069862, .5, 1)

			for i, survivor in pairs(game.Teams.Survivor:GetPlayers()) do
				code_module:SetEffect("Exposed", survivor, -1, "Stalker")
			end

			Stalker.Characters[Character.Name].AnimationTrack:Play()
			Player.Character:SetAttribute("Power_State", "Draining") -- stalk mode

			Stalker.Characters[Character.Name].DrainLoop = Character:GetAttributeChangedSignal("Power_Tier"):Connect(function()

				if Character:GetAttribute("Power_Tier") < 3 then
					for i, survivor in pairs(game.Teams.Survivor:GetPlayers()) do
						code_module:SetEffect("Exposed", survivor, nil, "Stalker")
					end
					--PlaySound(4307069862, .8, .8)
					Stalker.Characters[Character.Name].AnimationTrack:Stop()
					if Stalker.Characters[Character.Name].DrainLoop then Stalker.Characters[Character.Name].DrainLoop:Disconnect() Stalker.Characters[Character.Name].DrainLoop = nil end
				end
			end)
		else
			Player.Character:SetAttribute("Power_State", "Idle") -- idle mode
		end

		Stalker.Characters[Character.Name].State = "Nothing"
	end)()

	return -- nothing to return
end

function Stalker:Stop(Character)
	if not Stalker.Characters[Character.Name] then
		repeat task.wait()
		until Stalker.Characters[Character.Name]
	end

	if Stalker.Characters[Character.Name].Power_Tier_Up then
		Stalker.Characters[Character.Name].Power_Tier_Up:Disconnect() 
		Stalker.Characters[Character.Name].Power_Tier_Up = nil
	end 

	if Stalker.Characters[Character.Name].State ~= "Stalking" then return end

	Stalker.Characters[Character.Name].State = "Cancel"
end

return Stalker