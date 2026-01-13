local BaseValues = require(game.ReplicatedStorage.Modules.BaseValues)

local this = {}

function this:setupAttributes(Player_Values, Role)
	this:createAttributes(Player_Values, BaseValues[Role])
end

function this:createAttributes(Player_Values, Values)
	
	for key, value in pairs(Values) do
		if (typeof(value) == "table") then
			local PlayerConfig = Instance.new("Configuration")
			PlayerConfig.Name = key
			PlayerConfig.Parent = Player_Values
			
			this:createAttributes(Player_Values[key], Values[key])
		else
			Player_Values:SetAttribute(key, value)
		end
	end

end

return this
