remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
setKillerCharacter = remoteEvents:WaitForChild("SetKillerCharacter")

setKillerCharacter.OnServerEvent:Connect(function(plr,characterName,characterModel)

	if characterName == "Wraith" or characterName == "Trapper" then
		local char = workspace:WaitForChild(plr.Name)
		local redStain = game.ReplicatedStorage:WaitForChild("KillerStuff").Fl:Clone()
		redStain.Parent = workspace:WaitForChild(plr.Name).UpperTorso
		redStain:WaitForChild("Script").Disabled = false

		for _,child in ipairs (char:GetChildren()) do
			if child.ClassName == "Accessory" then
				child:WaitForChild("Handle").Transparency = 1
			end

			if child.ClassName == "MeshPart" then
				child.Transparency = 1
			end

			if child.Name == "Head" then
				child.Transparency = 1
				if child:FindFirstChild("face") ~= nil then
					child:FindFirstChild("face"):Destroy()
				end
			end
		end

		for _, child in pairs (char:GetChildren()) do
			if child.ClassName == "MeshPart" then
				if characterModel:FindFirstChild(child.Name.. "K") ~= nil then
					local newCharacterPart = characterModel:FindFirstChild(child.Name.."K"):Clone()
					newCharacterPart.Parent = char
					newCharacterPart.CFrame = child.CFrame

					local weld = Instance.new("WeldConstraint",newCharacterPart)
					weld.Name = "Weld"
					weld.Part0 = child
					weld.Part1 = newCharacterPart
					newCharacterPart.Anchored = false
				end
			end

			if child.Name == "Head" then
				if characterModel:FindFirstChild(child.Name.. "K") ~= nil then
					local newCharacterPart = characterModel:FindFirstChild(child.Name.."K"):Clone()
					newCharacterPart.Parent = char
					newCharacterPart.CFrame = child.CFrame

					local weld = Instance.new("WeldConstraint",newCharacterPart)
					weld.Name = "Weld"
					weld.Part0 = child
					weld.Part1 = newCharacterPart

					newCharacterPart.Anchored = false
				end
			end
		end
	end

	if characterName == "Stalker" or characterName == "MichaelMyers" then
		local char = workspace:WaitForChild(plr.Name)
		local redStain = game.ReplicatedStorage:WaitForChild("KillerStuff").Fl:Clone()
		redStain.Parent = workspace:WaitForChild(plr.Name).UpperTorso
		redStain:WaitForChild("Script").Disabled = false

		for _,child in ipairs (char:GetChildren()) do
			if child.ClassName == "Accessory" then
				child:WaitForChild("Handle").Transparency = 1
			end

			if child.ClassName == "MeshPart" then
				child.Transparency = 1
			end

			if child.Name == "Head" then
				child.Transparency = 1
				if child:FindFirstChild("face") ~= nil then
					child:FindFirstChild("face"):Destroy()
				end
			end
		end	

		for _, child in pairs (char:GetChildren()) do

			if child.ClassName == "MeshPart" then

				if characterModel:FindFirstChild(child.Name.. "K") ~= nil then

					local newCharacterPart = characterModel:FindFirstChild(child.Name.."K"):Clone()
					newCharacterPart.Parent = char
					newCharacterPart.CFrame = child.CFrame

					local weld = Instance.new("WeldConstraint",newCharacterPart)
					weld.Name = "Weld"
					weld.Part0 = child
					weld.Part1 = newCharacterPart

					newCharacterPart.Anchored = false

				end
			end

			if child.Name == "Head" then

				if characterModel:FindFirstChild(child.Name.. "K") ~= nil then

					local newCharacterPart = characterModel:FindFirstChild(child.Name.."K"):Clone()
					newCharacterPart.Parent = char
					newCharacterPart.CFrame = child.CFrame

					local weld = Instance.new("WeldConstraint",newCharacterPart)
					weld.Name = "Weld"
					weld.Part0 = child
					weld.Part1 = newCharacterPart

					newCharacterPart.Anchored = false
				end
			end
		end
	end
end)