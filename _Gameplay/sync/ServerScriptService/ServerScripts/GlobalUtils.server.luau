function Initialize()
	
	_G.Utils = {}

	_G.Utils.GetTableSize = function(table)
		local size = 0

		for _, v in pairs(table) do
			size += 1
		end

		return size
	end
end

game.ReplicatedStorage.Match.Started.Changed:Once(Initialize)

