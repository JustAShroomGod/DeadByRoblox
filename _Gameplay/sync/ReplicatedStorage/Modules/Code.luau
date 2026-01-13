local TweenService, ReplicatedStorage, Players, RunService, Teams, Physics = game:GetService('TweenService'), game:GetService('ReplicatedStorage'), game:GetService('Players'), game:GetService('RunService'), game:GetService('Teams'), game:GetService('PhysicsService')
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local Player = nil
local PreCloak = {}
local OldTransparency = {}

-- pro-tip: (CTRL + SHIFT + E) to collapse all trees - cheeta

--[[ For writing shorthand code for me - cheeta
Basically a long snippet of code that works for both server and client

========
SNIPPET EXAMPLE
Command | S = for Server use, C = for Client use, S|C = for both | Explanation
========
SNIPPETS
-
Module:IsExhausted() = S|C = "Returns if Exhausted"
Module:Exhaust() = S = "Makes Player Exhausted"
Module:Spectate() = S = "Sends Player to Spectator Team and remove Character"

Module:IsObsession() = S|C = "Returns if player is obession using most up-to-date method to check"
Module:IsDead() = S|C = "Returns if player is dead using most up-to-date method to check"
Module:IsDown() = S|C = "Returns if player is down using most up-to-date method to check"
Module:IsHooked() = S|C = "Returns if player is hooked using most up-to-date method to check"

Module:GetSpeed() = S|C = "Returns Speed for Killer"

Module:AddNotification() = S|C = "Creates notification alert"
]]

local Code = {
	Speeds = require(script.Speeds);
	BaseValues = require(script.Parent.BaseValues);
	Notification_Module = require(script.Notification);
	Status_Module = require(script["Status-Handler"]);
}

Code.Status_Module:SetCodeModule(Code)


local data_module = require(script.Parent:WaitForChild("Data"));

function Code:GetMatchPlayer(Player: Player | String)

	if Players:FindFirstChild(tostring(Player)) then
		return Players:WaitForChild(tostring(Player))
	end

	return -- Player not found
end

function Code:SetPlayerValue(Player, Attribute, Value)
	Code:GetMatchPlayer(Player)["PlayerValues"]:SetAttribute(Attribute, Value)
end

function Code:GetPlayerValue(Player, Attribute)
	return Code:GetMatchPlayer(Player)["PlayerValues"]:GetAttribute(Attribute)
end

function Code:InChase(Player)
	return Player.Character:GetAttribute("Chased")
end

function Code:GetEffects(Player : Player) : "Return all status effects"

	if RunService:IsServer() and Player then
		return Code.Status_Module:GetAll(Player.Character)
	elseif RunService:IsClient() then
		if not Player then Player = game.Players.LocalPlayer end
		
		return Code.Status_Module:GetAll(Player.Character)
	else
		return error("FAILED TO GRAB CHARACTER STATUS EFFECTS : No Player Given")
	end
end

function Code:GetEffect(Effect : string, Player : Player) : "Return all status effects"

	if RunService:IsServer() and Player then
		return Code.Status_Module:Get(Player.Character, Effect)
	elseif RunService:IsClient() then
		if not Player then Player = game.Players.LocalPlayer end

		return Code.Status_Module:Get(Player.Character, Effect)
	else
		return error("FAILED TO GRAB CHARACTER STATUS EFFECTS : No Player Given")
	end
end

function Code:SetEffect(Effect : string, Player : Player, Value : any, Custom : string | "Custom Name for Effect Branch/Stacks") : "Set the Effect"
	
	if RunService:IsServer() and Player then
		Code.Status_Module:Set(Player.Character, Effect, Value, Custom)
	else
		error('not available to set effect')
	end
end

function Code:IsExhausted(Player : Player) : "Returns if Exhausted"
	
	local function Exhausted(Character : Model) : boolean
		local exhaustion = Character:GetAttribute("Exhaustion")

		if exhaustion then
			exhaustion = string.split(exhaustion, ':')

			if tonumber(exhaustion[1]) > 0 then -- we have exhaustion
				return true
			end
		end
		
		return false
	end
	
	if RunService:IsServer() and Player then
		return Exhausted(Player.Character)
	elseif RunService:IsClient() then
		return Exhausted(game.Players.LocalPlayer.Character)
	else
		return error("FAILED TO GRAB CHARACTER EXHAUSTED VALUE : No Player Given")
	end
