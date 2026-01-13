local profileService, dataTemplate = require(script.Parent:WaitForChild('ProfileService')), require(script.Parent:WaitForChild('dataEntry'))
local SERVER = {
	profiles = {}
}
local profileStore = profileService.GetProfileStore(
	"PlayerData_-2",
	dataTemplate:GetDefault()
)

function SERVER:Get(player : Player) : "Data"
	local start = tick()
	
	repeat task.wait()
	until SERVER.profiles[player.UserId] or (not game.Players:FindFirstChild(player.Name) and (tick() - start >= 5))
	
	if not SERVER.profiles[player.UserId] and type(player) == 'table' then
		SERVER:ADD(player.UserId)
	end
	
	repeat task.wait()
	until SERVER.profiles[player.UserId] or (not game.Players:FindFirstChild(player.Name) and (tick() - start >= 10))
	
	return SERVER.profiles[player.UserId]
end

function SERVER:ADD(UserId : IntValue)
	local playerProfile = profileStore:LoadProfileAsync("Player_"..UserId)

	if playerProfile then

		playerProfile:AddUserId(UserId) -- GDPR compliance
		playerProfile:Reconcile() -- refills/insta-fills missing data for when we update it

		playerProfile:ListenToRelease(function()
			SERVER.profiles[UserId] = nil
		end)

		SERVER.profiles[UserId] = playerProfile
	end
end

function SERVER:JOIN(player : Player)
	local playerProfile = profileStore:LoadProfileAsync("Player_"..player.UserId)
	
	if playerProfile then
		playerProfile:AddUserId(player.UserId) -- GDPR compliance
		playerProfile:Reconcile() -- refills/insta-fills missing data for when we update it
		
		playerProfile:ListenToRelease(function()
			SERVER.profiles[player.UserId] = nil
			player:Kick("Error occured when loading data!")
			--warn(player, 'left!')
		end)
		
		if player:IsDescendantOf(game:GetService('Players')) then
			SERVER.profiles[player.UserId] = playerProfile
		else
			playerProfile:Release() -- let the game go
		end
	else
		player:Kick("Error loading your data!")
	end

	--warn(player, 'joined!')
end

function SERVER:LEAVE(player : Player)
	local playerProfile = SERVER.profiles[player.UserId]
	
	--print('Saving', playerProfile)
	
	if playerProfile then
		playerProfile:Release()
	end
end

return SERVER
