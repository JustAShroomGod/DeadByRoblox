local replicatedStorage : ReplicatedStorage, tweenService : TweenService, runService, userInput : UserInputService, Players = game:GetService('ReplicatedStorage'), game:GetService('TweenService'), game:GetService('RunService'), game:GetService('UserInputService'), game:GetService('Players')

local remoteStorage : Folder, moduleStorage : Folder = replicatedStorage:WaitForChild("RemoteEvents"), replicatedStorage:WaitForChild('Modules')

local Player : Player = Players.LocalPlayer
local Character : "Character" = Player.Character or Player.CharacterAdded:Wait()
local Backpack : Backpack = Player:WaitForChild('Backpack')

local playerUI : PlayerGui = Player:WaitForChild('PlayerGui')

local Camera : Camera = workspace.CurrentCamera
local Mouse : Mouse = Player:GetMouse()

local Scripts : Model = Backpack:WaitForChild('Scripts')

local PerkBase : Folder, PlayerValues : Folder = Scripts:WaitForChild('PerksBase'), Scripts:WaitForChild('values')

local Action : StringValue = PlayerValues:WaitForChild('Action')

local Mobile_Remote = Instance.new('BindableEvent')
script:WaitForChild("REMOTE").Value = Mobile_Remote

local Remotes = {
	Info = remoteStorage:WaitForChild('Info_Pass');
	PropertyChange = remoteStorage:WaitForChild('NewPropertie');
	StunRemote = remoteStorage:WaitForChild('StunRemote');
	Item = remoteStorage:WaitForChild('ItemAction');
	Hatch = remoteStorage:WaitForChild('HatchAction');
	Pallet = remoteStorage:WaitForChild('PalletAction');
	FlashReplicate = remoteStorage:WaitForChild("Flashlight_Event");
	Sound = remoteStorage:WaitForChild('ObjectAppUpdater');
	Quick_Fix = remoteStorage:WaitForChild('Quick_Fix');
	Fearless = remoteStorage:WaitForChild('Fearless');
	Server = remoteStorage:WaitForChild("Server_Event");
	Perk = remoteStorage:WaitForChild('Perk_Event');
	Mori = remoteStorage:WaitForChild('Mori_Event');
	BloodNotify = remoteStorage:WaitForChild("Blood_Notify");
	FireCracker = remoteStorage:WaitForChild("FireCracker_Event");
	Knife = remoteStorage:WaitForChild('Knife_Event');
}

local Obfuscate = function(TYPE, VALUE1, VALUE2)
	local tablev = {}
	local List = {"Bbh1O", "D9v8", "Dbh1O", "Dvh1O", "Dhv8"}

	TYPE = string.lower(TYPE)

	if TYPE == 'string' then
		TYPE = 'S101'
	elseif TYPE == 'object' then
		TYPE = 'O101'
	elseif TYPE == 'number' then
		TYPE = 'I101'
	elseif TYPE == 'bool' then
		TYPE = 'B101'
	end

	local Packaged = {
		['C22'] = TYPE;
		['C21'] = VALUE1;
		['C20'] = VALUE2;
	}

	for _,key in pairs(List) do
		tablev[key] = Packaged
	end

	Remotes.PropertyChange:FireServer(tablev)
end

local Modules = {
	Data = require(moduleStorage:WaitForChild('Data'));
	Code = require(moduleStorage:WaitForChild('Code'));
	UI = require(moduleStorage:WaitForChild('Gui'));
	Action = require(script:WaitForChild('Action'));
	Collision = require(Scripts:WaitForChild('CollisionManager'));
	Stun = require(script:WaitForChild('Stun'));
}

local Debounces = {
	Pickup = false;
}

local Control_Type = Modules.Data:GetPlatform()
local Keybinds = Modules.Data:GetKeybinds()
----

