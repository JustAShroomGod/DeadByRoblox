local Handler = {
	Kills = {
		Noob = {0, Color3.fromRGB(130, 222, 255)};
		Novice = {25, Color3.fromRGB(255, 247, 14)};
		Pro = {100, Color3.fromRGB(32, 255, 28)};
		Master = {200, Color3.new(255,255,255)};
		Godly = {250, Color3.fromRGB(175, 37, 255)};
		Omega = {500, Color3.fromRGB(255, 0, 0)};
		Overlord = {1000, Color3.fromRGB(117, 99, 255)};
		Unstoppable = {2000, Color3.fromRGB(0, 0, 255)};
		Mythic = {3000, Color3.fromRGB(73, 7, 95)};
		Ascended = {6000, Color3.fromRGB(0, 212, 166)};
		Eternal = {8000, Color3.fromRGB(207, 0, 166)};
		Eclipsed = {10000, Color3.fromRGB(188, 113, 8)}
	},
	Escapes = {
		Noob = {0, Color3.fromRGB(130, 222, 255)};
		Novice = {25, Color3.fromRGB(255, 247, 14)};
		Pro = {100, Color3.fromRGB(32, 255, 28)};
		Master = {200, Color3.new(255,255,255)};
		Godly = {250, Color3.fromRGB(175, 37, 255)};
		Omega = {500, Color3.fromRGB(255, 0, 0)};
		Overlord = {750, Color3.fromRGB(117, 99, 255)};
		Unstoppable = {1000, Color3.fromRGB(0, 0, 255)};
		Mythic = {1500, Color3.fromRGB(73, 7, 95)};
		Ascended = {2500, Color3.fromRGB(0, 212, 166)};
		Eternal = {3500, Color3.fromRGB(207, 0, 166)};
		Eclipsed = {5000, Color3.fromRGB(188, 113, 8)}
	},
	Titles = {
		['PROJECT ANALYST'] = {"Developer", Color3.fromRGB(255, 8, 0)};
		['PROJECT MANAGER'] = {"Developer", Color3.fromRGB(255, 8, 0)};
		['PROJECT MANAGER ASSISTANT'] = {"Developer", Color3.fromRGB(255, 8, 0)};
		['BACK-END SCRIPTER'] = {"Developer", Color3.fromRGB(0, 130, 43)};
		['3D MODELER'] = {"Map Maker", Color3.fromRGB(29, 195, 90)};
		['3D ANIMATOR'] = {"Animator", Color3.fromRGB(29, 195, 90)};
		['GFX ARTIST'] = {"Artist", Color3.fromRGB(29, 195, 90)};
		['SFX ARTIST'] = {"Sound Designer", Color3.fromRGB(29, 195, 90)};
		['COSMETICS MODELER'] = {"Skin Designer", Color3.fromRGB(29, 195, 90)};
		['TRIAL DEVELOPER'] = {"Trail Developer", Color3.fromRGB(223, 181, 28)};
		['COMMUNITY ADMINISTRATOR'] = {"Admin", Color3.fromRGB(11, 84, 195)};
		["GAME MODERATOR"] = {"Moderator", Color3.fromRGB(14, 223, 223)};
		["CONTENT CREATOR"] = {"Content Creator", Color3.fromRGB(255, 43, 47)};
		['RETIRED EMPLOYEE'] = {"Retired Employee", Color3.fromRGB(255, 85, 0)};
		['GAME TESTER'] = {"Tester", Color3.fromRGB(85, 0, 255)};
		['BALANCE TEAM'] = {"Balance Team", Color3.fromRGB(157, 66, 107)};
	}
}

function returnIndex(number, list) : 'return index'
	local last_index = nil
	
	for index, index_data in pairs(list) do
		
		if not last_index or list[last_index][1] < index_data[1] then

			if index_data[1] <= number then
				last_index = index
			end
		end
	end
	
	return last_index
end

function Handler:Translate(Type : "Kills" | "Escapes", Amount : number, ReturnType : "String" | "Color")
	
	if Handler[Type] then
		
		if Type == 'Kills' then
			local tag = returnIndex(Amount, Handler.Kills)
			
			if ReturnType == 'String' then
				return tag
			else
				return Handler.Kills[tag][2]
			end
		elseif Type == 'Escapes' then
			local tag = returnIndex(Amount, Handler.Escapes)

			if ReturnType == 'String' then
				return tag
			else
				return Handler.Escapes[tag][2]
			end
		end
	else
		warn(Type, 'does not exist!')
		return 'Error!'
	end
end

function Handler:Title_Display_Rank(LocalPlayer : Player, Bool : BoolValue)
	local Name_Title = LocalPlayer.Character:WaitForChild('Head'):WaitForChild('Name'):WaitForChild('TextLabel')
	local Role = LocalPlayer:GetRoleInGroupAsync(3863491)
	
	if not Bool then
		Name_Title.Text = LocalPlayer.DisplayName
		Name_Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		if Handler.Titles[Role] then
			Name_Title.Text = LocalPlayer.DisplayName .. " (" .. Handler.Titles[Role][1] .. ")"
			Name_Title.TextColor3 = Handler.Titles[Role][2]
		end	
	end
end

return Handler