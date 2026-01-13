local BadgeService : BadgeService = game:GetService("BadgeService")

local module = {
	Can_Obtain = true;
	Cache = {};
}

module.Badges = {
	["Play DbR"] = 1098936882136193;
	["Millionaire"] = 2009442271482263;
	["Not So Fast"] = 4453728430231792;
	["Backdoor"] = 1377336936350034;
	["Light Mode"] = 855924913103207;
	["A Friend In Need"] = 1699672696051626;
	["Healer"] = 2296201781449547;
	["Shake It Off"] = 3359279205274579;
	["Ground Hug"] = 1063271002393239;
	["Torment"] = 528902137070819;
	["Basement Gamer"] = 3572206668490013;
	["Sacrifice"] = 1017911005322764;
	["Key To Success"] = 2739144131296499;
	["Hoarder"] = 3221777169397777;
	["Collector"] = 3653963737535812;
	["No Need For Sight"] = 2152255873344901;
	--["Acrophobia"] = 314044176687486;
	["Combo"] = 4443199121709467;
	["Run It Back"] = 543316616358955;
	["You Can't Hide"] = 3399385504378962;
	["Escape Artist"] = 18116793170140;
	["Experienced Survivor"] = 3419386608910188;
	["Trickster"] = 478413327799206;
	["Perky"] = 542315336127656;
	["Bloody Birthday"] = 2994245609620567;
	["Oopsie Daisy"] = 2146789909066498;
	["Trap Master"] = 2185202573007468;
	["Bloody Hatchet"] = 2760988481078952;
	["Russian Winter"] = 2868885835843600;
	["Behind The Hope"] = 4438075246209529;

}

function module.Award(badgeName : StringValue, userId : NumberValue) : "Awards player with a badge"
	local badgeId = module.Badges[badgeName]
	
	if not module.Cache[userId] then
		module.Cache[userId] = {}
	end
	
	if not module.Can_Obtain or not badgeId then
		return
	end
	
	if not module.Cache[userId][badgeId] then
		
		if BadgeService:UserHasBadgeAsync(userId, badgeId) then
			module.Cache[userId][badgeId] = true
		else
			module.Cache[userId][badgeId] = false
		end
	end
	
	if module.Cache[userId][badgeId] == true then
		return
	end
	
	local success,_ = pcall(function()
		return BadgeService:AwardBadgeAsync(userId, badgeId)
	end)

	if not success then
		--warn("Badge named " .. badgeName .. " with id being " .. badgeId .. " was not awarded to " .. userId)
	else
		module.Cache[userId][badgeId] = true
		--warn("Badge granted",badgeName)
	end
end

function module.RetrievePossesion(badgeName : StringValue, userId : NumberValue)
	local badgeId = module.Badges[badgeName]

	if not module.Cache[userId] then
		module.Cache[userId] = {}
		warn("CREATING CACHE")
	end

	if not module.Can_Obtain or not badgeId then
		warn("DOESNT EXIST!")
		return false
	end

	if not module.Cache[userId][badgeId] then
		warn("TRYING TO FIND")
		if BadgeService:UserHasBadgeAsync(userId, badgeId) then
			warn("FOUND !")
			module.Cache[userId][badgeId] = true
		else
			warn("FALSE!! DOESNT HAVE!!")
			module.Cache[userId][badgeId] = false
		end
	end

	return module.Cache[userId][badgeId]
end

return module