end

function Code:Exhaust(Player : Player, Exhaustion_Time : number) : "Makes player exhausted for this period of time in this amount / will over-write not add"
	
	if RunService:IsClient() then
		return error("Is not a client event!")
	elseif RunService:IsServer() and Player then
		local Character = Player.Character
		
		if Code:IsExhausted(Player) then
			Character:SetAttribute("Exhaustion", nil) -- reset real quick
		end
		
		Character:SetAttribute("Exhaustion", Exhaustion_Time..':'..Exhaustion_Time) -- set new exhaustion
	else
		return error("FAILED TO MAKE PLAYER EXHAUSTED : No Player given")
	end
end

function Code:Spectate(Player : Player) : "Make player a spectator"
	
	if RunService:IsClient() then
		return error("Is not a client event!")
	else
		data_module:SetProMMK(Player, 'Unlock')
		data_module:GiveRank(Player, Player.Team.Name)
		data_module:GivePassProgress(Player)
		
		if Player.Character then Player.Character:Remove() end
		Player.Team = Teams.Spectator
	end
end

function Code:IsDead(Player : Player) : boolean | "Returns if dead or not"
	
	local function Dead(player : Player | Model) : boolean
		local Tag = game.ReplicatedStorage:WaitForChild('Match'):WaitForChild('Players'):FindFirstChild(player.Name)

		if Tag then
			return Tag:GetAttribute("Dead")
		end

		return true
	end
	
	if RunService:IsClient() then
		if not Player then Player = game.Players.LocalPlayer end
		return Dead(Player)
	elseif RunService:IsServer() and Player then
		return Dead(Player)
	else
		return error("Need a player to use IsDead()!")
	end
end

function Code:IsDown(Player : Player) : boolean | "Returns if dead or not"

	if RunService:IsClient() then

		if Player then
			local Health = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState')

			return (Health.Value <= 0)
		else -- No Player we are checking ourself
			local Health = game.Players.LocalPlayer:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState')

			return (Health.Value <= 0)
		end
	elseif RunService:IsServer() and Player then
		local Health = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState')
		
		return (Health.Value <= 0)
	else
		return error("Need a player to use IsDown()!")
	end
end

function Code:IsInjured(Player : Player | "Any") : boolean | number

	local function ReturnInjuredResult(player : Player)
		local Health = player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState')
		local IsHooked : boolean = Code:IsHooked(player)
		
		
		return (not IsHooked and (Health.Value == 1)) -- only injured
	end

	if RunService:IsClient() then
		if not Player then Player = game.Players.LocalPlayer end

		if Player == "Any" then -- get amount of injured survivors
			local Count = 0
			
			for _, Survivor in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do

				if ReturnInjuredResult(Survivor) then
					Count += 1 -- add to injured amount
				end
			end

			return Count
		else -- actual player
			return ReturnInjuredResult(Player)
		end
	elseif RunService:IsServer() and Player then

		if Player == "Any" then -- get amount of injured survivors
			local Count = 0
			
			for _, Survivor in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do

				if ReturnInjuredResult(Survivor) then
					Count += 1 -- add to injured amount
				end
			end

			return Count
		else -- actual player
			return ReturnInjuredResult(Player)
		end
	else
		return error("Need a player to use IsInjured()!")
	end
end

function Code:IsCarried(Player: Player)
	local Held = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Holded')
	return Held.Value
end

function Code:SetHealthState(Player: Player, Value: number)
	if (RunService:IsServer() and Player) then
		local HealthState = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState')
		HealthState.Value = math.clamp(Value, 0, 2)
	end
end

function Code:GetHealthState(Player: Player)
	local HealthState = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState')
	return HealthState.Value
end

function Code:SetHealProgress(Player: Player, Value: number)
	if (RunService:IsServer() and Player) then
		local HealProgress = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealProgress')
		HealProgress.Value = math.clamp(Value, 0, 1000)
	end
