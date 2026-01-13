local InsertService = game:GetService('InsertService')

local Map = {
	Public = {
		-- Normal Maps --
		--["Haddonfield"] = 16297783938;
		--['Dead Dawg Saloon'] = 15394980047;
		--["Blood Lodge"] = 137215053782325;
		--['Coal Tower'] = 15394975240;
		--["Fractured Cowshed"] = 15394951154;
		--["Fractured Space"] = 15394968493; 
		--["Old Blood Lodge"] = 131348077379814;  -- I have no plans for this getting season versions due to it being more like a memory of the past 
		["Rotten Fields"] = 18430963423;
		--["Sanctum of Wrath"] = 18431446206;
		--["Echoing Ruins"] = 18443609074; --long gone
		--["The Forest"] = 18431590670;
		--["Classic"] = 15548465106;
		["The Ruins"] = 116385950768910; 
		["The Library"] = 126961020263950;
		["Rancid Abattoir"] = 78240420573747;
		["Hawkins Laboratory"] = 85698183873699;
		["Charon Co. Ferry Tours"] = 81205982075835;
		["Azarov's Resting Place"] = 89833616758558;
		-----------------------------------------------------------------------
		--['Catacombs'] = 17102805881; disabled because this map ass

		--['TestingMap'] = 15467177835;
		--["Tile Test"] = 16242562425;

		--['TestMapChanges(Use Any Map here)'] = 15467177835;

		-- Fan Maps --
		--['Camping Woods'] = 15786363505;
		["Nightmare Forest"] = 15579304551;
		--["Stratinns Cellar"] = 18299048114;
		["Grace Abounds Church"] = 18866570429;
		--['Haunted Village'] = 18591989414;
		["The Yard"] = 109379795225393;
		["Flower Garden"] = 93359522721704;
		["Ormond Port Blox"] = 136190615809392;
		['Dead Tree Sanctuary'] = 82108279415535;
		--['Retro Castle'] = 82274992588741; -- disabled because this is buggy as shit
		['Crucifixion Woods'] = 91762624329095;


		-- Winter Maps --
		["Haddonfield"] = 15394782644; -- is temp winter
		['Winter Tower'] = 15424511493;
		['Winter Lodge'] = 15424647571;
		['Fractured Winter'] = 15424744734;
		--["Dead Dawg Saloon"] = 15395003970; -- INCOMPLETE (replace with new one)
		["Snowy Classic"] = 80166861941043;
		["Winter Cowshed"] = 109019036102451;
		["Winter Fields"] = 124948938826792; 
		["The Forest"] = 117262829167451;
		["Sanctum of Wrath"] = 89570971147815;

		-- Winter Fan Maps --
		["Nightmare Forest"] = 137712415524089;
		["Stratinn's Icy Cellar"] = 135063130656898;
		['Camping Woods'] = 129702349969482;
		--["Blox Asylum"] = 95064718241316;



		--Halloween Maps--
		--["Fall Nightmare Forest"] = 121440831778042;
		--["Fall Classic"] = 99154367183558;
		--["Fall Stratinns Cellar"] = 88292855547688;
		--["Fall Grace Abounds Church"] = 115680140700789;
		--["Fall Haunted Village"] = 130760525691073; -- disabled till map is fixed
		--["Fall Fractured Space"] = 106171173239693; 
		--['Fall Coal Tower'] = 71546743541484; 
		--['Fall Dead Dawg Saloon'] = 106756110964481;
		--["Fall Fractured Cowshed"] = 130128327381434; 
		--["Fall Forest"] = 112517688917508;
		--["Fall Haddonfield"] = 73681205457675;
		--["Fall Rotten Fields"] = 131154839318590; 
		--["Fall Echoing Ruins"] = 87865011231389;
		--["Fall Sanctum of Wrath"] = 78219848533704;
		--["Fall Blood Lodge"] = 111549905064589;

	},
	Private = { -- any maps in private are custom game only!
		['TESTING_MAP'] = 15467177835; --DEFAULT TESTING MAP - DO NOT DELETE THIS LINE
		['Map Testing 1'] = 103999553432678; --DEFAULT MT1 - DO NOT DELETE THIS LINE
		['Map Testing 2'] = 75999085636587; --DEFAULT MT2 - DO NOT DELETE THIS LINE
		["Test Map"] = 75243458371792; --DEFAULT TEST MAP - DO NOT DELETE THIS LINE
		["Johnson's Heartbeat"] = 87015574042531;
		["Wreckers' Yard"] = 130968426078351;
		["The Abomination"] = 126538963748507;
		["Unbridled Force"] = 76217037600445;
		--['No Red Paint'] = 91567305065328;
		['Dead Sands'] = 77176146353618;
		["Infinite Cornrows"] = 79888829520224;
		--["Old Fractured Cowshed"] = 83170196049464;
		--["Old Rotten Fields"] = 122123839992020;

		-- Winter Maps --
		--["Haddonfield"] = 15394782644; -- is temp winter
		--['Winter Tower'] = 15424511493;
		--['Winter Lodge'] = 15424647571;
		--['Fractured Winter'] = 15424744734;
		--["Dead Dawg Saloon"] = 15395003970; -- INCOMPLETE
		--["Snowy Classic"] = 80166861941043;
		--["Winter Cowshed"] = 109019036102451;
		--["Winter Fields"] = 124948938826792; 
		--["Winter Forest"] = 117262829167451;
		--["Sanctum of Wrath"] = 89570971147815;

		-- Winter Fan Maps --
		--["Winter Nightmare Forest"] = 137712415524089;
		--["Stratinn's Icy Cellar"] = 135063130656898;
		--['Winter Camping Woods'] = 129702349969482;


		--Halloween Maps--
		--["Fall Nightmare Forest"] = 121440831778042;
		--["Fall Classic"] = 99154367183558;
		--["Fall Stratinns Cellar"] = 88292855547688;
		--["Fall Grace Abounds Church"] = 115680140700789;
		--["Fall Haunted Village"] = 130760525691073; -- disabled till map is fixed
		--["Fall Fractured Space"] = 106171173239693; 
		--['Fall Coal Tower'] = 71546743541484; 
		--['Fall Dead Dawg Saloon'] = 106756110964481;
		--["Fall Fractured Cowshed"] = 130128327381434; 
		--["Fall Forest"] = 112517688917508;
		--["Fall Haddonfield"] = 73681205457675;
		--["Fall Rotten Fields"] = 131154839318590; 
		--["Fall Echoing Ruins"] = 87865011231389;
		--["Fall Sanctum of Wrath"] = 78219848533704;
		--["Fall Blood Lodge"] = 111549905064589;
	},
}

