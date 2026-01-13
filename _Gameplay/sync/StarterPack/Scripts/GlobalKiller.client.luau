local replicatedStorage, tweenService, runService, userInput, Players = game:GetService('ReplicatedStorage'), game:GetService('TweenService'), game:GetService('RunService'), game:GetService('UserInputService'), game:GetService('Players')

local remoteStorage, moduleStorage = replicatedStorage.RemoteEvents, replicatedStorage.Modules

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Backpack : Backpack = Player:WaitForChild('Backpack')

local playerUI = Player:WaitForChild('PlayerGui')

local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

local Scripts = Backpack.Scripts

local PerkBase, PlayerValues = Scripts:WaitForChild('PerksBase'), Scripts:WaitForChild('values')
local Mobile_Remote = Instance.new('BindableEvent')

local Remotes = {
	HeadTilt = remoteStorage:WaitForChild('HeadTilt');
	Info = remoteStorage:WaitForChild('Info_Pass');
	ObjectUpdater = remoteStorage:WaitForChild('ObjectAppUpdater');
	PropertyChange = remoteStorage:WaitForChild('NewPropertie');
	Grasp = remoteStorage:WaitForChild('GraspAction');
	Hatch = remoteStorage:WaitForChild('HatchAction');
	Server = remoteStorage:WaitForChild("Server_Event");
	Swing = remoteStorage:WaitForChild('Swing');
	ChainSaw = remoteStorage:WaitForChild("ChainSaw");
	Hatchet = remoteStorage:WaitForChild('Hatchet');
	Perk = remoteStorage:WaitForChild('Perk_Event');
	Mori = remoteStorage:WaitForChild('Mori_Event');
	BloodNotify = remoteStorage:WaitForChild("Blood_Notify")
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
	Data = require(moduleStorage.Data);
	Code = require(moduleStorage.Code);
	UI = require(moduleStorage.Gui);
	Action = require(script.Action);
	Camera = require(script.Camera);
	Collision = require(Scripts.CollisionManager);
	ResourceComponent = require(moduleStorage.PlayerValues.ResourceComponent);
}

local Debounces = {
	Pickup = false;
}

local Control_Type = Modules.Data:GetPlatform()
local Keybinds = Modules.Data:GetKeybinds()

----

--to disable movement do actionList.MovementScript:Disable() and to enable do the same just instead of :Disable() do :Enable()
local actionList = {
	Data_Storage_Clone = Modules.Data:GetRaw(nil, 'Killer');
	--
	FOV_SETTING = 90;
	--
	Data = Modules.Data;
	MovementScript = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls(); 
	ValueList = PlayerValues;
	PerkValues = PerkBase;
	PreventHeadTilt = false;
	KillerWeapon = Player.Character:WaitForChild(Modules.Data:GetCharacter(), 30);
	BasicAttack = {
		Prevent = false;
		Using = false;
	}; -- used to disable basic attack inputs globally
	--
	Hatch = nil;
	Hook = nil;
	Gate = nil;
	Hiding_Spot = nil; -- new
	Pallet = nil;
	Vault = nil;
	Totem = nil;
	Generator = nil;
	BreakWall = nil;
	--
	Control_Scheme = "Keyboard";
	--
	Player = nil;
	InteractingSurvivor = nil;
	--
	IsKiller = Scripts:WaitForChild('Killer');
	KillerInteractable = {
		Trap = nil;
		Tesla = nil;
	},
	--
	Cross_Connections = {};
	--
	CallFunction = {} -- Call all functions inside (used to run background loops)
}

----

local init_Boot = workspace:GetServerTimeNow() -- stop the killer having survivor bugs

--[[function InitializeSpeed()
	repeat task.wait()
	until Player:FindFirstChild("PlayerValues") ~= nil
	
	local clientValues = Instance.new("Configuration")
	clientValues.Name = "ClientValues"
	clientValues.Parent = Player
	
	local currentKiller = Modules.Data:GetKiller(Player)
	currentKiller = `{string.upper(string.sub(currentKiller, 1, 1))}{string.sub(currentKiller, 2, -1)}`
	
	Modules["Speed"] = Modules.ResourceComponent.new(clientValues, "Speed", Modules.Code.Speeds.Global_Settings.Base_Speed)
	Modules["SpeedMultiplier"] = Modules.ResourceComponent.new(clientValues, "SpeedMultiplier", 1)
	Modules["SpeedMultiplier"]:Add("KillerBase", Modules.Code.Speeds[currentKiller].Movement, -1)
end

coroutine.wrap(InitializeSpeed)()]]