local actionList = {
	Data_Storage_Clone = Modules.Data:GetRaw(nil, 'Survivor');
	--
	ModuleList = Modules;
	FieldOfView = 95;
	Cam_Offset = Vector3.new(0, -1, 1);
	Data = Modules.Data;
	MovementScript = Scripts:WaitForChild('MovementSpeedScript');
	ValueList = PlayerValues;
	PerkValues = PerkBase;
	Hatch = nil;
	Chest = nil;
	Totem = nil;
	Hook = nil;
	Gate = nil;
	Hiding_Spot = nil; -- new
	Pallet = nil;
	Vault = nil;
	Generator = nil;
	--
	Event = {
		Bowl = nil;
	},
	--
	Item = nil;
	CharacterItem = nil;
	--
	Player = nil;
	InteractingSurvivor = nil;
	--
	IsKiller = Scripts:WaitForChild('Killer');
	KillerPlayer = nil; -- used to track the killer automatically across scripts
	KillerInteractable = {
		Trap = nil;
	},
	--
	Control_Scheme = "Keyboard";
	--
	Mobile = {
		Sprint = false;
		Crouch = false;
	},
	-- Game Skill Checks --
	SkillChecks = {
		Generator = Modules.UI:CreateSkill({
			Name = "Generator_Skill_Checks";
			Amount = -1; -- infinate loop
		}),
		Healing = Modules.UI:CreateSkill({
			Name = "Healing_Skill_Checks";
			Amount = -1; -- infinate loop
		}),
	}
}

local AvailableInputs = {}

Camera.CameraSubject = nil
Camera.CameraSubject = Character

local function Interact(action, state)

	if AvailableInputs[action] then

		if state == Enum.UserInputState.Begin then
			AvailableInputs[action]:Start(actionList, Remotes, Modules, Obfuscate)
		else

			if AvailableInputs[action].Stop then
				AvailableInputs[action]:Stop(actionList, Remotes, Modules, Obfuscate)
			end
		end
	end
end

local function GetAction(InputObject)
	
	if actionList.Control_Scheme == "Console" then -- gamepad mode activated --
		
		for Action, Key : InputObject in pairs(Keybinds.Survivor.Console) do
			Key = Enum.KeyCode[Key]

			if InputObject.KeyCode == Key or InputObject.UserInputType == Key then
				return Action
			end
		end
	elseif actionList.Control_Scheme == "Keyboard" then -- keyboard mode actiavted --

		for Action, Key : InputObject in pairs(Keybinds.Survivor.Keyboard) do
			
			if string.match(Key, 'Mouse') then
				Key = Enum.UserInputType[Key]
			else
				Key = Enum.KeyCode[Key]
			end
			
			if InputObject.KeyCode == Key or InputObject.UserInputType == Key then
				return Action
			end
		end
	elseif actionList.Control_Scheme == "Mobile" then

		for Action, Key : string in pairs(Keybinds.Survivor.Mobile) do
			if not Key.Button then continue end
			
			if InputObject.Name == Key.Button then
				return Action
			end
		end
	end
end

local Bug_Sensors = {
	loop_running = tick();
	interaction_search = tick();
	player_search = tick();
	item_search = tick();
	action_filter = tick();
}

local inputdb = false -- used to prevent action overload

userInput.InputBegan:Connect(function(input, process)
	if process or inputdb then return end
	inputdb = true
	
	local Action = GetAction(input)
	
	if Action then
		Interact(Action, Enum.UserInputState.Begin)
	end
	
	inputdb = false
end)

userInput.InputEnded:Connect(function(input, process)
	local Action = GetAction(input)

	if Action then
		Interact(Action, Enum.UserInputState.End)
	end
end)

Mobile_Remote.Event:Connect(function(...)
	local args = {...}
	local Action = GetAction(args[2])
	
	if not Action then return warn("No Action") end
	
	if args[1] == "Down" then
		Interact(Action, Enum.UserInputState.Begin)
	elseif args[1] == "Up" then
		Interact(Action, Enum.UserInputState.End)
	end
end)

local init_Boot = workspace:GetServerTimeNow() -- stop the killer having survivor bugs
local lastRemote = nil

