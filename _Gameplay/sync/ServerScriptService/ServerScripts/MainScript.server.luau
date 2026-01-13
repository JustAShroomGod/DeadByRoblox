local playerService, replicatedStorage, serverScriptService, serverStorage, memorystore, teleportService, httpService, messageService, analyticsService = game:GetService('Players'), game:GetService('ReplicatedStorage'), game:GetService('ServerScriptService'), game:GetService('ServerStorage'), game:GetService('MemoryStoreService'), game:GetService('TeleportService'), game:GetService('HttpService'), game:GetService('MessagingService'), game:GetService("AnalyticsService")
local Game_Data = replicatedStorage.Game_Data

local serverModules = serverStorage.Modules
local DataManager = require(replicatedStorage.Modules.Data)

local killerCharacters = serverStorage.CharactersStuff.Killer
local RemoteHandler = require(script.Remotes)
local MatchMaking = require(script.MatchMaking)

local AutoStart, AutoStartTime = nil, 20

local BUG_READ = replicatedStorage.RemoteEvents.BUGREAD

local Modules = {
	Attributes = require(serverModules.AttributeHandler);
	Collision = require(serverModules.CollisionHandler);
	Map = require(serverModules.MapHandler);
	Match = require(serverModules.MatchReader);
	Killer_Objects = require(serverModules.Killer_Interactables);
	Character_Handler = require(serverModules.Character);
	Ping = require(replicatedStorage.Modules.Ping);
	Code = require(replicatedStorage.Modules.Code);
	BaseValues = require(replicatedStorage.Modules.BaseValues);
	ResourceComponent = require(replicatedStorage.Modules.PlayerValues.ResourceComponent);
}

_G.ValueTable = {}
_G.ObjectValues = {}

----
local OurMap, ServerLoaded = nil, nil

----- Player Joining|Leaving

messageService:SubscribeAsync("Reservations", function(tbl)
	local Data = httpService:JSONDecode(tbl.Data)
	if Data.LobbyId ~= MatchMaking.Server.Host.ID then return end -- isn't talking to us
	
	MatchMaking:QUEUE(Data)
end)

playerService.PlayerRemoving:Connect(function(Player : Player)
	Modules.Code.Speeds:removeUser(Player)
	Modules.Match:Update()
	
	if not MatchMaking.Server.Host.HOSTED or ServerLoaded then return end
	MatchMaking:Leave(Player)
end)

---- Character Set up


function SetSurvivor(Player : Player) : "Sets up survivor"
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local playerData = DataManager:GetRaw(Player, 'Survivor')
--warn(playerData)
	Modules.Character_Handler:LoadAppearence(Player, "Survivor", playerData)

	Modules.Character_Handler:GiveItem(Player)

	Player.CameraMode = Enum.CameraMode.Classic
	CreateValues(Player, "Survivor")
	
	Modules.Match:ConnectPlayer(Player, 'Survivor')
	Modules.Attributes:setupAttributes(Modules.Match:Search(Player), "Survivor")
	Modules.Code.Speeds:addUser(Player)
	Modules.Code:SetPlayerValue(Player, "DefaultSpeed", Modules.Code.Speeds.Survivor.Walking)
	_G.GetValue(Player, "Speed"):Add("Default", Modules.Code.Speeds.Survivor.Walking, -1)
	_G.GetValue(Player, "SpeedMultiplier"):Add("ReduceDefault", -0.5, -1)
	

	Modules.Character_Handler:Spawn(Character, "Survivor")
	initializePerks(Player, "Survivor")

	-- attach base attributes --
	local hasSalvation, SalvationTier = DataManager:GetPerk("SlipperyMeat", Player)
	local hasMither, _ = DataManager:GetPerk("NoMither", Player)
	
	if hasMither then
		Modules.Code:SetEffect("Broken", Player, -1) -- perm broken
		Modules.Code:SetEffect("Quiet", Player, {-1, 100}, "NoMither")
		Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState').Value = 1 -- injure
	end
	
	local base_bleed = if hasSalvation then (1000 * (require(Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('SlipperyMeat')).Tiers[SalvationTier]/100)) + 1000 else 1000
	local base_hook = if hasSalvation then (1000 * (require(Game_Data:WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('SlipperyMeat')).Tiers[SalvationTier]/100)) + 1000 else 1000
	
	Character:SetAttribute("Hysteria", 0)
	Character:SetAttribute("Blood", base_bleed..":"..base_bleed) -- w/ survivalist we will just increase max capacity
	Character:SetAttribute("Hook_Blood", base_hook..":"..base_hook) -- w/ survivalist we will just increase max capacity
	Character:SetAttribute("Hook_Stage", "0:2") -- w/ survivalist we will just increase max capacity
	
	game.PhysicsService:CollisionGroupSetCollidable("Killer", "Survivor", false)
	Modules.Code:SetCollision(Player, 'Survivor')

	if MatchMaking.Server.Pro_Only then
		-->> PRO MMK Reset Timer << --
		DataManager:SetProMMK(Player, 'Lock')
	end
	
	Player:SetAttribute("FINISHED", true)
	
	DataManager:Consume("Survivor", Player)