function Map:Choose(chosen_map : string)
	local mapname, map = "none", 0
	local list = {}

	-- assemble map list --
	for map_name : string, map_source : number in pairs(Map.Public) do
		table.insert(list, {map_name, map_source})
	end

	-- pick map --
	local chosen_map_id = nil

	if Map.Public[chosen_map] then
		chosen_map_id = {chosen_map, Map.Public[chosen_map]}
	elseif Map.Private[chosen_map] then
		chosen_map_id = {chosen_map, Map.Private[chosen_map]}
	else -- secret/hidden map pull from their instead
		chosen_map_id = nil
	end

	if not chosen_map_id then
		chosen_map_id = list[math.random(1, #list)]
	end

	mapname, map = chosen_map_id[1], chosen_map_id[2]

	map = InsertService:LoadAsset(map)

	map = map:FindFirstChildOfClass('Folder')

	if not map then return error(mapname..' can not load!') end

	return map, mapname
end

function Map:Generate(offerings : 'table')
	local mapname, map = "none", 0
	local list = {}

	-- pick map --
	local chosen_map_id = nil

	if workspace:GetAttribute("TESTING") then
--		print("Testmap chosen")
		chosen_map_id = {"Testing Map", Map.Private.TESTING_MAP}
	else
		-- assemble map list --
		for map_name : string, map_source : number in pairs(Map.Public) do
			table.insert(list, {map_name, map_source})
		end

		for i, offering in pairs(offerings) do

			if offering == "" or offerings == " " then
				table.remove(offerings, i)
			elseif not Map.Public[offering] and not Map.Private[offering] and string.lower(offering) ~= "wild" then -- not a existing map offering or wild card
				table.remove(offerings, i)
			end
		end

		if table.find(offerings, "Wild") or #offerings < 1 then -- we had a wild card do a random roll or we had no offerings
			chosen_map_id = list[math.random(1, #list)]
		else -- we have 1 or more offerings for a map type
			chosen_map_id = offerings[math.random(1, #offerings)] -- picks a random offering

			if Map.Public[chosen_map_id] then
				chosen_map_id = {chosen_map_id, Map.Public[chosen_map_id]}
			else -- secret/hidden map pull from their instead
				chosen_map_id = {chosen_map_id, Map.Private[chosen_map_id]}
			end
		end

		if not chosen_map_id[2] then
			chosen_map_id = list[math.random(1, #list)]
		end
	end

--	print(chosen_map_id[1], chosen_map_id[2])
	mapname, map = chosen_map_id[1], chosen_map_id[2]

	map = InsertService:LoadAsset(map)

	map = map:FindFirstChildOfClass('Folder')

	if not map then return error(mapname..' can not load!') end
	
	-- Sets CanQuery equal to the CanCollide propertie, if CanCollide is false
	local count = 0
	for i, v in pairs(map:GetDescendants()) do
		if (v:IsA("BasePart")) then
			local part: BasePart = v
			if (not part.CanCollide) then
				part.CanQuery = false
				count += 1
			end
		end
	end
	--print(`Set CanQuery of {count} Parts`)
	--
	
	local halloweenfilter = Instance.new("ColorCorrectionEffect")

	halloweenfilter.Name = "HalloweenColorCorrection"
	halloweenfilter.Brightness = .1
	halloweenfilter.Contrast = .2
	halloweenfilter.Enabled = true
	halloweenfilter.Saturation = .1
	halloweenfilter.TintColor = Color3.fromRGB(234, 181, 88)

	halloweenfilter.Parent = game.Lighting

	return map, mapname
end

return Map