end

function Code:GetHealProgress(Player: Player)
	local HealProgress = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealProgress')
	return HealProgress.Value
end

function Code:GetKillerAction(Player: Player)
	local KillerAction = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('KillerAction')
	return KillerAction.Value
end

function Code:SetKillerAction(Player: Player, NewAction: string)
	
	if (not RunService:IsServer()) then
		return
	end
	
	local KillerAction = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('KillerAction')
	KillerAction.Value = NewAction
end

function Code:GetSurvivorAction(Player: Player)
	local Action = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action')
	return Action.Value
end

function Code:SetSurvivorAction(Player: Player, NewAction: string)
	
	if (not RunService:IsServer()) then
		return
	end
	
	local Action = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action')
	Action.Value = NewAction
end

function Code:IsHooked(Player : Player | "Any") : boolean | "Returns if any player is hooked or not"
	
	local function ReturnHookResult(player : Player)
		local Hooked_Value = player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Hooked')

		return Hooked_Value.Value
	end
	
	if RunService:IsClient() then
		if not Player then Player = game.Players.LocalPlayer end
		
		if Player == "Any" then -- return if any player is hooked

			for _, Survivor in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do

				if ReturnHookResult(Survivor) then
					return true
				end
			end

			return false
		else -- actual player
			return ReturnHookResult(Player)
		end
	elseif RunService:IsServer() and Player then
		
		if Player == "Any" then -- return if any player is hooked
			
			for _, Survivor in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do
				
				if ReturnHookResult(Survivor) then
					return true
				end
			end
			
			return false
		else -- actual player
			return ReturnHookResult(Player)
		end
	else
		return error("Need a player to use IsDead()!")
	end
end

function Code:isCarried(Player : Player | "Any") : boolean | "Returns if any player is carried or not"

	local function ReturnHoldResult(player : Player)
		local Holded_Value = player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Holded')

		return Holded_Value.Value
	end

	if RunService:IsClient() then
		if not Player then Player = game.Players.LocalPlayer end

		if Player == "Any" then -- return if any player is hooked

			for _, Survivor in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do

				if ReturnHoldResult(Survivor) then
					return true
				end
			end

			return false
		else -- actual player
			return ReturnHoldResult(Player)
		end
	elseif RunService:IsServer() and Player then

		if Player == "Any" then -- return if any player is hooked

			for _, Survivor in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do

				if ReturnHoldResult(Survivor) then
					return true
				end
			end

			return false
		else -- actual player
			return ReturnHoldResult(Player)
		end
	else
		return error("Need a player to use IsDead()!")
	end
end

function Code:IsObsession(Player : Player) : "Returns if obsession or not"

	local function ReturnResult(player : Player)
		local Player_String = ReplicatedStorage:WaitForChild('Match'):WaitForChild('Players'):FindFirstChild(player.Name)
		
		if Player_String and Player_String:GetAttribute("Obsession") then
			return true
		end
		
		return false
	end

	if RunService:IsClient() then
		if not Player then Player = game.Players.LocalPlayer end
		return ReturnResult(Player)
	elseif RunService:IsServer() and Player then
		return ReturnResult(Player)
	else
		return error("Need a player to use IsDead()!")
	end
end

function Code:ReturnObsession() : "Returns the obsession"
	local Obsession = false
	
	for _,Player in pairs(ReplicatedStorage:WaitForChild('Match'):WaitForChild('Players'):GetChildren()) do
		if not Player:GetAttribute("Obsession") then
			continue
		end
		
		if not (Player:GetAttribute("Team") == "Survivor") then
			continue
		end
		
		Obsession = Players[Player.Name]
		break
	end

	return Obsession
end

function Code:GetSpeed(Movement : "Movement" | "Carry" | "Rage" | "Fatigue" | "Chainsaw" | "Aiming" | "Stalking" | "Charge" | "PostBlink" , Player : Player) : number | "Return Proper Killer Speed"
	
	if RunService:IsClient() then
		return Code.Speeds:Get(game.Players.LocalPlayer, Movement)
	elseif RunService:IsServer() and Player then
		return Code.Speeds:Get(Player, Movement)
	else
		return error("Need a player to pull speed for!")
	end
