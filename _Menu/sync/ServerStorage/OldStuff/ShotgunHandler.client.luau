local playerservice = game:GetService("Players")
local userinputservice = game:GetService("UserInputService")

local player = playerservice.LocalPlayer
if player.Name ~= "Bromeri"
	and player.Name ~= "boogameow"
	and player.Name ~= "Fioz_s"	
	and player.Name ~= "AerooDev"
	and player.Name ~= "cheetamcu"
	and player.Name ~= "KameronLP11"
	and player.Name ~= "VeroxCode"
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

local character = workspace:WaitForChild(player.Name)
local humanoid = character:WaitForChild("Humanoid")
local rootpart = character:WaitForChild("HumanoidRootPart")
local hand = character:WaitForChild("RightHand")

local camera = workspace.CurrentCamera

local mouse = player:GetMouse()

local cf = CFrame
local cfn = cf.new
local cfa = cf.Angles

local prefix = "rbxassetid://"
local id = 15081495855

local animation = Instance.new("Animation", humanoid)
animation.AnimationId = prefix.. tostring(id)

local animtrack = humanoid:LoadAnimation(animation)

local began = userinputservice.InputBegan
local ended = userinputservice.InputEnded

local press

local remoteevent = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Shotgun")

local KeyCode = Enum.KeyCode.F


local event = began:Connect(function(input, process)
	if process == false then
		if input.KeyCode == KeyCode then
			remoteevent:FireServer(true)

			animtrack:Play(0.2, 1, 1)

			press = mouse.Button1Down:Connect(function()
				local look = camera.CFrame.LookVector

				local new_shotgun = character:FindFirstChild("Shotgun")

				local ignorelist = {character}
				table.insert(ignorelist, new_shotgun)

				local ray = Ray.new(camera.CFrame.Position, look*300)
				local target, position = workspace:Raycast(ray, ignorelist)

				remoteevent:FireServer({camera.CFrame, cfn(position)})

				for n, oplayer in pairs (game.Players:GetPlayers()) do
					if oplayer ~= player then
						local ochar = workspace:FindFirstChild(oplayer.Name)

						if ochar then
							local oroot = ochar:FindFirstChild("HumanoidRootPart")
							local ohum = ochar:FindFirstChild("Humanoid")
							if  oroot and ohum then
								local mag = (oroot.CFrame.p-position).magnitude
								if mag < 10 then
									remoteevent:FireServer(ohum)
									break
								end
							end
						end
					end
				end
			end)
		end
	end
end)

local event = ended:Connect(function(input)
	if input.KeyCode == KeyCode then
		remoteevent:FireServer(false)

		animtrack:Stop(0.2)

		if press then
			press:Disconnect()
		end
	end
end)