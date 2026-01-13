local Player = game:GetService("Players").LocalPlayer

local Data = require(game.ReplicatedStorage.Modules.Data)
local Anniversary = require(script:WaitForChild("Anniversary"))	

game.ReplicatedStorage.Match.Started.Changed:Once(function()
	local Settings = Data:GetSettings()
	
	if Settings.PERFORMANCE_MODE then
		game.Lighting.GlobalShadows = false

		for _,v in pairs(workspace:GetDescendants()) do
			if v:IsA("Part") or v:IsA("BasePart") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
				v.CastShadow = false
				v.Material = Enum.Material.SmoothPlastic

				if #v:GetChildren() > 0 then
					for _,child in pairs(v:GetChildren()) do
						if child:IsA("Texture") then
							child:Destroy()
						end
					end
				end
			end 
		end
	else
		Anniversary.Init()
	end
end)