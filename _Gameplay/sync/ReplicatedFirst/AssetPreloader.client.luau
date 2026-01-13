local ContentProvider = game:GetService("ContentProvider")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local assets = {}

function loop(last)
	
	for _, child in pairs (last:GetChildren()) do
		local isAsset = false
		local list = {"ImageLabel", "Sound"}
		
		for _, index0 in pairs(list) do
			if child.ClassName == index0 then
				isAsset = true
			end
		end
		
		if isAsset then
			table.insert(assets, child)
		end
		
		loop(child)
	end
end

loop(workspace)
loop(playerGui)

ContentProvider:PreloadAsync(assets)