end

function Code:AddDeath(Player : Player) : "Add a Kill to all Killers in this Match!"
	if Player.Team ~= Teams:WaitForChild('Survivor') then return end -- not a survivor
	if RunService:IsClient() then return error("Only for server!") end

	-- Send to Spectate --
	Code:Spectate(Player) -- send to spectator team

	local data_module = require(script.Parent:WaitForChild('Data'))
	local BadgeManager = require(game:GetService('ServerStorage'):FindFirstChild("Modules"):FindFirstChild("BadgeManager"))
	
	local function EndgameKill()
		if not workspace:GetAttribute("Endgame") then return false end
		
		local collapse_info = string.split(workspace:GetAttribute("Endgame"), ':')
		local current_elapsed, total_elapsed = collapse_info[1], collapse_info[2]
		
		if tonumber(current_elapsed) >= tonumber(total_elapsed) then
			return true
		else
			return false
		end
	end
	
	for _, Killer : Player in pairs(game:GetService('Teams'):WaitForChild('Killer'):GetPlayers()) do

		data_module:AddKill(Killer)
		
		task.spawn(function()
			if EndgameKill() then
				BadgeManager.Award("Trickster", Killer.UserId)
			end
		end)
	end
	
	--data_module:GiveRank(Player, "Killer")
	-- Kill Them --
	Player:SetAttribute("Dead", true)
	ReplicatedStorage:WaitForChild('Match'):WaitForChild('Players'):WaitForChild(Player.Name):SetAttribute("Dead", true)
end

function Code:AddEscape(Player : Player) : "Add A Escape to the this Player"
	if RunService:IsClient() then return error("Only for server!") end
	if not Player then return error("No Player Given!") end
	
	local data_module = require(script.Parent:WaitForChild('Data'))

	-- Send to Spectate --
	Code:Spectate(Player) -- send to spectator team
	data_module:AddEscape(Player)
	--data_module:GiveRank(Player, "Survivor")
end

function Code:SetCollision(Player : Player, Group : "Survivor" | "Killer" | 'Crouch' | 'Downed' | 'Locker' | "Carry") : 'Change Collision Group'
	if not Player.Character then return warn('No Character') end
	
	for _, Descendant in pairs(Player.Character:GetDescendants()) do
		
		if Descendant:IsA('BasePart') then
			
			if (Descendant.Name == "BodyParticleEmitter" or Descendant.Name == "TrailParticleEmitter") then
				continue
			end
			
			Descendant.CollisionGroup = Group
		end
	end
end

function Code:AddNotification(DesiredCFrame : CFrame, Length : NumberValue, Type : StringValue, DesiredPlayer : Player) : "Create A Notification"
	local Event = RemoteEvents:WaitForChild("Notification")
	
	if RunService:IsClient() then
		if not DesiredPlayer then
			Code.Notification_Module.New(DesiredCFrame, Length, Type)
		end
	elseif RunService:IsServer() then
		
		if not DesiredPlayer then --its global
			Event:FireAllClients(DesiredCFrame, Length, Type)
		else
			Event:FireClient(DesiredPlayer, DesiredCFrame, Length, Type)
		end
	end
end

function Code:getKiller() : table | "Returns the Killer of the Match"
	local Killers = game.Teams:WaitForChild('Killer'):GetPlayers()
	
	if #Killers == 1 then
		return Killers[1]
	elseif #Killers > 1 then
		return Killers
	end
	
	return nil
end

function Code:isKiller(Player : Player) : "| Returns if Killer or not"
	if Player.Team == game:GetService("Teams").Killer  then
		return true
	else
		return false
	end
end

function Code:Stun_Killer(Killer : Player, Type : string, Dropper: Player) : "Stun Killer Universal Code"
	local Stun = Killer:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Stunned')
	local Stunner = Stun:WaitForChild("Stunner")
	local Kind = Stun:WaitForChild('Kind')
	
	Stunner.Value = if (Dropper) then Dropper.Name else ""
	Kind.Value = Type
	Stun.Value = true
	
