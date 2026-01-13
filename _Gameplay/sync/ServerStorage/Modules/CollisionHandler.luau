--local physicsService = game:GetService('PhysicsService')

local Handler = {
	CollisionGroups = {
		NormalKiller = "Killer";
		Stalking = "Phase";
		NormalSurvivor = "Survivor";
		Attacked = "Hit";
		Slugged = "Downed";
	},
	
	
}


local function SetCollision(Character : Model, Group : string) : "Sets Collision to Group"
	
	for _, part : Part in pairs(Character:GetDescendants()) do
		if not part:IsA('BasePart') then continue end
		
		if part.Name == 'HumanoidRootPart' then
			--physicsService:SetPartCollisionGroup(part, Handler.CollisionGroups.Slugged)
		elseif part:IsA('BasePart') or part.ClassName == 'MeshPart' then
			--physicsService:SetPartCollisionGroup(part, Group)
		end
	end
end

function CollisionHandler(player : Player) : "Handlers Collision upon new character!"
	local Backpack, Character = player:WaitForChild('Backpack'), player.Character
	
	--SetCollision(Character, Handler.CollisionGroups.NormalSurvivor)
	
	local Health = Backpack:WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState')
	
	Health.Changed:Connect(function()
	
		if Health.Value == 0 then
			--SetCollision(Character, Handler.CollisionGroups.Slugged)
		else
			--SetCollision(Character, Handler.CollisionGroups.NormalSurvivor)
		end
	end)
end

function Handler:UpdateCollision(player : Player, Group : string) : "Sets Collision Manually | Hit, Stalk, Phase"
	local Character = player.Character
	
	if Character then
		--SetCollision(Character, Group)
	end
end

function Handler:AddPlayer(player : Player)
	local handled = false
	
	player.CharacterAdded:Connect(function(character)
		handled = true
		--CollisionHandler(player, character)
	end)
	
	if player.Character and not handled then
		--CollisionHandler(player, player.Character)
	end
end

return Handler
