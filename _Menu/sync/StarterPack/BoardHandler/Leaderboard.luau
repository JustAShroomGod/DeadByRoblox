local ReplicatedStorage : ReplicatedStorage, GroupService : GroupService, Players : Players = game:GetService("ReplicatedStorage"), game:GetService("GroupService"), game:GetService("Players")
local Remote = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('Server_Client')

local module = {}

local GroupId, RestrictedRank = 231, 230

local Container_Main = workspace:WaitForChild("Leaderboards"):WaitForChild("Leaderboard"):WaitForChild("Background"):WaitForChild("Container")
local Container_Title = workspace:WaitForChild("Leaderboards"):WaitForChild("Leaderboard"):WaitForChild("Title"):WaitForChild("Container")

local LeaderboardTitle = Container_Title:WaitForChild('Title')
local LeaderboardContent = Container_Main:WaitForChild('Content')
local Template = script:WaitForChild('Template')

local current_type, debouncer = nil, false
local Number_Abbrev = {"K", "M", "B"}

local board_types = {
	"Survivor",
	"Killer",
}

local Colours = {
	[1] = Color3.fromRGB(202, 208, 84);
	[2] = Color3.fromRGB(117, 175, 158);
	[3] = Color3.fromRGB(135, 100, 47);
}

function CleanBoard()
	for _, slot in pairs(LeaderboardContent:GetChildren()) do
		if slot:IsA('UIListLayout') then continue end
		slot:Destroy()
	end
end

function GetRankFromUserID(GroupID, UserID) : number
	local Groups = GroupService:GetGroupsAsync(UserID)

	for _, Group in pairs(Groups) do
		if Group.Id ~= GroupID then continue end
		return Group.Rank
	end

	return 0 -- did not get group
end

function AbbrievateNumber(Amount : number) : string
	if Amount < 1000 then return Amount end -- return amount if not available for num abbrev
	local string_var = tostring(math.floor(Amount))

	return tonumber((string.sub(string_var, 1, ((#string_var + 2)%3) + 3))/100) .. Number_Abbrev[math.floor((#string_var-1)/3)]
end

Remote.OnClientEvent:Connect(function(server_command, leaderboard_type, leaderboard_data)
	if server_command ~= "leaderboard" then return end -- not for this script
	if leaderboard_type == current_type then return end -- unneeded
	if debouncer then return end

	debouncer = true
	current_type = leaderboard_type

	CleanBoard()
	local Amount_Type = ""

	if leaderboard_type == "Survivor" then
		LeaderboardTitle.Text = leaderboard_type .. " Escapes"
		Amount_Type = "Escapes"
	elseif leaderboard_type == "Killer" then
		LeaderboardTitle.Text = "Total " .. leaderboard_type .. " Kills"
		Amount_Type = "Kills"
	else
		LeaderboardTitle.Text = leaderboard_type .. " Kills"
		Amount_Type = "Kills"
	end

	local rank, lastStamp, users = 1, workspace:GetServerTimeNow(), 1

	for _, leaderboard_slot in pairs(leaderboard_data) do
		if GetRankFromUserID(GroupId, leaderboard_slot.key) >= RestrictedRank then continue end -- skip restricted users
		if users > 20 then break end
	
		local userid, amount = leaderboard_slot.key, leaderboard_slot.value
		local current_slot = Template:Clone()

		local groups = game:GetService('GroupService'):GetGroupsAsync(tonumber(userid))

		current_slot.Name = rank
		current_slot.Player.Text = "Username"
		current_slot.Place.Text = "#"..rank
		current_slot.Amount.Text = Amount_Type .. ' - ' .. AbbrievateNumber(amount)

		if Colours[rank] then
			current_slot.Amount.TextColor3 = Colours[rank]
			current_slot.Place.TextColor3 = Colours[rank]
			current_slot.Player.TextColor3 = Colours[rank]
		end

		coroutine.wrap(function() -- split thread for faster loading times
			local PlayerImage, _ = game.Players:GetUserThumbnailAsync(tonumber(userid), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

			current_slot.Profile.Image = PlayerImage

			current_slot.Player.Text = game.Players:GetNameFromUserIdAsync(tonumber(userid))
			lastStamp = workspace:GetServerTimeNow()
		end)()

		current_slot.Parent = LeaderboardContent

		rank += 1
		users += 1
	end
	
	lastStamp = workspace:GetServerTimeNow()

	repeat task.wait()
	until (workspace:GetServerTimeNow() - lastStamp) > 0.1 -- most efficient wait method i think

	debouncer = false
end)

function Shift_Board(Amount)
	if debouncer then return end -- do not shift if we are in debouncer mode
	local current_index = table.find(board_types, current_type)

	if not current_index then
		current_index = 1
	end

	current_index += Amount

	if current_index <= 0 then
		current_index = #board_types
	elseif current_index > #board_types then
		current_index = 1
	end

	require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')):GetLeaderboard(Players.LocalPlayer,board_types[current_index])
end

for _, Killer_Module in pairs(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Killers'):GetChildren()) do
	if not require(Killer_Module).Active then continue end -- not a active killer skip leaderboard
	table.insert(board_types, Killer_Module.Name)
end

function module.Create()
	Container_Title:WaitForChild("Prev").MouseButton1Click:Connect(function()
		Shift_Board(-1)
	end)

	Container_Title:WaitForChild("Next").MouseButton1Click:Connect(function()
		Shift_Board(1)
	end)

	Shift_Board(1)
end

return module
