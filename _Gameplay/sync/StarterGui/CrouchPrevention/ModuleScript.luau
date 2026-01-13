local module = 
	{
		runfun = function()
			coroutine.resume(coroutine.create(function()
				local v = game.ReplicatedStorage:WaitForChild("Game_Data"):WaitForChild("Perks"):WaitForChild("Survivor")
				for i, g in pairs(v.Parent:GetDescendants()) do
					if (g:IsA("ModuleScript")) then
						require(g).Colors = {Color3.fromRGB(180, 180, 0), Color3.fromRGB(0,170,0), Color3.fromRGB(81, 0, 77)}
					end
				end
				for i, b in pairs(script.Parent.Parent:WaitForChild("HUD"):WaitForChild("Perk_Display"):WaitForChild("Perks"):WaitForChild("RATIO-MAKER"):GetDescendants()) do
					if b then
						if b.Name == "PerkImage" then
							b.Size = UDim2.new(1,0,1,0)
						end
					end
				end
				require(v:WaitForChild("DeadHard")).Image = "http://www.roblox.com/asset/?id=2021646063"
				require(v:WaitForChild("DecisiveStrike")).Image = "http://www.roblox.com/asset/?id=1756407278"
				require(v:WaitForChild("SprintBurst")).Image = "http://www.roblox.com/asset/?id=2021645195"
				require(v:WaitForChild("SelfCare")).Image = "http://www.roblox.com/asset/?id=2021049075"
				require(v:WaitForChild("ObjectOfObsession")).Image = "http://www.roblox.com/asset/?id=2031797052"
				require(v:WaitForChild("BorrowedTime")).Image = "http://www.roblox.com/asset/?id=2420685312"
				require(v:WaitForChild("Unbreakable")).Image = "http://www.roblox.com/asset/?id=2424527819"
				require(v:WaitForChild("NoMither")).Image = "http://www.roblox.com/asset/?id=2428997716"
				require(v.Parent:WaitForChild("Killer"):WaitForChild("SpiritFury")).Image = "http://www.roblox.com/asset/?id=2644511608"
				require(v:WaitForChild("WellMakeIt")).Image = "http://www.roblox.com/asset/?id=2803871560"
				require(v:WaitForChild("HeadOn")).Image = "http://www.roblox.com/asset/?id=3416574750"
				for i, g in pairs(v.Parent.Parent:WaitForChild("Items"):GetChildren()) do
					if (string.match(g.Name, "Flashlight")) then
						require(g).Image = "http://www.roblox.com/asset/?id=2558276960"
					elseif string.match(g.Name, "Medkit") then
						require(g).Image = "http://www.roblox.com/asset/?id=2558276968"
					elseif string.match(g.Name, "Toolbox") then
						require(g).Image = "http://www.roblox.com/asset/?id=2558276972"
					end
				end
			end))
		end,
	}

return module