local ReplicatedStorage, TweenService, PlayerService, ServerScriptService, ServerStorage = game:GetService('ReplicatedStorage'), game:GetService('TweenService'), game:GetService('Players'), game:GetService('ServerScriptService'), game:GetService('ServerStorage')

local UserApperance = require(script:WaitForChild('UserAppearence'))

local KillerStuff = ServerStorage:WaitForChild('KillerStuff')
local Spawns = ReplicatedStorage:WaitForChild('Game_Spawns')
local ItemStorage = ServerStorage:WaitForChild('ItemsStuff')

local Handler = {
	humanoid_settings = {
		Survivor = {
			BodyDepthScale = 0.9;
			BodyHeightScale = 1.2;
			BodyProportionScale = 0;
			BodyTypeScale = 0;
			BodyWidthScale = 0.73;
			HeadScale = 0.99;
		},
		Killer = {
			BodyDepthScale = 0.9;
			BodyHeightScale = 1.52;
			BodyProportionScale = 0;
			BodyTypeScale = 0;
			BodyWidthScale = 1.05;
			HeadScale = 1.2;
		},
		Tiny_Character = {
			BodyDepthScale = 0.68;
			BodyHeightScale = 0.68;
			BodyProportionScale = 0;
			BodyTypeScale = 0;
			BodyWidthScale = 0.58;
			HeadScale = 0.66;
		},
		Gnomes = {
			BodyDepthScale = 0.68;
			BodyHeightScale = 0.8;
			BodyProportionScale = 0;
			BodyTypeScale = 0;
			BodyWidthScale = 0.5;
			HeadScale = 0.68;
		}
	},
}

Handler.__index = Handler

function Handler:LoadAppearence(Player : Player, Mode : string, Data : "PlayerData", Killer_Character) : "Loads up UserAppearance Script"
	local Custom, Humanoid_Settings, KillerName = "Nothing", Handler.humanoid_settings[Mode], "Trapper"


	--TODO: find a way to display killers head (from 3rd person) while killer cutscene is playing
	if Data.Other.Character then
		KillerName = string.gsub(Data.Other.Character, "^.", string.upper) --capitalizes the first letter of a string

		local Testing_Killer = workspace:GetAttribute('Test_Killer')
		if Testing_Killer and Testing_Killer ~= "" and game:GetService('RunService'):IsStudio() then
			KillerName = Testing_Killer
		end
	end

	if Mode == "Killer" and workspace:GetAttribute('CUSTOM_MODE') == 'Tiny Killer' then
		Humanoid_Settings = Handler.humanoid_settings.Tiny_Character
	elseif Mode == "Survivor" and workspace:GetAttribute('CUSTOM_MODE') == 'Tiny Survivor' then
		Humanoid_Settings = Handler.humanoid_settings.Tiny_Character
	end

	coroutine.wrap(function()
		UserApperance.load(Player, Humanoid_Settings, Mode, Data, KillerName)
	end)()
end

function Handler:GiveItem(Player : Player) : "Gives equipped item to character"
	local Loaded_Item = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')):GetItem(Player)
	local Chosen_Item = if Loaded_Item then ItemStorage:FindFirstChild(Loaded_Item) else nil -- find our item
	local Addons = (require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')):GetAddons('Survivor', Player))

	if Chosen_Item then
		Chosen_Item = Chosen_Item:Clone()
		Chosen_Item:SetAttribute('Addon_1', Addons[1])
		Chosen_Item:SetAttribute('Addon_2', Addons[2])
		Chosen_Item.Parent = workspace:WaitForChild(Player.Name)


	elseif Loaded_Item and Loaded_Item ~= "" and Loaded_Item ~= " " then
		warn(Loaded_Item,' is missing from item storage!')
	end
end

function Handler:Spawn(Character : Model, Team : string) : "Spawns Character"
	local survivorSpawns = Spawns:WaitForChild('SurvivorSpawns')
	local killerSpawns = Spawns:WaitForChild("KillerSpawns")

	if Team == 'Killer' then

		local chosenSpawn : BasePart = Spawns:WaitForChild("KillerSpawns"):GetChildren()[math.random(1, #killerSpawns:GetChildren())]
		Character:PivotTo(chosenSpawn.CFrame * CFrame.new(0,1,0))
		chosenSpawn:Destroy()
	elseif Team == 'Survivor' then
		local chosenSpawn = Spawns:WaitForChild('SurvivorSpawns'):GetChildren()[math.random(1, #survivorSpawns:GetChildren())]

		Character:PivotTo(chosenSpawn.CFrame * CFrame.new(0,1,0))
		chosenSpawn:Destroy()
	end
end

return Handler