local Totems = {}
local BoonsActive = 0
Totems.BoonsActive = {}
Totems.HeartBeatService = game:GetService("RunService").Heartbeat
local this = {}
this.HealingAid = {}
this.HealingAid.PlayerList = {}
this.FreshAir = {}
this.FreshAir.PlayerList = {}
this.Shadows = {}
this.Shadows.PlayerList = {}

local HealingAMod = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild("Blessing: Healing Aid"))
local InShadowsMod = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild("Blessing: In The Shadows"))
local FreshAirMod = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild("Blessing: Fresh Air"))
local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

function GetDistanceToTotem(Player, Totem)
	local PlayerPos: Vector3 = Player.Character:GetPivot().Position
	local TotemPos: Vector3 = Totem:GetPivot().Position
	return (PlayerPos - TotemPos).Magnitude
end

Totems.Connect = function(Survivor, Totem, Typesv)
	for i, g in pairs(Totems.BoonsActive) do
		if g and g.Totem == Totem then
			return nil
		end
	end
	table.insert(Totems.BoonsActive, {Totem = Totem, Types = Typesv, Survivor = Survivor, Run = false, Players = {}})
	BoonsActive += 1
	if not Totems.RunCon then
		Totems.RunCon = Totems.HeartBeatService:Connect(function()
			for i, Totem in pairs(Totems.BoonsActive) do
				if Totem then
					local BoonSpot = Totem.Totem
					local Types = Totem.Types
					local HealingAid = false
					local InTheShadows = false
					local FreshAir = false
					for l, Typ in pairs(Types) do
						if Typ == "HealingAid" then
							HealingAid = true
						elseif Typ == "InTheShadows" then
							InTheShadows = true
						else
							FreshAir = true
						end
					end
					if not Totem.Run then
						if HealingAid then
							local has, Tier = Data_Module:GetPerk("Blessing: Healing Aid", Survivor)
							for g, plr in pairs(game.Teams.Survivor:GetPlayers()) do
								local dist = GetDistanceToTotem(plr, BoonSpot)
								local isAffected = Totem.Players[plr.Name]
								if not Totem.Run then
									if (dist <= HealingAMod.Tier_Ranges[Tier]) then
										if (isAffected) then
											continue
										end	

										Totem.Players[plr.Name] = true
										if (plr.Character:GetAttribute("Healing_Boost")) then
											plr.Character:SetAttribute("Healing_Boosts_Active", plr.Character:GetAttribute("Healing_Boosts_Active") + 1)
											plr.Character:SetAttribute("Healing_Boost", (plr.Character:GetAttribute("Healing_Boost") + (1-HealingAMod.Tiers[Tier])))
										else
											plr.Character:SetAttribute("Healing_Boosts_Active", 1)
											plr.Character:SetAttribute("Healing_Boost", HealingAMod.Tiers[Tier])
										end
										Code_Module:SetEffect("Blessed", plr, true, `Healing_Aid_{Survivor.Name}`)
									else
										if (not isAffected) then
											continue
										end	

										Totem.Players[plr.Name] = false
										if plr.Character:GetAttribute("Healing_Boosts_Active") and (plr.Character:GetAttribute("Healing_Boosts_Active") <= 1) then
											plr.Character:SetAttribute("Healing_Boosts_Active", nil)
											plr.Character:SetAttribute("Healing_Boost", nil)
										else
											if (plr.Character:GetAttribute("Healing_Boosts_Active")) then
												plr.Character:SetAttribute("Healing_Boosts_Active", plr.Character:GetAttribute("Healing_Boosts_Active") - 1)
												plr.Character:SetAttribute("Healing_Boost", (plr.Character:GetAttribute("Healing_Boost") - (1-HealingAMod.Tiers[Tier])))
											else
												plr.Character:SetAttribute("Healing_Boosts_Active", nil)
												plr.Character:SetAttribute("Healing_Boost", nil)
											end
										end
										Code_Module:SetEffect("Blessed", plr, nil, `Healing_Aid_{Survivor.Name}`)
									end
								end
							end
						end
						if FreshAir then
							local has, Tier = Data_Module:GetPerk("Blessing: Fresh Air", Survivor)
							for i, plr in pairs(game.Teams.Survivor:GetPlayers()) do
								local dist = GetDistanceToTotem(plr, BoonSpot)
								local isAffected = Totem.Players[plr.Name]
								if not Totem.Run then
									if (dist <= FreshAirMod.Range) then
										if (isAffected) then
											continue
										end	

										Totem.Players[plr.Name] = true
										Code_Module:SetEffect("Rejuvenation", plr, {-1, FreshAirMod.Tiers[Tier]}, `Fresh_Air_{Survivor.Name}`)
										Code_Module:SetEffect("Blessed", plr, true, `Fresh_Air_{Survivor.Name}`)
									else
										if (not isAffected) then
											continue
										end	

										Totem.Players[plr.Name] = false
										Code_Module:SetEffect("Rejuvenation", plr, nil, `Fresh_Air_{Survivor.Name}`)
										Code_Module:SetEffect("Blessed", plr, nil, `Fresh_Air_{Survivor.Name}`)
									end
								end
							end
						end
						if InTheShadows then
							local has, Tier = Data_Module:GetPerk("Blessing: In The Shadows", Survivor)
							for i, plr in pairs(game.Teams.Survivor:GetPlayers()) do
								local dist = GetDistanceToTotem(plr, BoonSpot)
								local isAffected = Totem.Players[plr.Name]
								if not Totem.Run then
									if (dist <= InShadowsMod.Tiers[Tier]) then
										if (isAffected) then
											continue
										end	

										Totem.Players[plr.Name] = true
										Code_Module:SetEffect("Hidden", plr, -1, `In_The_Shadows_{Survivor.Name}`)
										Code_Module:SetEffect("Blessed", plr, true, `In_The_Shadows_{Survivor.Name}`)
									else
										if (not isAffected) then
											continue
										end	

										Totem.Players[plr.Name] = false
										Code_Module:SetEffect("Hidden", plr, nil, `In_The_Shadows_{Survivor.Name}`)
										Code_Module:SetEffect("Blessed", plr, nil, `In_The_Shadows_{Survivor.Name}`)
									end
								end
							end
						end
					end
				end
			end
		end)
	end
