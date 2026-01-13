local ReplicatedStorage : ReplicatedStorage, Players : Players = game:GetService("ReplicatedStorage"), game:GetService("Players")

local RemoteEvents : Folder = ReplicatedStorage:WaitForChild("RemoteEvents")

local ShotgunRemote = Instance.new("RemoteEvent")
ShotgunRemote.Name = "Shotgun"
ShotgunRemote.Parent = RemoteEvents

local template = script:WaitForChild("Shotgun")

local new_shotgun

ShotgunRemote.OnServerEvent:Connect(function(player, target)
	if player.Name ~= "Bromeri" 
		and player.Name ~= "Fioz_s"
		and player.Name ~= "AerooDev"
		and player.Name ~= "boogameow"
		and player.Name ~= 'cheetamcu'
		and player.Name ~= 'KameronLP11'
		and player.Name ~= 'VeroxCode'
		and player.Name ~= "PlsGiveMe_ATaco"
		and player.Name ~= "PoIarPatroller"
		and player.Name ~= "juauelmior1212"
		and player.Name ~= "Vixuzzy"
		and player.Name ~= "K0_rd"
		and player.Name ~= "SANICBOOMO"
		and player.Name ~= "GGnateG"
		and player.Name ~= "GreatAnthony100"
		and player.Name ~= "previded"
		and player.Name ~= "cream_aw"
        and player.Name ~= "PaRK_JimIN9555" then
		return
	end

	local character = workspace:FindFirstChild(player.Name)
	local hand = character:WaitForChild("RightHand")

	local _type = typeof(target)

	if _type == "Instance"  then
		target.Health -= 100
	elseif _type == "boolean" then

		if target then
			new_shotgun = template:Clone()
			new_shotgun.Parent = character
			new_shotgun.Anchored = false

			local newcframe = hand.CFrame * CFrame.Angles(0, -math.pi/2, 0)
			newcframe = newcframe*CFrame.new(-1.2, -0.1, 0)

			new_shotgun.CFrame = newcframe

			local weld = Instance.new("WeldConstraint", new_shotgun)
			weld.Part0 = hand
			weld.Part1 = new_shotgun
		else
			if new_shotgun then 
				new_shotgun:Destroy()
			end
		end
	else
		local with = function (cframe)
			local part = Instance.new("Part", workspace)
			part.Anchored = true
			part.Transparency = 1
			part.CanCollide = false
			part.CFrame = cframe

			local sound = Instance.new("Sound", part)
			sound.SoundId =  "rbxassetid://".. tostring(182289949)
			sound.RollOffMinDistance = 20
			sound.Volume = 5
			sound.RollOffMaxDistance = 800

			sound.TimePosition = 0
			sound.Playing = true

			spawn(function()
				task.wait(5)

				part:Destroy()
			end)
		end

		with(target[1])
		with(target[2])
	end
end)