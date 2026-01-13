local Blocked = false
local Tier = 0

local Modules = {
	Data = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'));
	Code = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'));
	Perk_Module = require(game.ReplicatedStorage:WaitForChild("Game_Data"):WaitForChild("Perks"):WaitForChild("Killer"):WaitForChild("Curse: Lockdown"))
}

script.Parent.Event.Event:Connect(function(Command, Player)
	if Command == "Cleansed_Totem" then
		Blocked = true
	elseif Command == "Reactivated_Totem" then
		Blocked = false
	elseif Command == "Hooked_Player" then
		if Blocked == false then
			local Tables = {}
			for i, v in pairs(workspace:GetDescendants()) do
				if (string.find(v.Name, "Generator")) and (v:IsA("Model")) and (v:FindFirstChild("Panel") ~= nil) then
					table.insert(Tables, v.Panel.Progress)
				end
			end
			local i = 0
			local highnumber = -1
			local list = {}
			for Number, Gens in pairs(Tables) do
				if Gens then
					print(highnumber)
					print(Gens)
					print(Gens.Value)
					if Gens.Value > highnumber then
						list = {Gens}
						i = 1
						highnumber = Gens.Value
					elseif Gens.Value == highnumber then
						i += 1
						table.insert(list, Gens)
					end
				end
			end
			local haslock, tierlock = Modules.Data:GetPerk("Curse: Lockdown", Player)
			if i == 1 then

				if (list[1].Value >= 1000) then
					return
				end

				list[1].Value -= Modules.Perk_Module.Tiers[tierlock]
			else

				local random = math.random(1,#list)

				if (list[random].Value >= 1000) then
					return
				end

				list[random].Value -= Modules.Perk_Module.Tiers[tierlock]
			end
		end
	end
end)