if actionList.KillerWeapon then
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

			for Action, Key : InputObject in pairs(Keybinds.Killer.Console) do
				Key = Enum.KeyCode[Key]

				if InputObject.KeyCode == Key or InputObject.UserInputType == Key then
					return Action
				end
			end
		elseif actionList.Control_Scheme == "Keyboard" then -- keyboard mode actiavted --

			for Action, Key : InputObject in pairs(Keybinds.Killer.Keyboard) do

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

			for Action, Key : string in pairs(Keybinds.Killer.Mobile) do
				if not Key.Button then continue end

				if InputObject.Name == Key.Button then
					return Action
				end
			end
		end
	end

	local inputdb = false -- used to prevent action overload
	local lastType, inputTick = nil, 0

	userInput.InputBegan:Connect(function(input, process)
		if process or inputdb then return end
		inputdb = true

		local Action = GetAction(input)

		if Action then

			if lastType == Action then -- if it's the same then allow it through no matter what
				Interact(Action, Enum.UserInputState.Begin)
				inputTick = workspace:GetServerTimeNow()
			elseif lastType ~= Action and (workspace:GetServerTimeNow() - inputTick) >= 0.15 then -- pressing 2 different buttons quickly in less then a second
				Interact(Action, Enum.UserInputState.Begin)
				lastType, inputTick = Action, workspace:GetServerTimeNow()
			end

		end

		inputdb = false
	end)

	userInput.InputEnded:Connect(function(input, process)
		local Action = GetAction(input)

		if Action then
			Interact(Action, Enum.UserInputState.End)
		end
	end)

	local NeckDb = tick()

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

	local function BindPart(Part : BasePart, Transparency : number, NotAPart : boolean)
		if NotAPart then
			Part.Transparency = Transparency
			return
		end
		
		Part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
			Part.LocalTransparencyModifier = Transparency
		end)

		Part.LocalTransparencyModifier = Transparency
	end

	actionList.KillerWeapon.DescendantAdded:Connect(function(part)
		if part:IsA('BasePart') then BindPart(part, 0) end
	end)
	
	for i, v in pairs(actionList.KillerWeapon:GetDescendants()) do
		if v:IsA('BasePart') then BindPart(v, 0) end
	end

	for _, Part : BasePart in pairs(actionList.KillerWeapon:GetChildren()) do
		if Part:IsA('BasePart') then BindPart(Part, 0) end
	end

	Modules.UI:InsertDeadzones(Keybinds.Killer.Mobile.Deadzones)

	local HasShadow, ShadowTier = Modules.Data:GetPerk("Shadowborn")

	local bypass bypass = runService.Heartbeat:Connect(function(step)
		if (workspace:GetServerTimeNow() - init_Boot) <= 7.5 then coroutine.yield() return end
		if not actionList.IsKiller.Value then -- remove if timer has elapsed
			bypass:Disconnect()
			return coroutine.yield()
		end

		-- Start Data Collecting of closest Objects/Players --

		if HasShadow then
			Camera.FieldOfView = actionList.FOV_SETTING + require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Shadowborn')).Tiers[ShadowTier]
		else
			Camera.FieldOfView = actionList.FOV_SETTING
		end

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
		
		actionList.Hatch = workspace:FindFirstChild("Hatch") -- Hatch Setter

		for _, Model : Model in pairs(workspace:GetChildren()) do -- interaction checker --

			if string.match(string.lower(Model.Name), "hook") and Model:GetAttribute("IsInteractable") then

				if actionList.Hook and actionList.Hook ~= Model then -- have a hook set

					if (actionList.Hook:WaitForChild("Trigger").Position - Character:GetPivot().Position).Magnitude > (Model:WaitForChild("Trigger").Position - Character:GetPivot().Position).Magnitude then
						actionList.Hook = Model
					end
				elseif not actionList.Hook then
					actionList.Hook = Model
				end
			elseif string.match(string.lower(Model.Name), "totem") and Model:GetAttribute("IsInteractable") then

				if actionList.Totem and actionList.Totem ~= Model then

					if (actionList.Totem:WaitForChild('Root').Position - Character:GetPivot().Position).Magnitude > (Model:WaitForChild('Root').Position - Character:GetPivot().Position).Magnitude then
						actionList.Totem = Model
					end
				elseif not actionList.Totem then
					actionList.Totem = Model
				end
			elseif string.match(string.lower(Model.Name), 'pallet') and Model:GetAttribute("IsInteractable") then

				if actionList.Pallet and actionList.Pallet.Parent and actionList.Pallet ~= Model then

					if (actionList.Pallet:WaitForChild("HumanoidRootPart").Position - Character:GetPivot().Position).Magnitude > (Model:WaitForChild('HumanoidRootPart').Position - Character:GetPivot().Position).Magnitude then
						actionList.Pallet = Model
					end
				elseif not actionList.Pallet or not actionList.Pallet.Parent then
					actionList.Pallet = Model
				end
			elseif string.match(string.lower(Model.Name), 'breakablewall') and Model:GetAttribute("IsInteractable") then

				if actionList.BreakWall and actionList.BreakWall ~= Model then

					if (actionList.BreakWall:GetPivot().Position - Character:GetPivot().Position).Magnitude > (Model:GetPivot().Position - Character:GetPivot().Position).Magnitude then
						actionList.BreakWall = Model
					end
				elseif not actionList.BreakWall then
					actionList.BreakWall = Model
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
			end
		end

		for _, otherPlayer : Player in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do
			if otherPlayer == Player or actionList.Player == otherPlayer then continue end
			if not otherPlayer.Character or not Character then continue end

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
				if AvailableInputs[key].ActionName ~= module.ActionName then
					Modules.UI:Remove(AvailableInputs[key].ActionName)
				end
			end

			if (actionList.Control_Scheme == "Mobile" and Keybinds.Killer.Mobile[key]) -- is mobile and has the binds
				or (actionList.Control_Scheme == "Keyboard" and Keybinds.Killer.Keyboard[key]) -- is keyboard and has the binds
				or (actionList.Control_Scheme == "Console" and Keybinds.Killer.Console[key]) then -- is controller and has the binds

				AvailableInputs[key] = module
				Modules.UI:Add(module.ActionName, if actionList.Control_Scheme == "Console" then Keybinds.Killer.Console[key] elseif actionList.Control_Scheme == "Keyboard" then Keybinds.Killer.Keyboard[key] else Keybinds.Killer.Mobile[key], Mobile_Remote)
			end
		end

		-- Process Perk UI --
		Modules.UI:UpdatePerks(actionList)
		Modules.UI:UpdateStatus(actionList)

		-- Process background loops --

		for _, func : "Functions" in pairs(actionList.CallFunction) do
			func(step, actionList, Remotes, Modules, Obfuscate)
		end
	end)
	
	init_Boot = workspace:GetServerTimeNow()
	
	local cameraStep
	cameraStep = runService.RenderStepped:Connect(function(delta)
		if (workspace:GetServerTimeNow() - init_Boot) <= 7.5 then coroutine.yield() return end
		if not actionList.IsKiller.Value then -- remove if timer has elapsed
			cameraStep:Disconnect()
			return coroutine.yield()
		end
		
		if (not Player.Character:GetAttribute("IntroDone")) then
			return coroutine.yield()
		end
			
		-- Camera --
		local Vector = Vector2.zero

		if actionList.Control_Scheme == "Keyboard" then
			Vector = Modules.Camera:GetMouseVector()
		elseif actionList.Control_Scheme == "Console" then
			Vector = Modules.Camera:GetGamepadVector()
		elseif actionList.Control_Scheme == "Mobile" then
			Vector = Modules.Camera:GetTouchVector()
		end
		
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = Modules.Camera:GetCamera(Character, Vector * delta, delta)
	end)

	Remotes.BloodNotify.OnClientEvent:Connect(function(...)
		if actionList.IsKiller.Value then
			Modules.UI:CreatePoints(...)
		end
	end)
	
	repeat task.wait()
	until (workspace:GetServerTimeNow() - init_Boot) > 7.5
	

	Player.Character:GetAttributeChangedSignal("IntroDone"):Once(function()
		Modules.UI:UpdateChaseClaws()
		Modules.UI:UpdatePlayers_GameMenu()
		

		task.spawn(function()
			BindPart(Character:WaitForChild('Head'), 1) -- keep head invisible
			BindPart(Character:WaitForChild('Neck'):WaitForChild('Handle'), 1) -- keep head invisible
			
			for _, v in pairs(Character:WaitForChild('Head'):GetDescendants()) do
				if v:IsA("Texture") or v:IsA("Decal") then
					BindPart(v, 1, true)
				end
			end
		end)
	end)

	if actionList.IsKiller.Value then

		while task.wait() do -- slower loop for UI

			if (tick() - NeckDb) >= .5 then

				if actionList.PreventHeadTilt then
					Remotes.HeadTilt:FireServer("Default")
				else
					local Angle, _, _ = Camera.CFrame:ToOrientation()
					Remotes.HeadTilt:FireServer(Angle)
				end
			end

			Modules.UI:UpdateGame(actionList.Control_Scheme)
			Modules.UI:UpdateItem(actionList)
			Modules.UI:UpdateSurvivors(actionList)
			Modules.UI:UpdateCollapse()

			if Player.Team == game:GetService('Teams').Spectator then
				break
			end
		end
		
		

		bypass:Disconnect()
		cameraStep:Disconnect()

		playerUI:WaitForChild('HUD').Enabled = false
		playerUI:WaitForChild('Post_Screen').Enabled = true

		userInput.MouseIconEnabled = true
		userInput.MouseBehavior = Enum.MouseBehavior.Default
	end
end