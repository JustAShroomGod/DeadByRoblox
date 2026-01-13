local Events = require(game.ServerScriptService["Event System"].Events)

local PerkUtils = {}

function PerkUtils.SetHex(Player: Player)
	
	local Totems = {}
	
	for i, v in workspace:GetChildren() do
		if (string.find(v.Name, "Totem")) then
			local Totem_Effect = v.Panel.Effect
			local Totem_Holder = Totem_Effect.Holder
			
			if (Totem_Holder.Value ~= "" or Totem_Effect.Value ~= "Dull") then
				continue
			end
			
			table.insert(Totems, v)
		end
	end
	
	if (#Totems > 0) then
		local random = math.random(1, #Totems)
		local chosen = Totems[random]
		
		local Totem_Effect = chosen.Panel.Effect
		local Totem_Holder = Totem_Effect.Holder
		
		Totem_Effect.Value = "Curse"
		Totem_Holder.Value = Player.Name
		
		return chosen, true
	end
	
	return nil, false
end

function PerkUtils.TransferHex(Player, Totem, NewTotem)
	local Totem_Effect = Totem.Panel.Effect
	local Totem_Holder = Totem_Effect.Holder
	
	local NewTotem_Effect = NewTotem.Panel.Effect
	local NewTotem_Holder = NewTotem_Effect.Holder
	
	NewTotem_Effect.Value = "Curse"
	NewTotem_Holder.Value = Player.Name
	
	Totem_Effect.Value = "Dull"
	Totem_Holder.Value = ""
	
	Events.Gameplay.onTotemTransfer:Fire(Totem, NewTotem)
end

function PerkUtils.GetBlessing(Player: Player)

	for i, v in workspace:GetChildren() do
		if (string.find(v.Name, "Totem")) then
			local Totem_Effect = v.Panel.Effect
			local Totem_Holder = Totem_Effect.Holder

			if (Totem_Holder.Value ~= Player.Name or Totem_Effect.Value ~= "Blessing") then
				continue
			end

			return v
		end
	end

	return nil
end

function PerkUtils.IsHexStanding(Totem)
	
	if (Totem == nil) then
		return false
	end
	
	local Totem_Effect = Totem.Panel.Effect
	local Totem_State = Totem.Panel.State
	
	return (Totem_Effect.Value == "Curse" and Totem_State.Value == 0)
end

function PerkUtils.IsBoonStanding(Totem)

	if (Totem == nil) then
		return false
	end

	local Totem_Effect = Totem.Panel.Effect
	local Totem_State = Totem.Panel.State

	return (Totem_Effect.Value == "Blessing" and Totem_State.Value == 0)
end

return PerkUtils
