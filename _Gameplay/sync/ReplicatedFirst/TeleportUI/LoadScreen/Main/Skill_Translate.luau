local Handler = {
	Kills = {
		Noob = {0, Color3.fromRGB(130, 222, 255)};
		Novice = {25, Color3.fromRGB(255, 247, 14)};
		Pro = {100, Color3.fromRGB(32, 255, 28)};
		Master = {200, Color3.new(255,255,255)};
		Godly = {250, Color3.fromRGB(175, 37, 255)};
		Omega = {500, Color3.fromRGB(255, 0, 0)};
		Overlord = {1000, Color3.fromRGB(0,0,0)};
		Unstoppable = {2000, Color3.fromRGB(0, 0, 255)}
	},
	Escapes = {
		Noob = {0, Color3.fromRGB(130, 222, 255)};
		Novice = {25, Color3.fromRGB(255, 247, 14)};
		Pro = {100, Color3.fromRGB(32, 255, 28)};
		Master = {200, Color3.new(255,255,255)};
		Godly = {250, Color3.fromRGB(175, 37, 255)};
		Omega = {500, Color3.fromRGB(255, 0, 0)};
		Overlord = {750, Color3.fromRGB(0, 0, 0)};
		Unstoppable = {1000, Color3.fromRGB(0, 0, 255)}
	},
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
				return tag .. ' Killer'
			else
				return Handler.Kills[tag][2]
			end
		elseif Type == 'Escapes' then
			local tag = returnIndex(Amount, Handler.Escapes)

			if ReturnType == 'String' then
				return tag .. ' Survivor'
			else
				return Handler.Escapes[tag][2]
			end
		end
	else
		warn(Type, 'does not exist!')
		return 'Error!'
	end
end

return Handler
