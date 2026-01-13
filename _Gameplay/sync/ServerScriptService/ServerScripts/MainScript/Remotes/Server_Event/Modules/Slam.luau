local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScripts = game:GetService('ServerScriptService')
local TweenService = game:GetService('TweenService')
local Teams = game:GetService("Teams")

local code_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local data_module = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data')) -- best module in game ;)

local Killer_Module = require(ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Killers'):WaitForChild('Reaper'))

local module = {}

--
function InfectPlayers(Killer : Player)
	local function Infect(User : Model) : "Soul-Binds"
		User:SetAttribute("Soul_Bound", Killer_Module.Soul_Bound.Duration..':'..workspace:GetServerTimeNow())
	end

	for _, otherplayer in pairs(Teams.Survivor:GetPlayers()) do
		local othercharacter = otherplayer.Character
		if othercharacter == Killer.Character or not othercharacter:IsA('Model') then continue end
		if not othercharacter:FindFirstChildOfClass('Humanoid') then continue end -- confirmed to be a object with humanoid that is not us / survivors or animation dummy
		if othercharacter:FindFirstChild("Panel") or othercharacter:FindFirstChild("AnimSaves") then continue end -- not a interaction object or typical animation dummy

		if (othercharacter:GetPivot().Position - Killer.Character:GetPivot().Position).Magnitude <= Killer_Module.Soul_Bound.Radius then
			local Player = game.Players:FindFirstChild(othercharacter.Name)

			if Player then
				local Hooked = Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Hooked')

				if not Hooked.Value then -- if not on hook can be bound
					Infect(othercharacter)
				end

				data_module:GiveBlood(Killer, 500, "Deviousness","SOUL BOUND")
			else -- is a bot
				Infect(othercharacter)
			end
		end
	end
end

function Wave_Blast(Killer : Player) : "Blast A Wave of Energy"
	local Charges = string.split(Killer.Character:GetAttribute("Power"), ':')

	Killer.Character:SetAttribute("Power", (tonumber(Charges[1]) - 1)..':'..Charges[2])

	local s = Killer.Character.PrimaryPart:FindFirstChild("Slam") -->> SLAM NOISE << --

	if s then
		s:Remove()
	end

	s = script.Parent.Parent:WaitForChild('Sounds'):WaitForChild('Slam'):Clone()
	s.Parent = Killer.Character.PrimaryPart

	s:Play()

	data_module:GiveBlood(Killer, 1000, "Deviousness", "WAVE SENT")

	local wave = script.Parent.Parent:WaitForChild('Particles'):WaitForChild('Shock_Wave'):Clone()
	wave:PivotTo(Killer.Character:GetPivot())
	wave.Parent = workspace

	local tween = TweenService:Create(wave, TweenInfo.new(Killer_Module.Soul_Bound.Radius/Killer_Module.Soul_Bound.Wave_Speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 0,
		Size = Vector3.new(Killer_Module.Soul_Bound.Radius * 2, Killer_Module.Soul_Bound.Radius * 2, Killer_Module.Soul_Bound.Radius * 2),
	})
	tween:Play()
	tween.Completed:Wait()

	InfectPlayers(Killer)

	tween = TweenService:Create(wave, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1,
	})
	tween:Play()
	tween.Completed:Wait()

	wave:Remove()
end

--

function module:Fire(Player : Player, Arguments : "table")
	local Killer, Using = Player, Arguments[2]
	local Backpack = Player:WaitForChild('Backpack'):WaitForChild('Scripts')
	local perkBase, playerValues = Backpack:WaitForChild('PerksBase'), Backpack:WaitForChild('values')

	local Command : boolean = Arguments[2]

	if Command == "Start_Slam" then

		local Charges = string.split(Player.Character:GetAttribute('Power'), ':')

		if tonumber(Charges[1]) <= 0 then return end
		local Length = (Killer_Module.Timings.Slam + 0)

		_G.GetValue(Player.Name, "DisruptiveActions"):Add("Ability", 1, nil)
		Player.Character:SetAttribute("Animation", "")
		Length -= 0.1
		task.wait(0.1)

		code_module:SetEffect("Slow", Player, {-1, (Killer_Module.Speeds.Slam_Reduction * 100)}, 'Reaper_Slam') -->> apply slowness

		Player.Character:SetAttribute("Animation_Time", workspace:GetServerTimeNow() + Length)
		Player.Character:SetAttribute("Animation", "Slam")
		Player.Character:SetAttribute("Power_State", "Animation")
		playerValues.Action.Value = "Slamming"
		playerValues.KillerAction.Value = "Slamming"

		--[[local s = Player.Character.PrimaryPart:FindFirstChild("Sword Unsheath")

		if s then
			s:Remove()
		end

		s = script.Parent.Parent:WaitForChild('Sounds'):WaitForChild('Sword Unsheath'):Clone()
		s.Parent = Player.Character.PrimaryPart
		s:Play()]]--

		task.wait(Length - (Length * 0.14))
		Length = (Length * .14)

		Wave_Blast(Player)

		task.wait(Length)

		Player.Character:SetAttribute("Power_State", "Slamming") -- knock us back to idle
	elseif Command == "Finish_Slam" then
		code_module:SetEffect("Slow", Player, nil, 'Reaper_Slam') -->> remove slowness

		--TODO: CREATE ADDON TO APPLY HASTE AFTER SLAMS IN FUTURE --
		if Killer_Module.Speeds.Post_Slam > 0 then
			code_module:SetEffect("Haste", Player, {10, (Killer_Module.Speeds.Post_Slam * 5)}, 'Slam_Haste')
		end

		_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")
		Player.Character:SetAttribute("Power_State", "Idle") -- knock us back to idle

		playerValues.Action.Value = "Nothing"
		playerValues.KillerAction.Value = "Nothing"
	elseif Command == "Cancel_Slam" then

		_G.GetValue(Player.Name, "DisruptiveActions"):Remove("Ability")
		Player.Character:SetAttribute("Power_State", "Idle") -- knock us back to idle
		code_module:SetEffect("Slow", Player, nil, 'Reaper_Slam') -->> remove slowness

		--playerValues.Action.Value = "Nothing"
		--playerValues.KillerAction.Value = "Nothing"
	end

	--[[if Using and Player.Character and Player.Character:GetAttribute("Power") then -- make sure we have th charges
		local Charges = string.split(Player.Character:GetAttribute('Power'), ':')
		
		if tonumber(Charges[1]) > 0 then
			playerValues.KillerAction.Value = "Slamming"
			Slam(Killer, Backpack, perkBase, playerValues)
		end
	elseif playerValues.KillerAction.Value == "Slamming" then -- released m2 / while still cloaking
		playerValues.KillerAction.Value = "Cancel Slam"
	end]]--
end

return module