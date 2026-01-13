local ReplicatedStorage, tweenService = game:GetService('ReplicatedStorage'), game:GetService('TweenService')

local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local remoteEvent = Instance.new("RemoteEvent", remoteEvents)
remoteEvent.Name = string.gsub(script.Name,"Script","")

local Modules = {
	Collision = require(script:WaitForChild('Collisions'));
}

local prefix = "rbxassetid://"
local animationsId = {
	["FirstPort"] = prefix..14245986826, --13426024858 old animation, 14245986826 2nd old
	["SecondPort"] = prefix..14246039295 --13426031367 old animation, 14246039295 2nd old
}

remoteEvent.OnServerEvent:Connect(function(Player : Player, Pallet : Model, Side : BasePart, Action : string)
	local Scripts : Model = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local playerValues : Folder, movementScript : Script = Scripts:WaitForChild('values'), Scripts:WaitForChild('MovementSpeedScript'):WaitForChild('MainScript')
	local playerAction : StringValue = playerValues:WaitForChild('Action')
	
	local Character : "Character" = Player.Character
	local Humanoid : BasePart, RootPart : BasePart = Character:WaitForChild('Humanoid'), Character:WaitForChild('HumanoidRootPart')
	
	local Pallet_Settings : Folder = Pallet:WaitForChild('Panel')
	local palletState : IntValue, palletDropper : StringValue, palletVaulter : StringValue = Pallet_Settings:WaitForChild('State'), Pallet_Settings:WaitForChild('Dropper'), Pallet_Settings:WaitForChild('Vaulter')
	
	
	if Action == "Drop" and palletState.Value == 0 then
		palletState.Value = 1
		playerAction.Value = "DroppingPallet"
		palletDropper.Value = Player.Name
		RootPart.Anchored = true
		
		local tween = tweenService:Create(RootPart, TweenInfo.new(0.16), {
			CFrame = Side.CFrame * CFrame.new(0, -.8, 0) * CFrame.Angles(0, math.rad(180), 0);
		})
		tween:Play()
		tween.Completed:Wait()
		
		local dropAnim = Instance.new("Animation", Humanoid)
		dropAnim.AnimationId = animationsId[Side.Name]
		
		local animTrack = Humanoid:LoadAnimation(dropAnim)
		animTrack:Play()
		animTrack:AdjustSpeed(4.35)
		animTrack.Stopped:Wait()
		
		RootPart.Anchored = false
		playerAction.Value = "Nothing"
		dropAnim:Destroy()
		
		task.delay(.25, function()
			palletDropper.Value = "" -- no longer dropping
		end)
	elseif Action == "Vault" and palletState.Value == 1 then
		
		local DropTime = .2
		local VaultTimeModifier, TweenTimeModifier = .835, 1
		local HeightOffset, DistanceOffset = -.65, -7.7
		
		
		if Side.Name == "SecondPort" then
			movementScript.Disabled = true
			Humanoid.WalkSpeed = 0
			RootPart.Anchored = true
			palletVaulter.Value = Player.Name
			playerAction.Value = "SlidingPallet"
			
			Modules.Collision:UpdateCollisions(Character, false)
			
			local paletteBackSlideAnim = Instance.new("Animation")
			paletteBackSlideAnim.AnimationId = "http://www.roblox.com/Asset?ID=78658943788883" --78658943788883 new, 13426042156 old
			
			local paletteBackSlideAnimTrack = Humanoid:LoadAnimation(paletteBackSlideAnim)
			paletteBackSlideAnimTrack.Priority = Enum.AnimationPriority.Action
			paletteBackSlideAnimTrack:AdjustSpeed(1)
			paletteBackSlideAnimTrack:Play()
			
			local tween = game:GetService("TweenService"):Create(RootPart, TweenInfo.new(DropTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = Pallet.SecondPort.CFrame * CFrame.new(0, HeightOffset, -.8)
			})
			tween:Play()
			tween.Completed:Wait()
			
			local reachedCon reachedCon = paletteBackSlideAnimTrack.KeyframeReached:Connect(function(keyframe)
				
				if keyframe == "SlideFrame" then	
					reachedCon:Disconnect()
					
					local lastPosition = paletteBackSlideAnimTrack.TimePosition
					paletteBackSlideAnimTrack:AdjustSpeed(1.2 * VaultTimeModifier)
					
					local tween = tweenService:Create(RootPart,TweenInfo.new(((paletteBackSlideAnimTrack.Length * TweenTimeModifier) - lastPosition) / paletteBackSlideAnimTrack.Speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						CFrame = Pallet:WaitForChild("SecondPort").CFrame * CFrame.new(0, HeightOffset, DistanceOffset);
					})
					tween:Play()
					
					Pallet_Settings:WaitForChild("Collision"):WaitForChild("SlideSound"):Play()

					local endVault endVault = tween.Completed:Once(function()
						movementScript.Disabled = false
						RootPart.Anchored = false

						Modules.Collision:UpdateCollisions(Character, true)
					end)
					
					local stopCon1 stopCon1 = paletteBackSlideAnimTrack.Stopped:Connect(function()
						local paletteLandAnim = Instance.new("Animation")
						paletteLandAnim.AnimationId = "http://www.roblox.com/Asset?ID=13426049421"
						
						local paletteLandAnimTrack = Humanoid:LoadAnimation(paletteLandAnim)
						paletteLandAnimTrack.Priority = Enum.AnimationPriority.Action
						paletteLandAnimTrack:Play()
						paletteLandAnimTrack:AdjustSpeed(1.8)
						
						local stopCon2 stopCon2 = paletteLandAnimTrack.Stopped:Connect(function()
							playerAction.Value = "Nothing"
							palletVaulter.Value = ""
							
							stopCon1:Disconnect()
							reachedCon:Disconnect()
							stopCon2:Disconnect()
						end)
					end)
				end
			end)
		else
			movementScript.Disabled = true
			Humanoid.WalkSpeed = 0
			RootPart.Anchored = true
			palletVaulter.Value = Player.Name
			playerAction.Value = "SlidingPallet"
			
			Modules.Collision:UpdateCollisions(Character, false)
		
			local paletteFrontSlideAnim = Instance.new("Animation")
			paletteFrontSlideAnim.AnimationId = "http://www.roblox.com/Asset?ID=117582156666403" -- 117582156666403 new, 13426057439 old
			
			local paletteFrontSlideAnimTrack = Humanoid:LoadAnimation(paletteFrontSlideAnim)
			paletteFrontSlideAnimTrack.Priority = Enum.AnimationPriority.Action
			paletteFrontSlideAnimTrack:AdjustSpeed(1)
			paletteFrontSlideAnimTrack:Play()
			
			local tween = game:GetService("TweenService"):Create(RootPart, TweenInfo.new(DropTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = Pallet.FirstPort.CFrame*CFrame.new(0, HeightOffset, -.8)
			})
			tween:Play()
			tween.Completed:Wait()
			
			local reachedCon reachedCon = paletteFrontSlideAnimTrack.KeyframeReached:Connect(function(keyframe)
				
				if keyframe == "SlideFrame" then
					
					
					local lastPosition = paletteFrontSlideAnimTrack.TimePosition
					paletteFrontSlideAnimTrack:AdjustSpeed(1.2 * VaultTimeModifier)
					
					local tween = tweenService:Create(RootPart,TweenInfo.new(((paletteFrontSlideAnimTrack.Length * TweenTimeModifier) - lastPosition) / paletteFrontSlideAnimTrack.Speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						CFrame = Pallet:WaitForChild("FirstPort").CFrame * CFrame.new(0, HeightOffset, DistanceOffset);
					})
					tween:Play()
					
					Pallet_Settings:WaitForChild("Collision"):WaitForChild("SlideSound"):Play()
					
					local endVault endVault = tween.Completed:Once(function()
						movementScript.Disabled = false
						RootPart.Anchored = false

						Modules.Collision:UpdateCollisions(Character, true)
					end)
					
					paletteFrontSlideAnimTrack.Stopped:Once(function()
						local paletteLandAnim = Instance.new("Animation")
						paletteLandAnim.AnimationId = "http://www.roblox.com/Asset?ID=13426049421"
						
						local paletteLandAnimTrack = Humanoid:LoadAnimation(paletteLandAnim)
						paletteLandAnimTrack.Priority = Enum.AnimationPriority.Action
						paletteLandAnimTrack:Play()
						paletteLandAnimTrack:AdjustSpeed(1.8)
						
						paletteLandAnimTrack.Stopped:Once(function()
							playerAction.Value = "Nothing"
							palletVaulter.Value = ""
						end)
					end)
				end
			end)
		end
	end
end)