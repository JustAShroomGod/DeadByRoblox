--local physicsService = game:GetService("PhysicsService")
local Module = {
	CollisionGroups = {
		Player = 'Survivor';
		Pallet = 'Pallet';
		Slugged = "Downed";
	}
}

local function SetCollision(Character : Model, Group : string, All : BoolValue) : "Sets Collision to Group"

	for _, part : Part in pairs(Character:GetChildren()) do

		if part.Name == 'HumanoidRootPart' then
			local toSet = if All then Group else Module.CollisionGroups.Slugged
			
			--physicsService:SetPartCollisionGroup(part, toSet)
		elseif part:IsA('BasePart') or part.ClassName == 'MeshPart' then
			--physicsService:SetPartCollisionGroup(part, Group)
		end
	end
end

function Module:UpdateCollisions(Character : Model, collidable)
	if not Character then return end

	if not collidable then
		--SetCollision(Character, Module.CollisionGroups.Pallet, true)
	else
		--SetCollision(Character, Module.CollisionGroups.Player)
	end
end

return Module