end

function Code:Stun_Survivor(Survivor : Player, Duration: number) : "Stun Survivor Universal Code"
	if (RunService:IsServer()) then
		RemoteEvents:WaitForChild("StunRemote"):FireClient(Survivor, Duration)
	end	
end

function Code:Skillcheck_Modifier(Modification : "Speed" | "Direction", Amount, Skill_Type : "Generator" | "Healing" , Player : Player)
	
	if RunService:IsServer() then
		local Skill_Command = nil
		
		if Modification == "Speed" then
			Skill_Command = "Speed"
		elseif Modification == "Direction" then
			Skill_Command = "Direction"
		end
		
		if not Skill_Command then return warn(Modification, 'invalid') end
		
		if Player then
			RemoteEvents:WaitForChild('SendSkillCheck'):FireClient(Player, Skill_Type, Skill_Command, Amount)
		else
			RemoteEvents:WaitForChild('SendSkillCheck'):FireAllClients(Skill_Type, Skill_Command, Amount)
		end
	else
		warn('Client should not be accessing this')
	end
end

function Code:IsBlessing(Totem : Instance) : 'Return list of blessing or nothing'
	
	if game.Players:FindFirstChild(Totem:WaitForChild('Panel'):WaitForChild('Effect'):WaitForChild('Holder').Value) then
		local Blessings = data_module:GetBlessings(game.Players:FindFirstChild(Totem:WaitForChild('Panel'):WaitForChild('Effect'):WaitForChild('Holder').Value))
		
		if (#Blessings == 0) then
			return false
		else
			return Blessings
		end
	end
	
	return false
end

function Code:Cloak_Survivor(Player: Player, TargetTransparency: number)

	local Character = Player.Character
	local RootPart = Character.PrimaryPart
	local RigStorage = workspace.RigStorage:FindFirstChild(Character.Name)

	OldTransparency[Player.Name] = {}
	OldTransparency[Player.Name.."_Rig"] = {}

	-- Normal Parts

	for i, v: Part in pairs(Character:GetDescendants()) do
		if ((v:IsA("MeshPart") or v:IsA("Part")) and v ~= RootPart) then
			PreCloak[v.Name] = v.Color
			local colorTween = game:GetService("TweenService"):Create(v, TweenInfo.new(1), {Color = Color3.new(0.5, 0.5, 0.5)})
			colorTween:Play()
		end
	end

	task.wait(0.2)

	for i, v: Part in pairs(Character:GetDescendants()) do
		if ((v:IsA("MeshPart") or v:IsA("Part")) and v ~= RootPart) then
			if (v.Transparency >= 1) then
				continue 
			end

			v.Material = Enum.Material.ForceField
			OldTransparency[Player.Name][v.Name] = v.Transparency
			local transparencyTween = game:GetService("TweenService"):Create(v, TweenInfo.new(2), {Transparency = TargetTransparency})
			transparencyTween:Play()
		end
	end

	-- Accessories

	for i, v: Part in pairs(Character:GetDescendants()) do
		if ((v:IsA("Accessory")) and v ~= RootPart) then
			PreCloak[v.Name] = v.Handle.Color	

			local colorTween = game:GetService("TweenService"):Create(v.Handle, TweenInfo.new(1), {Color = Color3.new(0.5, 0.5, 0.5)})
			colorTween:Play()
		end
	end

	task.wait(0.2)

	for i, v: Part in pairs(Character:GetDescendants()) do
		if ((v:IsA("Accessory")) and v ~= RootPart) then
			if (v.Handle.Transparency >= 1) then continue end
			OldTransparency[Player.Name][v.Name] = v.Handle.Transparency

			local transparencyTween = game:GetService("TweenService"):Create(v.Handle, TweenInfo.new(2), {Transparency = TargetTransparency})
			transparencyTween:Play()
		end
	end

	-- Decals

	for i, v: Part in pairs(Character:GetDescendants()) do
		if (v:IsA("Decal")) then
			OldTransparency[Player.Name][v.Name] = v.Transparency
			v.Transparency  = 1
		end
	end

	task.wait(0.2)

	if (RigStorage ~= nil) then
		for i, v: Part in pairs(RigStorage:GetDescendants()) do
			if (v:IsA("Decal")) then
				OldTransparency[Player.Name.."_Rig"][v.Name] = v.Transparency
				v.Transparency  = 1
			end
		end
	end

end

function Code:Uncloak_Survivor(Player: Player)

	local Character = Player.Character
	local RootPart = Character.PrimaryPart
	local RigStorage = workspace.RigStorage:FindFirstChild(Character.Name)

	for i, v: Part in pairs(Character:GetDescendants()) do
		if ((v:IsA("MeshPart") or v:IsA("Part")) and v ~= RootPart) then
			if (OldTransparency[Player.Name][v.Name] == nil) then continue end

			local transparencyTween = game:GetService("TweenService"):Create(v, TweenInfo.new(1), {Transparency = OldTransparency[Player.Name][v.Name]})
			transparencyTween:Play()

			if not v.Parent:IsA("Accessory") then
				transparencyTween.Completed:Once(function()
					local colorTween = game:GetService("TweenService"):Create(v, TweenInfo.new(1), {Color = PreCloak[v.Name]})
					colorTween:Play()
					v.Material = Enum.Material.Plastic
				end)
			end
		end

		if (v:IsA("Accessory") and v ~= RootPart) then
			if (OldTransparency[Player.Name][v.Name] == nil) then continue end

			local transparencyTween = game:GetService("TweenService"):Create(v.Handle, TweenInfo.new(1), {Transparency = OldTransparency[Player.Name][v.Name]})
			transparencyTween:Play()

			transparencyTween.Completed:Once(function()	
				local colorTween = game:GetService("TweenService"):Create(v.Handle, TweenInfo.new(1), {Color = PreCloak[v.Name]})

				colorTween:Play()
				v.Handle.Material = Enum.Material.Plastic
			end)
		end

		if (v:IsA("Decal")) then
			local transparencyTween = game:GetService("TweenService"):Create(v, TweenInfo.new(1), {Transparency = OldTransparency[Player.Name][v.Name]})
			transparencyTween:Play()
		end
	end

	for i, v: Part in pairs(Character:GetDescendants()) do
		if (v:IsA("Decal")) then
			v.Transparency  = OldTransparency[Player.Name][v.Name]
		end
	end

	if (RigStorage ~= nil) then
		for i, v: Part in pairs(RigStorage:GetDescendants()) do
			if (v:IsA("Decal")) then
				v.Transparency  = OldTransparency[Player.Name.."_Rig"][v.Name]
			end
		end
	end

end

function Code:Remote_Sound(Player : Player, Sound : string) : 'Remote Sound from Player -> Others or Server - > Players'
	
	
	if RunService:IsServer() and Player then
		
		for att, v in pairs(Player.Character:GetAttributes()) do -- clear old sounds
			
			if string.match(att, 'Sound_') then
				Player.Character:SetAttribute(att, nil)
			end
		end
		
		Player.Character:SetAttribute("Sound_"..Sound, true) -- activate sound
	end
end

function Code:World_Sound(Sound : string, Object : Model) : "Play a world-audio to all clients"
	
	if RunService:IsServer() then
		RemoteEvents:WaitForChild('Server_Sound'):FireAllClients(Sound, Object)
	end
end

function Code:AllEscaped(Player_Local : Player)
	local Count = 0
	
	for _, Survivor in pairs(ReplicatedStorage:WaitForChild('Match'):WaitForChild('Players'):GetChildren()) do
		if Survivor.Name ~= Player_Local.Name then continue end
		
		if Survivor:GetAttribute("Escaped") then
			Count += 1
		end
	end
	
	return if Count >= 3 then true else false
end

function Code:Test(...)
	local args = {...}
	
	--Code:Skillcheck_Modifier("Speed", 5, "Generator")
	
	--Code:SetEffect("Flashed", args[1], args[2])
	
	--Code:AddNotification(CFrame.new(), 5, "Hatch")
end

return Code
