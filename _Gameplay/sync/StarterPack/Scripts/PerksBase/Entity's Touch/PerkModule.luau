local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("Entity's Touch"))

local this = {}

this.Player = nil
this.initialized = false
this.Tier = 0

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier

	coroutine.resume(coroutine.create(function()
		local g = 0
		local d = 1

		repeat task.wait()
		until g == d or (Player.Backpack:WaitForChild("Scripts"):WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)

		local Timer = Perk_Module.Tiers[Tier]

		local List = {}

		local Third = nil
		local Second = nil
		local First = nil
		for i, v in pairs(workspace:GetChildren()) do
			if (string.find(v.Name, "Generator")) then
				if First then
					if (v.RootPart.Position - Player.Character.PrimaryPart.Position).Magnitude < (First.RootPart.Position - Player.Character.PrimaryPart.Position).Magnitude then
						if Second then
							if (v.RootPart.Position - Player.Character.PrimaryPart.Position).Magnitude < (Second.RootPart.Position - Player.Character.PrimaryPart.Position).Magnitude then
								if Third then
									if (v.RootPart.Position - Player.Character.PrimaryPart.Position).Magnitude < (Third.RootPart.Position - Player.Character.PrimaryPart.Position).Magnitude then
									else
										Third = v
									end
								else
									Third = v
								end
							else
								Third = Second
								Second = v
							end
						else
							Second = v
						end
					else
						Third = Second
						Second = First
						First = v
					end
				else
					First = v
				end
			end
		end
		List = {First, Second, Third}

		for i, v in pairs(List) do
			_G.GetObjectValue(v.Name, "Blocked").Add("EntitysTouch", 1, -1)
			v:SetAttribute("EntitysTouch", true)
		end

		script.Parent:SetAttribute("Timer", Timer)
		script.Parent:SetAttribute("Max", Timer)

		script.Parent:SetAttribute("Active", true)

		repeat task.wait(1) 
			Timer -= 1
			script.Parent:SetAttribute("Timer", Timer)
			if Perk_Module.BlockOnDown == true then
				for Numbers, Players in pairs(game.Players:GetPlayers()) do
					if Players then
						if Players.Character then
							if Players.Backpack:WaitForChild("Scripts"):WaitForChild("values"):WaitForChild("HealthState").Value == 0 then
								Timer = 0
							end
						end
					end
				end
			end
		until Timer <= 0
		script.Parent:SetAttribute("Timer", Timer)

		for i, v in pairs(List) do
			_G.GetObjectValue(v.Name, "Blocked").Remove("EntitysTouch")
			v:SetAttribute("EntitysTouch", nil)
		end

		script.Parent:SetAttribute("Active", false)
	end))

	return
end

return this