end

Totems.Disconnect = function(Totem)
	for i, Boons in pairs(Totems.BoonsActive) do
		if Boons then
			if Boons.Totem == Totem then
				Boons.Run = true
				local Types2 = {Heal = false, Shadow = false, Vigil = false}
				for l, Types in pairs(Boons.Types) do
					for g, plr in pairs(game.Teams.Survivor:GetPlayers()) do
						if Types == "HealingAid" then
							Types2.Heal = true
							Boons.Players[plr.Name] = false
							if plr.Character:GetAttribute("Healing_Boosts_Active") and (plr.Character:GetAttribute("Healing_Boosts_Active") <= 1) then
								plr.Character:SetAttribute("Healing_Boosts_Active", nil)
								plr.Character:SetAttribute("Healing_Boost", nil)
							else
								if (plr.Character:GetAttribute("Healing_Boosts_Active")) then
									plr.Character:SetAttribute("Healing_Boosts_Active", plr.Character:GetAttribute("Healing_Boosts_Active") - 1)
									plr.Character:SetAttribute("Healing_Boost", (plr.Character:GetAttribute("Healing_Boost") - (1-HealingAMod.Tiers[this.Tier])))
								else
									plr.Character:SetAttribute("Healing_Boosts_Active", nil)
									plr.Character:SetAttribute("Healing_Boost", nil)
								end
							end
							Code_Module:SetEffect("Blessed", plr, nil, `Healing_Aid_{Boons.Survivor.Name}`)
						end
						if Types == "FreshAir" then
							Types2.Vigil = true
							Boons.Players[plr.Name] = false
							Code_Module:SetEffect("Rejuvenation", plr, nil, `Fresh_Air_{Boons.Survivor.Name}`)
							Code_Module:SetEffect("Blessed", plr, nil, `Fresh_Air_{Boons.Survivor.Name}`)
						end
						if Types == "InTheShadows" then
							Types2.Shadow = true
							Boons.Players[plr.Name] = false
							Code_Module:SetEffect("Hidden", plr, nil, `In_The_Shadows_{Boons.Survivor.Name}`)
							Code_Module:SetEffect("Blessed", plr, nil, `In_The_Shadows_{Boons.Survivor.Name}`)
						end
					end
				end
				local plr = Boons.Survivor
				if Types2.Heal == "HealingAid" then
					Boons.Players[plr.Name] = false
					if plr.Character:GetAttribute("Healing_Boosts_Active") and (plr.Character:GetAttribute("Healing_Boosts_Active") <= 1) then
						plr.Character:SetAttribute("Healing_Boosts_Active", nil)
						plr.Character:SetAttribute("Healing_Boost", nil)
					else
						if (plr.Character:GetAttribute("Healing_Boosts_Active")) then
							plr.Character:SetAttribute("Healing_Boosts_Active", plr.Character:GetAttribute("Healing_Boosts_Active") - 1)
							plr.Character:SetAttribute("Healing_Boost", (plr.Character:GetAttribute("Healing_Boost") - (1-HealingAMod.Tiers[this.Tier])))
						else
							plr.Character:SetAttribute("Healing_Boosts_Active", nil)
							plr.Character:SetAttribute("Healing_Boost", nil)
						end
					end
					Code_Module:SetEffect("Blessed", plr, nil, `Healing_Aid_{plr.Name}`)
				end
				if Types2.Vigil == "FreshAir" then
					Boons.Players[plr.Name] = false
					Code_Module:SetEffect("Rejuvenation", plr, nil, `Fresh_Air_{plr.Name}`)
					Code_Module:SetEffect("Blessed", plr, nil, `Fresh_Air_{plr.Name}`)
				end
				if Types2.Shadow == "InTheShadows" then
					Boons.Players[plr.Name] = false
					Code_Module:SetEffect("Hidden", plr, nil, `In_The_Shadows_{plr.Name}`)
					Code_Module:SetEffect("Blessed", plr, nil, `In_The_Shadows_{plr.Name}`)
				end
				table.remove(Totems.BoonsActive, i)
				break
			end
		end
	end
	BoonsActive -= 1
end

Totems.Search = function(Player, Totem, Types)
	for i, g in pairs(Totems.BoonsActive) do
		if g then
			if g.Totem == Totem then
				Totems.Disconnect(Totem)
				break
			end
		end
	end
	Totems.Connect(Player, Totem, Types)
end

local Event = Instance.new("RemoteEvent", game.ReplicatedStorage["-LockerAuras"])
Event.Name = "Boon_Handler"

Event.OnServerEvent:Connect(function(Player, Totem, Types, Reason)
	if Reason == "Disconnect" then Totems.Disconnect(Totem) elseif Reason == "Connect" then Totems.Search(Player, Totem, Types) end
end)

local d = Instance.new("BindableEvent", game.ReplicatedStorage["-LockerAuras"])
d.Name = "ServerDisconnect"

d.Event:Connect(function(Totem)
	Totems.Disconnect(Totem)
end)
