local Code = require(game.ReplicatedStorage.Modules.Code)
local Prefab = script:WaitForChild("BloodPool")
local data_module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local HasMither, MitherTier = data_module:GetPerk("NoMither", script.Parent.Parent.Parent)
local Teams = game:GetService("Teams")
local SpawnDelay = 0.85 
local Timer = {}

function OnUpdate(delta)
	local Survivors = Teams.Survivor
	
	if (#Survivors:GetPlayers() <= 0) then
		return
	end
	
	for index, player in pairs(Survivors:GetPlayers()) do
		if (player == nil) then
			continue
		end
		
		if (Timer[player.Name] == nil or (not Code:IsInjured(player) and not Code:IsDown(player)) or Code:GetEffect("Ghost", player)) then
			Timer[player.Name] = SpawnDelay
			continue
		end
		
		Timer[player.Name] -= delta
		if (Timer[player.Name] <= 0) then
			Timer[player.Name] = SpawnDelay
			CreateBloodPool(player)
		end
	end
end

function CreateBloodPool(Player: Player)
	
	if (Player.Character == nil) then
		return warn("Character nil")
	end
	
	if string.match(Player.Backpack.Scripts.values.Action.Value, "Hiding") then
		return
	end
	
	local Position = Player.Character.PrimaryPart.CFrame.Position
	local Params = RaycastParams.new()
	local AllCharacters = {}
	for _, DesiredPlayer in pairs(game.Players:GetPlayers()) do
		if DesiredPlayer then
			if DesiredPlayer.Character then
				local DesiredCharacter = DesiredPlayer.Character or DesiredPlayer.CharacterAdded:Wait()
				table.insert(AllCharacters, DesiredCharacter)
			end
		end
	end
	Params.FilterDescendantsInstances = {AllCharacters}
	Params.FilterType = Enum.RaycastFilterType.Exclude
	
	local Result: RaycastResult = workspace:Raycast(Position, Vector3.new(0, -1, 0) * 20, Params)
	
	if (Result) then
		local InterceptPos = Result.Position
		local InterceptAngle = 0
		local InterceptAngleZ = 0
		local BloodPool = Prefab:Clone()
		
		local RandomSize = math.random(200, 250)
		RandomSize /= 100
		local RandomRotation = math.random(0, 0)
		
		if (Result.Instance:IsA("BasePart") or Result.Instance:IsA("MeshPart")) then
			InterceptAngle = Result.Instance.Orientation.X
			InterceptAngleZ = Result.Instance.Orientation.Z
		end
		
		if (workspace:FindFirstChild("Stains") ~= nil) then
		else
			Instance.new("Folder", workspace).Name = "Stains"
		end
		
		BloodPool.Size = Vector3.new(0.01, 0.1, 0.01)
		BloodPool.CFrame = CFrame.new(InterceptPos, Vector3.new(InterceptAngle, RandomRotation, InterceptAngleZ))
		BloodPool.Parent = workspace.Stains
		
		local update: RBXScriptSignal = nil
		local tween = game.TweenService:Create(BloodPool, TweenInfo.new(0.7), {Size = Vector3.new(RandomSize, 0.1, RandomSize)})
		
		tween:Play()
		tween.Completed:Connect(function()
			update = game["Run Service"].Heartbeat:Connect(function(delta)
				local Transparency = BloodPool.Decal.Transparency
				local Reduction = (delta * 0.3)
				
				Transparency += Reduction
				BloodPool.Decal.Transparency = Transparency
				
				if (Transparency >= 1) then
					update:Disconnect()
					update = nil
					BloodPool:Destroy()
				end
			end)
		end)
	end
end

if HasMither then
	return
end


game["Run Service"].Heartbeat:Connect(OnUpdate)