end

function SetKiller(Player : Player)
	local playerData = DataManager:GetRaw(Player, 'Killer')
	local Killer_Character = DataManager:GetCharacter(Player):gsub("^%l", string.upper)

	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Scripts = Player:WaitForChild("Backpack"):WaitForChild('Scripts')
	local Values = Scripts:WaitForChild('values')

	Modules.Match:ConnectPlayer(Player, 'Killer')
	Modules.Attributes:setupAttributes(Modules.Match:Search(Player), "Killer")

	Scripts:WaitForChild('Killer').Value = true
	CreateValues(Player, "Killer")

	Modules.Character_Handler:LoadAppearence(Player, "Killer", playerData, Killer_Character)
	Modules.Code.Speeds:addUser(Player)
	Modules.Code:SetPlayerValue(Player, "DefaultSpeed", Modules.Code.Speeds.Global_Settings.Base_Speed)
	_G.GetValue(Player, "Speed"):Add("Default", Modules.Code.Speeds.Global_Settings.Base_Speed, -1)
	_G.GetValue(Player, "SpeedMultiplier"):Add("KillerDefault", Modules.Code.Speeds[Killer_Character].Movement, -1)

	local playerName = Instance.new("StringValue", Character)
	playerName.Name = "PlayerName"
	playerName.Value = Player.Name

	Player.CameraMode = Enum.CameraMode.LockFirstPerson

	Modules.Character_Handler:Spawn(Character, "Killer")
	initializePerks(Player, "Killer")

	if Killer_Character == "Trapper" then
		Modules.Killer_Objects:SetTraps(Player)
	else
		Modules.Killer_Objects:SetValues(Player, Killer_Character)
	end

	coroutine.wrap(function()
		repeat task.wait()
		until game.ReplicatedStorage.Match.Started.Value -- >> wait until game is started aka all players loaded and killer can move freely
		
		--print('PERKS ARE BEING SET!!!')
		
		--Modules.Killer_Objects:SetHexes(Player)
		Modules.Killer_Objects:SetPerks(Player)
	end)()
	
	if MatchMaking.Server.Pro_Only then
		-->> PRO MMK Reset Timer
		DataManager:SetProMMK(Player, 'Lock')
	end
	
	Modules.Code:SetCollision(Player, 'Killer')
	
	Player:SetAttribute("FINISHED", true)
	
	DataManager:Consume("Killer", Player)
end

function beginKiller(player : Player) : "Grabs Killer Slot"
	--BUG_READ:FireAllClients(player.Name.." LOADING AS KILLER")

	player.Team = game:GetService('Teams').Killer
	
	SetKiller(player)
end

function beginSurvivor(player : Player) : "Grabs Survivor Slot"
	--BUG_READ:FireAllClients(player.Name.." LOADING AS SURVIVOR")

	player.Team = game:GetService('Teams').Survivor

	SetSurvivor(player)
end

function beginSpectator(Player : Player) : "LOAD SPECTATOR"
	--BUG_READ:FireAllClients(Player.Name.." LOADING AS SPECTATOR")

	Player.Team = game:GetService('Teams').Spectator
	
	Player.CameraMode = Enum.CameraMode.Classic

	Player:SetAttribute("FINISHED", true) -->> remove replicated first UI
	
	local specator = game.StarterGui:WaitForChild('Post_Screen'):Clone()
	specator.Parent = Player:WaitForChild('PlayerGui')
	specator.Enabled = true
	specator:SetAttribute("GOD", true) -->> god spectate mode | can spectate anybody