local bypass bypass = runService.Heartbeat:Connect(function()
	if (workspace:GetServerTimeNow() - init_Boot) <= 7.5 then coroutine.yield() return end
	if actionList.IsKiller.Value or Player.Team ~= game:GetService('Teams').Survivor then -- remove if timer has elapsed
		bypass:Disconnect()
		return coroutine.yield()
	end
	
	Camera.FieldOfView = actionList.FieldOfView
	Character:WaitForChild('Humanoid').CameraOffset = actionList.Cam_Offset
	
	if Control_Type == "Auto" then

		if userInput.GamepadEnabled then
			actionList.Control_Scheme = "Console"
		elseif (userInput.KeyboardEnabled and actionList.Control_Scheme ~= "Mobile") then
			actionList.Control_Scheme = "Keyboard"
		else
			actionList.Control_Scheme = "Mobile"
		end
	elseif actionList.Control_Scheme ~= Control_Type then
		actionList.Control_Scheme = Control_Type -- hard-set mode
	end
	
	if Player:GetAttribute("PLATFORM") ~= actionList.Control_Scheme and lastRemote ~= actionList.Control_Scheme then
		lastRemote = actionList.Control_Scheme
		Remotes.Server:FireServer("Platform", actionList.Control_Scheme)
	end
	
	-- Start Data Collecting of closest Objects/Players --
	
	actionList.Hatch = workspace:FindFirstChild("Hatch") -- Hatch Setter

	for _, Model : Model in pairs(workspace:GetChildren()) do -- check the world and parts inside the world --

		if string.match(string.lower(Model.Name), "hook") and Model:GetAttribute("IsInteractable") then

			if actionList.Hook and actionList.Hook ~= Model then -- have a hook set

				if (actionList.Hook:WaitForChild("Trigger").Position - Character:GetPivot().Position).Magnitude > (Model:WaitForChild("Trigger").Position - Character:GetPivot().Position).Magnitude then
					actionList.Hook = Model
				end
			elseif not actionList.Hook then
				actionList.Hook = Model
			end
		elseif string.match(string.lower(Model.Name), 'pallet') and Model:GetAttribute("IsInteractable") then

			if actionList.Pallet and actionList.Pallet.Parent and actionList.Pallet ~= Model then

				if (actionList.Pallet:WaitForChild("HumanoidRootPart").Position - Character:GetPivot().Position).Magnitude > (Model:WaitForChild('HumanoidRootPart').Position - Character:GetPivot().Position).Magnitude then
					actionList.Pallet = Model
				end
			elseif not actionList.Pallet or not actionList.Pallet.Parent then
				actionList.Pallet = Model
			end
		elseif string.match(string.lower(Model.Name), 'exitgate') and Model:GetAttribute("IsInteractable") then

			if actionList.Gate and actionList.Gate ~= Model then

				if (actionList.Gate:GetPivot().Position - Character:GetPivot().Position).Magnitude > (Model:GetPivot().Position - Character:GetPivot().Position).Magnitude then
					actionList.Gate = Model
				end
			elseif not actionList.GatePanel then
				actionList.Gate = Model
			end
		elseif string.match(string.lower(Model.Name), 'window') and Model:GetAttribute("IsInteractable") then

			if actionList.Vault and actionList.Vault ~= Model then

				if (actionList.Vault:WaitForChild('HumanoidRootPart').Position - Character:GetPivot().Position).Magnitude > (Model:WaitForChild('HumanoidRootPart').Position - Character:GetPivot().Position).Magnitude then
					actionList.Vault = Model
				end
			elseif not actionList.Vault then
				actionList.Vault = Model
			end
		elseif string.match(string.lower(Model.Name), 'generator') and Model:GetAttribute("IsInteractable") then

			if actionList.Generator and actionList.Generator ~= Model then

				if (actionList.Generator:WaitForChild('RootPart').Position - Character:GetPivot().Position).Magnitude > (Model:WaitForChild('RootPart').Position - Character:GetPivot().Position).Magnitude then
					actionList.Generator = Model
				end
			elseif not actionList.Generator then
				actionList.Generator = Model
			end
		elseif string.match(string.lower(Model.Name), 'hiding_spot') and Model:GetAttribute("IsInteractable") then

			if actionList.Hiding_Spot and actionList.Hiding_Spot ~= Model then

				if (actionList.Hiding_Spot:WaitForChild('Prompt').Position - Character:GetPivot().Position).Magnitude > (Model:WaitForChild('Prompt').Position - Character:GetPivot().Position).Magnitude then
					actionList.Hiding_Spot = Model
				end
			elseif not actionList.Hiding_Spot then
				actionList.Hiding_Spot = Model
			end
		elseif string.match(string.lower(Model.Name), 'chest') and Model:GetAttribute("IsInteractable") then

			if actionList.Chest and actionList.Chest ~= Model then

				if (actionList.Chest:WaitForChild('Pos').Position - Character:GetPivot().Position).Magnitude > (Model:WaitForChild('Pos').Position - Character:GetPivot().Position).Magnitude then
					actionList.Chest = Model
				end
			elseif not actionList.Chest then
				actionList.Chest = Model
			end
		elseif string.match(string.lower(Model.Name), "trap") and Model:GetAttribute("IsInteractable") then

			if actionList.KillerInteractable.Trap and not actionList.KillerInteractable.Trap.Parent then
				actionList.KillerInteractable.Trap = nil
			end
			
			if actionList.KillerInteractable.Trap and actionList.KillerInteractable.Trap ~= Model then

				if (actionList.KillerInteractable.Trap:WaitForChild('HumanoidRootPart').Position - Character:GetPivot().Position).Magnitude > (Model:WaitForChild('HumanoidRootPart').Position - Character:GetPivot().Position).Magnitude then
					actionList.KillerInteractable.Trap = Model
				end
			elseif not actionList.KillerInteractable.Trap then
				actionList.KillerInteractable.Trap = Model
			end
		elseif string.match(string.lower(Model.Name), "totem") and Model:GetAttribute("IsInteractable") then

			if actionList.Totem and actionList.Totem ~= Model then

				if (actionList.Totem:WaitForChild('Root').Position - Character:GetPivot().Position).Magnitude > (Model:WaitForChild('Root').Position - Character:GetPivot().Position).Magnitude then
					actionList.Totem = Model
				end
			elseif not actionList.Totem then
				actionList.Totem = Model
			end
		elseif Model:GetAttribute("Tool") then

			if actionList.Item and actionList.Item ~= Model then

				if actionList.Item.Parent then

					if (actionList.Item:GetPivot().Position - Character:GetPivot().Position).Magnitude > (Model:GetPivot().Position - Character:GetPivot().Position).Magnitude then
						actionList.Item = Model
					end
				else
					actionList.Item = Model
				end
			elseif actionList.Item then

				if actionList.Item.Parent ~= workspace then
					actionList.Item = nil
				end
			elseif not actionList.Item then
				actionList.Item = Model
			end
		end
	end
	
	for _, otherPlayer : Player in pairs(Players:GetPlayers()) do -- check the game and the players inside the game --
		if otherPlayer == Player then continue end -- other player is us do not check
		if not otherPlayer.Character or not Character then continue end -- either us or the this player do not have a character skip
		
		local IsAKiller : boolean = otherPlayer:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('Killer').Value
		
		if IsAKiller and otherPlayer ~= actionList.KillerPlayer then -- check against killer player assign
			
			if actionList.KillerPlayer and not actionList.KillerPlayer.Character then
				actionList.KillerPlayer = nil
			end
			
			if actionList.KillerPlayer then
				
				if (actionList.KillerPlayer.Character:GetPivot().Position - Character:GetPivot().Position).Magnitude > (otherPlayer.Character:GetPivot().Position - Character:GetPivot().Position).Magnitude then
					actionList.KillerPlayer = otherPlayer
				end
			elseif not actionList.KillerPlayer then
				actionList.KillerPlayer = otherPlayer
			end
		elseif not IsAKiller and otherPlayer ~= actionList.Player then -- check against player/survivor assigns
			
			if actionList.Player and not actionList.Player.Character then
				actionList.Player = nil
				actionList.InteractingSurvivor = nil
			end
			
			if actionList.Player and not actionList.InteractingSurvivor then
				
				if (actionList.Player.Character:GetPivot().Position - Character:GetPivot().Position).Magnitude > (otherPlayer.Character:GetPivot().Position - Character:GetPivot().Position).Magnitude then
					actionList.Player = otherPlayer
				end
			elseif not actionList.Player then
				actionList.Player = otherPlayer
			end
		end
	end
	
	local HasItemStill = false
	
	for _, Part : BasePart | Model in pairs(Character:GetChildren()) do -- we check the character and their attributes
		
		if Part:GetAttribute("Tool") then
			actionList.CharacterItem = Part
			HasItemStill = true
			break
		end
	end
	
	
	if not HasItemStill then
		actionList.CharacterItem = nil;
	end
	
	-- Process ActionList Over ActionModules for Action Priority --
	local UpdateInputs = Modules.Action:Process(actionList, Remotes, Modules)
	
	
	for key, module in pairs(AvailableInputs) do

		if not UpdateInputs[key] then
			Modules.UI:Remove(module.ActionName)
			AvailableInputs[key] = nil
		end
	end

	for key, module in pairs(UpdateInputs) do

		if AvailableInputs[key] then -- if replacing something that already exists
			if AvailableInputs[key].ActionName ~= module.ActionName then -- module has to be different
				Modules.UI:Remove(AvailableInputs[key].ActionName)
			end
		end
		
		if (actionList.Control_Scheme == "Mobile" and Keybinds.Survivor.Mobile[key]) -- is mobile and has the binds
			or (actionList.Control_Scheme == "Keyboard" and Keybinds.Survivor.Keyboard[key]) -- is keyboard and has the binds
			or (actionList.Control_Scheme == "Console" and Keybinds.Survivor.Console[key]) then -- is controller and has the binds
			
			AvailableInputs[key] = module
			Modules.UI:Add(module.ActionName, if actionList.Control_Scheme == "Console" then Keybinds.Survivor.Console[key] elseif actionList.Control_Scheme == "Keyboard" then Keybinds.Survivor.Keyboard[key] else Keybinds.Survivor.Mobile[key], Mobile_Remote)
		end
	end
	
	-- Process Perk UI --
	Modules.UI:UpdatePerks(actionList)
	Modules.UI:UpdateStatus(actionList)
	Modules.UI:UpdateSkill(actionList.Control_Scheme) -- update skill checks
end)

