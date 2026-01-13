local ReplicatedStorage, ServerStorage, RunService, Players = game:GetService('ReplicatedStorage'), game:GetService("ServerStorage"), game:GetService("RunService"), game.Players
local ModuleStorage, RemoteStorage = ReplicatedStorage:WaitForChild('Modules'), ReplicatedStorage:WaitForChild('RemoteEvents')

local Totem = script.Parent.Parent
local Totem_State = Totem.Panel.State
local Totem_Player = Totem.Panel.Player
local Totem_Progress = Totem.Panel.Progress

local Totem_Effect = Totem.Panel.Effect
local Totem_Holder = Totem_Effect.Holder

local Flame_Effect = Totem:WaitForChild('Root'):WaitForChild('ParticleEmitter')
local Runner = nil
local Track = nil

local ValidActions = {"BreakingTotem", "CraftingShard"}

local Colors = {
	["Blessing"] = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(4, 0, 255)),
		ColorSequenceKeypoint.new(.266, Color3.fromRGB(37, 244, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	});
	["Curse"] = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(.306, Color3.fromRGB(255, 174, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 213, 0))
	})
}

local Sounds = {
	Breaking = Totem:WaitForChild('Collider'):WaitForChild('TotemCleansing');
	Broken = Totem:WaitForChild('Collider'):WaitForChild('TotemBreak');
	Hint = Totem:WaitForChild('Collider'):WaitForChild('Hint');
	Bless = Totem:WaitForChild('Collider'):WaitForChild('Bless')
}

local Modules = {
	Data = require(ModuleStorage:WaitForChild('Data'));
	Code = require(ModuleStorage:WaitForChild('Code'));
	Events = require(game.ServerScriptService["Event System"].Events)
}

function EffectChanged(newEffect)
	
	if (Totem_State.Value == 1) then
		Flame_Effect.Enabled = false
		return
	end
	
	Flame_Effect.Color = if (newEffect ~= "Dull") then Colors[newEffect] else Colors["Curse"]
	Flame_Effect.Enabled = (newEffect ~= "Dull")
	
	if (newEffect == "Blessing") then
		Sounds.Bless:Play()

		coroutine.wrap(function()

			while Totem_Effect.Value ~= "Dull" do
				task.wait(math.random(200, 500)/100)
				Sounds.Hint:Play()

				local Our_Player = game.Players:FindFirstChild(Totem_Holder.Value)

				if not Our_Player or Our_Player.Team ~= game.Teams:WaitForChild('Survivor') then
					Totem_Effect.Value = "Dull" -- downgrade, but do not break
				end
			end
		end)()
	end
	
end

function StateChanged(newState)
	
	if (newState == 1) then
		BreakTotem()
	end
	
	if (newState == 0) then
		if (Track == nil) then
			return
		end
		
		Track.TimePosition = 0
		Track:Stop()
	end
	
end

function PlayerChanged(playerName: string)
	StopBreaking()
	StartBreaking()
end

function StartBreaking()
	
	local Player = Players:FindFirstChild(Totem_Player.Value)
	
	Sounds.Breaking.TimePosition = math.random(0, 2.586)

	if (Totem_State.Value == 1 or Player == nil) then
		Totem_Progress.Value = 0
		return
	end
	
	Player.Character:SetAttribute("CurrentInteractable", Totem.Name)
	
	Sounds.Breaking.Playing = true
	Runner = RunService.Heartbeat:Connect(function(delta)
		
		Player = Players[Totem_Player.Value]
		
		if (Player == nil or Totem_State.Value == 1) then
			Totem_Progress.Value = 0
			StopBreaking()
			return
		end
		
		if (Totem_Progress.Value < 1000) then
			local CleanseSpeed = Modules.Code:GetPlayerValue(Player, "CleanseSpeed")
			CleanseSpeed = (delta * CleanseSpeed) * 60
			Totem_Progress.Value += math.clamp(CleanseSpeed, 0, 1000)
		else
			
			local Type = Totem_Effect.Value
			local PlayerAction = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value
			
			Totem_State.Value = 1
			Totem_Effect.Value = "Dull"
			
			if (Totem_Effect.Value == "Dull") then
				Modules.Data:GiveBlood(Player, 1000, "Boldness", "TOTEM CLEANSED")
			else
				Modules.Data:GiveBlood(Player, 1500, "Boldness", "CURSE CLEANSED")
			end

			if (PlayerAction == "CraftingShard" and Player.Character) then
				ServerStorage:WaitForChild('ItemsStuff'):WaitForChild('Bone_Knife'):Clone().Parent = Player.Character
			end
			
			Modules.Events.Survivor.onTotemBreak:Fire(Player, Type, Totem)
			
			StopBreaking()
		end
	end)
	
end

function StopBreaking()
	if (Runner ~= nil) then
		Runner:Disconnect()
		Runner = nil
	end
	Sounds.Breaking.Playing = false
end

function BreakTotem()
	
	if (Track == nil) then
		Track = Totem.Humanoid.Animator:LoadAnimation(script.Broken)
	end
	
	Sounds.Broken:Play()

	Track:Play(0, 1, 1)
	Track.Stopped:Wait()

	Track:Play(0, 1, 0)
	Track.TimePosition = Track.Length-1/100

	Totem.Collider.CanCollide = false
end


Totem_State.Changed:Connect(StateChanged)
Totem_Effect.Changed:Connect(EffectChanged)
Totem_Player.Changed:Connect(PlayerChanged)