end

function initializePerks(Player: Player, Side: string)
	
	task.wait(5)
	
	local Perks = DataManager:GetPerks(Side, Player)
	local Backpack = Player.Backpack
	local Scripts = Backpack.Scripts
	local PerksBase = Scripts.PerksBase
	
	for name, tier in pairs(Perks) do
		--print(name)
		if (PerksBase:FindFirstChild(name) ~= nil) then
			local Path = PerksBase:FindFirstChild(name)
			if (Path:FindFirstChild("PerkModule") ~= nil) then
				local Module = require(Path:FindFirstChild("PerkModule"))
				Module.initialize(Player, tier["Tier"])
			end
		end
	end
end

local function ServerRegion()
	local ServerIP, ServerData
	
	local Success, getIp = pcall(function()
		return httpService:GetAsync("https://ipconfig.io/json")
	end)

	if Success and getIp then
		local ipData = httpService:JSONDecode(getIp)
		ServerIP = ipData["ip"]
	end

	-- now that we have the serverip, we can parse it and get the rest of the data
	if ServerIP then
		local Success, ServerData = pcall(function()
			return httpService:GetAsync("https://ipapi.co/"..ServerIP.."/json/") 
		end)
	end

	if ServerData and ServerIP then
		ServerData = httpService:JSONDecode(ServerData)
		warn(ServerData["region"]..", "..ServerData["country_code"])
		game.ReplicatedStorage.Match.Region = tostring(ServerData["region"])
	end
end

function CreateValues(Player, Role)
	
	local baseValues = Modules.BaseValues[Role]
	
	if (Player:FindFirstChild("PlayerValues") == nil) then
		local playerValues = Instance.new("Configuration")
		playerValues.Name = "PlayerValues"
		playerValues.Parent = Player
	end
	
	_G.ValueTable[Player.Name] = {}
	
	for category, attrList in pairs(baseValues) do
		for attrName, attrValue in pairs(baseValues[category]) do
			CreateValue(Player, attrName, attrValue)
		end
	end
	
end

function CreateValue(Player, attributeName, default)
	local newResource = Modules.ResourceComponent.new(Player.PlayerValues, attributeName, default)
	_G.ValueTable[Player.Name][attributeName] = newResource
end

_G.GetValue = function(PlayerName: string, ValueName: string)
	return _G.ValueTable[tostring(PlayerName)][ValueName]
end

_G.GetObjectValue = function(ObjectName: string, ValueName: string)
	return _G.ObjectValues[ObjectName][ValueName]
end

-- Game - Requirements --
Modules.Map:Essentials() -- load workspace folders we need

RemoteHandler:Spawn() -- Spawn The Remotes --
RemoteHandler:Connect() -- Connect The Remotes

task.wait()--
--

--the reason why was this loop created is purely because we need ping more frequently
task.spawn(function()
	task.spawn(function()
		ServerRegion()
	end)
	
	while task.wait(3) do
		for _, Player : Player in pairs(playerService:GetChildren()) do
			task.spawn(function()
				local PingFinal = Modules.Ping[Player.Name] or 0
				Player:SetAttribute("PING", math.floor(PingFinal * 2000))
			end)	
		end
	end
end)