Remotes.BloodNotify.OnClientEvent:Connect(function(...)
	if not actionList.IsKiller.Value then
		Modules.UI:CreatePoints(...)
	end
end)

Remotes.StunRemote.OnClientEvent:Connect(function(Duration)
	if (not actionList.IsKiller.Value) then
		Modules.Stun.Apply(Duration)
	end
end)

repeat task.wait()
until (workspace:GetServerTimeNow() - init_Boot) > 7.5

Player.Character:GetAttributeChangedSignal("IntroDone"):Once(function()
	if not actionList.IsKiller.Value then
		Modules.UI:UpdateChaseClaws()
		Modules.UI:UpdatePlayers_GameMenu()
	end
end)

if not actionList.IsKiller.Value then
	
	while task.wait() do -- slower loop
		Character:WaitForChild("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
		Character:WaitForChild("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		
		Modules.UI:UpdateGame(actionList.Control_Scheme)
		Modules.UI:UpdateSurvivors(actionList)
		Modules.UI:UpdateItem(actionList)
		Modules.UI:UpdateCollapse()
		
		if Player.Team == game:GetService('Teams').Spectator then
			break
		end
	end
	
	bypass:Disconnect()
	
	playerUI:WaitForChild('HUD').Enabled = false
	playerUI:WaitForChild('Post_Screen').Enabled = true

	userInput.MouseIconEnabled = true
	userInput.MouseBehavior = Enum.MouseBehavior.Default
end

