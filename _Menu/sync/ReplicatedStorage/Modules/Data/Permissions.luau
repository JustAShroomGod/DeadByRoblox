local Emulate_No_Perms : boolean = false -- turn on if you want to experience no perms for all
local Emulate_Full_Perms : boolean = false -- turn on if you want the test players to have full perms
local Cache = {}

local Perms = {
	Group_ID = 3863491;
	Free = {
		"mackthegame08",
		"KameronLP11",
		"C0MPL3X_W4RR10R",
		"PlsGiveMe_ATaco",
		"lucasaruxa",
		"rplee168",
		"Hens333"
	},
	Ranks = {
		{
			role = 'Tester';
			amount = 208;
		},
		{
			role = 'Mod';
			amount = 210;
		},
		{
			role = 'Admin';
			amount = 220;
		},
		{
			role = 'Developer';
			amount = 230;
		},
	},
}

function Perms:GetPerms(Player : Player, Permission : string) : "Either Return Raw Permission or true/false if they can do this action"
	if not Player then return warn('No Player Provided') end
	local In_Group = Player:IsInGroupAsync(Perms.Group_ID)
	local Current_Perm_Level = "None"
	
	if In_Group then
		Current_Perm_Level = "Group Memeber"
		
		if table.find(Perms.Free, Player.Name) then
			Current_Perm_Level = "Free Content"
		end
		
		local current_rank = Player:GetRankInGroupAsync(Perms.Group_ID)
		
		for _, data in pairs(Perms.Ranks) do
			
			if current_rank >= data.amount then
				Current_Perm_Level = data.role
			else
				break
			end
		end
	end
	
	if Emulate_No_Perms then -- overwrite to emulate
		Current_Perm_Level = "None"
	elseif Emulate_Full_Perms then
		Current_Perm_Level = "Developer"
	end
	
	if Permission then
		
		if Permission == "Testing" then -- Testing/Beta Content

			if Current_Perm_Level == "Developer"
				or Current_Perm_Level == "Mod"
				or Current_Perm_Level == "Admin"
				or Current_Perm_Level == "Tester" then
				return true
			end
		elseif Permission == "Moderating" then -- Moderating the game

			if Current_Perm_Level == "Developer"
				or Current_Perm_Level == "Mod"
				or Current_Perm_Level == "Admin" then
				return true
			end
		elseif Permission == "Developing" then

			if Current_Perm_Level == "Developer" then -- Early/Alpha testing for us
				return true
			end
		elseif Permission == "Content" then -- For Free Content/Stuff
			
			if Current_Perm_Level == "Developer"
				or Current_Perm_Level == "Free Content" then
				return true
			end
		elseif Permission == "Group" then
			
			if Current_Perm_Level ~= "None" then -- if not none then they are in group
				return true
			end
		end
		
		return false
	end
	
	return Current_Perm_Level
end

function Perms:GrabCache(Player : Player, Permission : string)
	if not Player then return warn("No player for cached search") end
	
	if not Cache[Player] then
		Cache[Player] = {}
	end
	
	if not Permission then -- want permission for action
		Permission = "Perm_Level"
	end
	
	if (Cache[Player][Permission] == nil) then
		
		if Permission == "Perm_Level" then
			Cache[Player][Permission] = require(script.Parent):GetPermission(nil, Player, true)
		else
			Cache[Player][Permission] = require(script.Parent):GetPermission(Permission, Player, true)
		end
	end
	
	return Cache[Player][Permission]
end

return Perms