while task.wait(5) do -- revert to 6 if mmk throws errors

	-- Check if All are ready --
	local CurrentReady, KillerReady, Other = 0, 0, {
		K = 0;
		S = 0;
	}

	if not ServerLoaded then
		for _, Player : Player in pairs(playerService:GetChildren()) do
			local dataStorage = Player:WaitForChild("Data", 5)
			if not dataStorage then --[[BUG_READ:FireAllClients(Player.Name.."'s data not found")]] continue end

			local Team = Player:GetAttribute("Team")		

			if not Team then continue end

			if not Player:GetAttribute("READY") then
				if not workspace:GetAttribute("TESTING") and not workspace:GetAttribute("CUSTOM") then
					Player:SetAttribute("READY", true) 
				end
			end


			if Team == 'Killer' then
				Other.K += 1
			elseif Team == 'Survivor' then
				Other.S += 1
			end

			if Player:GetAttribute("READY") then

				if Team == 'Survivor' then
					CurrentReady += 1 -- add 1 ready to roster
				elseif Team == 'Killer' then
					KillerReady += 1 -- add 1 ready to roster
				end
			end
		end
		
		MatchMaking:PING() -- ping server information
		
		if Other.S >= 4 and Other.K >= 1 and not AutoStart and not workspace:GetAttribute("CUSTOM") then
			BUG_READ:FireAllClients("Game has began auto-start sequence!")
			AutoStart = workspace:GetServerTimeNow()
		elseif Other.S < 4 or Other.K <= 0 and AutoStart then
			AutoStart = nil
		end
		
		if CurrentReady >= 4 and KillerReady >= 1 and CurrentReady + KillerReady >= (Other.S + Other.K) -- we have a killer and combined all are ready
			or (not workspace:GetAttribute("TESTING") and AutoStart and (workspace:GetServerTimeNow() - AutoStart) >= AutoStartTime and Other.S >= 4 and Other.K >= 1) -- we have had enough people for a minute now
			or ((workspace:GetAttribute("TESTING") or workspace:GetAttribute('CUSTOM')) and CurrentReady + KillerReady >= math.clamp((Other.S + Other.K), 1, 100)) then -- if all are ready doesn't matter how many when in custom or testing mode
			
			BUG_READ:FireAllClients("Game has begun booting up!")
			
			ServerLoaded = if ServerLoaded then tonumber(ServerLoaded) else workspace:GetServerTimeNow()
			workspace:SetAttribute("SERVER_LOADED", ServerLoaded)
			
			-- Ping Details Here to close server now!
			MatchMaking.Server.Host.CLOSED = true
			coroutine.wrap(function()
				MatchMaking:PING()
			end)()
			
			-- Calculate Offerings | Spawn Map --
			local offerings = {}

			for _, Player : Player in pairs(playerService:GetChildren()) do
				local dataStorage = Player:FindFirstChild('Data')
				local Team = Player:GetAttribute("Team")
				if not dataStorage or not Team then continue end
				
				if Team == "Killer" or Team == "Survivor" then
					table.insert(offerings, DataManager:GetOffering(Team, Player))
				end
			end
			
			if workspace:GetAttribute("CUSTOM_MODE") == "TOURNAMENT" then
				offerings = {}
			end
			
			OurMap = Modules.Map:Spawn(offerings)
			--

			--BUG_READ:FireAllClients("Map Generated!")
			
			for _, Player : Player in pairs(playerService:GetChildren()) do
				local dataStorage, stored_name = Player:FindFirstChild("Data"), Player.Name
				if not dataStorage then --[[BUG_READ:FireAllClients(Player.Name.."'s data not found")]] continue end

				local Team = Player:GetAttribute('Team')
				
				if Player and Player.Parent then -- check for parent and that it's to the game
					
					if Team ~= 'Killer' and Team ~= "Survivor" then
						beginSpectator(Player)
					else
						Player:LoadCharacter() -- do not wait
						if Team == 'Killer' then
							beginKiller(Player)
						elseif Team == "Survivor" then
							beginSurvivor(Player)
						end
					end

					--BUG_READ:FireAllClients("Spawned "..Player.Name)
				else
					--BUG_READ:FireAllClients("Player could not load: "..stored_name)
				end
			end

			Modules.Match:Assign_Obsession() -- assign an obsession
			
			--print('testing...')
			
			task.wait(2.5)
			
			game.ReplicatedStorage.Match.Started.Value = true
			--BUG_READ:FireAllClients("Players Loaded!")
		end
	end
	
	if ServerLoaded and not game:GetService("RunService"):IsStudio() and not workspace:GetAttribute("CUSTOM") then
		
		if #game.Teams:WaitForChild('Survivor'):GetPlayers() <= 0 and (workspace:GetServerTimeNow() - ServerLoaded) >= 60 then -- no survivors left
			if game:GetService("RunService"):IsStudio() then return end
			
			for _, killer_player in pairs(game.Teams:WaitForChild('Killer'):GetPlayers()) do
				Modules.Code:Spectate(killer_player)
			end
		end
		
		if #game.Teams:WaitForChild("Killer"):GetPlayers() <= 0 and (workspace:GetServerTimeNow() - ServerLoaded) >= 60 then -- no killers left
			if game:GetService("RunService"):IsStudio() then return end

			for _, survivor_player in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do
				Modules.Code:Spectate(survivor_player)
			end
		end
	end
end
