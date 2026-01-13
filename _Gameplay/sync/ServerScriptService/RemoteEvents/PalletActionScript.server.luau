local ReplicatedStorage, tweenService, players = game:GetService('ReplicatedStorage'), game:GetService('TweenService'), game:GetService("Players")

local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local remoteEvent = Instance.new("RemoteEvent", remoteEvents)
remoteEvent.Name = string.gsub(script.Name, "Script", "")

local Modules = {
	Data = require(ReplicatedStorage.Modules:WaitForChild("Data"));
	Code = require(ReplicatedStorage.Modules:WaitForChild("Code"));
	Collision = require(script:WaitForChild('Collisions'));
}

local loadedTracks = {}

local prefix = "rbxassetid://"
local animationsId = {
	["FirstPort"] = prefix..80505555249711; --13426024858 old animation, 14245986826 2nd old, 80505555249711 new
	["SecondPort"] = prefix..129809226824019; --13426031367 old animation, 14246039295 2nd old, 129809226824019 new
}

players.PlayerAdded:Connect(function(Player) -- second then first
	Player.CharacterAdded:Connect(function(character)
		
		game:GetService("RunService").Stepped:Wait()
		
		loadedTracks[Player.Name] = {}
		local animator = Player.Character.Humanoid.Animator
		
		-- Rushed
		
		local RfirstAnim = Instance.new("Animation")
		RfirstAnim.AnimationId = prefix..117582156666403
		
		local RsecondAnim = Instance.new("Animation")
		RsecondAnim.AnimationId = prefix..78658943788883
		
		loadedTracks[Player.Name]["FirstPort_Rushed"] = animator:LoadAnimation(RfirstAnim)
		loadedTracks[Player.Name]["FirstPort_Rushed"].Priority = Enum.AnimationPriority.Action

		loadedTracks[Player.Name]["SecondPort_Rushed"] = animator:LoadAnimation(RsecondAnim)
		loadedTracks[Player.Name]["SecondPort_Rushed"].Priority = Enum.AnimationPriority.Action
		
		loadedTracks[Player.Name]["FirstPort_Rushed"]:Play()
		loadedTracks[Player.Name]["SecondPort_Rushed"]:Play()
		
		-- Slow
		
		local firstAnim = Instance.new("Animation")
		firstAnim.AnimationId = prefix..14532066315--117582156666403

		local secondAnim = Instance.new("Animation")
		secondAnim.AnimationId = prefix..14532063030--78658943788883

		loadedTracks[Player.Name]["FirstPort_Slow"] = animator:LoadAnimation(firstAnim)
		loadedTracks[Player.Name]["FirstPort_Slow"].Priority = Enum.AnimationPriority.Action

		loadedTracks[Player.Name]["SecondPort_Slow"] = animator:LoadAnimation(secondAnim)
		loadedTracks[Player.Name]["SecondPort_Slow"].Priority = Enum.AnimationPriority.Action

		loadedTracks[Player.Name]["FirstPort_Slow"]:Play()
		loadedTracks[Player.Name]["SecondPort_Slow"]:Play()
	end)
end)

remoteEvent.OnServerEvent:Connect(function(Player: Player, Pallet: Model, Side: BasePart, Action: string, Rushed: boolean)
	local Scripts: Model = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local playerValues: Folder, movementScript: Script = Scripts:WaitForChild('values'), Scripts:WaitForChild('MovementSpeedScript'):WaitForChild('MainScript')
	local playerAction: StringValue = playerValues:WaitForChild('Action')

	local Character = Player.Character
	local Humanoid, RootPart = Character:WaitForChild('Humanoid'), Character:WaitForChild('HumanoidRootPart')

	local Pallet_Settings: Folder = Pallet:WaitForChild('Panel')
	local palletState: IntValue, palletDropper: StringValue, palletVaulter: StringValue = Pallet_Settings:WaitForChild('State'), Pallet_Settings:WaitForChild('Dropper'), Pallet_Settings:WaitForChild('Vaulter')

	if Action == "Drop" and palletState.Value == 0 then
		palletState.Value = 1
		playerAction.Value = "DroppingPallet"
		palletDropper.Value = Player.Name
		RootPart.Anchored = true

		-- Fast center to position
		local centerTween = tweenService:Create(RootPart, TweenInfo.new(0.1), {
			CFrame = Side.CFrame * CFrame.new(0, 0, -.75) * CFrame.Angles(0, math.rad(180), 0)
		})
		centerTween:Play()
		centerTween.Completed:Wait()

		local dropAnim = Instance.new("Animation", Humanoid)
		dropAnim.AnimationId = animationsId[Side.Name]

		local animTrack = Humanoid:LoadAnimation(dropAnim)
		animTrack:Play()
		--animTrack:AdjustSpeed(.75)
		animTrack.Stopped:Wait()

		RootPart.Anchored = false
		playerAction.Value = "Nothing"
		dropAnim:Destroy()
		
		if (Player.Character:GetAttribute("Chased")) then
			Modules.Data:GiveBlood(Player, 200, 'Boldness', 'PALLET DROP')
		end

		task.delay(.25, function()
			palletDropper.Value = "" -- no longer dropping
		end)
	elseif Action == "Vault" and palletState.Value == 1 then
		local VaultSpeed = Modules.Code:GetPlayerValue(Player, "WindowVaultSpeed") or 1
		local VaultTimeModifier = if (Rushed) then 0.7 else 1.8
		local HeightOffset, DistanceOffset = -0.65, -9.25
		VaultTimeModifier *= VaultSpeed

		movementScript.Disabled = true
		Humanoid.WalkSpeed = 0
		RootPart.Anchored = true
		palletVaulter.Value = Player.Name
		playerAction.Value = "SlidingPallet"

		Modules.Collision:UpdateCollisions(Character, false)

		-- Fast center to position
		local targetPort = (Side.Name == "SecondPort" and Pallet.SecondPort or Pallet.FirstPort)
		local centerTween = tweenService:Create(RootPart, TweenInfo.new(0.1), {
			CFrame = targetPort.CFrame * CFrame.new(0, HeightOffset, 0)
		})
		centerTween:Play()
		centerTween.Completed:Wait()

		-- Start animation and tween
		local animType = if (Rushed) then "_Rushed" else "_Slow"
		local animTrack = loadedTracks[Player.Name][Side.Name..animType]
		
		animTrack:Play()
		animTrack:AdjustSpeed(if (Rushed) then 0.7 else 1.3)

		-- Play slide sound
		if (Rushed) then
			Pallet_Settings:WaitForChild("Collision"):WaitForChild("SlideSound"):Play()
			
			for i, plr in pairs(game.Teams.Killer:GetPlayers()) do
				Modules.Code:AddNotification(Pallet:GetPivot(), 5, "Default", plr)
			end
		end

		-- Main movement tween
		local moveTween = tweenService:Create(RootPart, TweenInfo.new(
			VaultTimeModifier,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out
			), {
				CFrame = targetPort.CFrame * CFrame.new(0, HeightOffset, DistanceOffset)
			})
		moveTween:Play()

		moveTween.Completed:Once(function()
			movementScript.Disabled = false
			RootPart.Anchored = false
			Modules.Collision:UpdateCollisions(Character, true)
			playerAction.Value = "Nothing"
			palletVaulter.Value = ""
		end)
	end
end)
