local ReplicatedStorage : ReplicatedStorage,ServerScripts : ServerScriptService,ServerStorage : ServerStorage = game:GetService('ReplicatedStorage'),game:GetService("ServerScriptService"),game:GetService("ServerStorage")

local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)
local BadgeManager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("BadgeManager"))

local wiggle_animation = script:WaitForChild('Animation')
local animation_speed = 3

local module = {
	Saved = {}; -- timestamps
	AnimationTracks = {}; -- play wiggle animations 
}

local Settings = {
	wiggleRate = 0.15;
	wiggleSpeed = 12; -- amount each tap gives
}

function module:Fire(Player : Player, Arguments : "table")
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')
	
	if not module.AnimationTracks[Player] then
		module.AnimationTracks[Player] = Player.Character.Humanoid:LoadAnimation(wiggle_animation)
	end
	
	local modifier = 1
	
	if not module.Saved[Player] then
		module.Saved[Player] = workspace:GetServerTimeNow()
	elseif (workspace:GetServerTimeNow() - module.Saved[Player]) <= Settings.wiggleRate then
		return -- do nothing too soon to update
	end
	
	local progress = playerValues:WaitForChild("WiggleProgress")
	
	if playerValues.Holded.Value and Arguments[2] and game.Players:FindFirstChild(Arguments[2].Name) then
		local Killer : Player = game.Players:FindFirstChild(Arguments[2].Name)
		local hasGrip, GripTier = data_module:GetPerk("Tight Grip", Killer)
		
		if hasGrip then
			modifier *= require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Tight Grip')).Pickup_Reduction
		end
		
		if not module.AnimationTracks[Player].IsPlaying then
			module.AnimationTracks[Player]:Play()
			module.AnimationTracks[Player]:AdjustSpeed(animation_speed)
			
			coroutine.wrap(function()
				task.wait(Settings.wiggleRate * 3)
				
				if (workspace:GetServerTimeNow() - module.Saved[Player]) >= Settings.wiggleRate then
					module.AnimationTracks[Player]:Stop()
				end
			end)()
		end
		
		if (progress.Value + (Settings.wiggleSpeed * modifier)) < 1000 then
			progress.Value = math.clamp(progress.Value + (Settings.wiggleSpeed * modifier), 0, 1000)
		else -- we get passed 1000
			BadgeManager.Award("Shake It Off",Player.UserId)
			
			if Arguments[2] and game.Players:FindFirstChild(Arguments[2].Name) then
				local Stunned = Arguments[2]:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Stunned')
				
				if not Stunned.Value then
					code_module:Stun_Killer(Arguments[2], 'Wiggle')
					data_module:GiveBlood(Player, 1500, "Survival", "KILLER GRASP ESCAPE")
				end
			end
			
			progress.Value = math.clamp(0, 0, 1000)
		end
	else
		--progress.Value = 0 -->> Caused the wiggle reset bug?

		if not module.AnimationTracks[Player].IsPlaying then
			module.AnimationTracks[Player]:Stop()
		end
	end
end

return module
