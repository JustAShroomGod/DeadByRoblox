local Players, ReplicatedStorage, RunService = game:GetService('Players'), game:GetService('ReplicatedStorage'), game:GetService('RunService')
local CoolDown : StringValue, Sample = script.Parent:WaitForChild('COOLDOWN'), script:WaitForChild('Sample')

local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Guardian'))

local Player : Player = Players.LocalPlayer
local Scripts = Player:WaitForChild('Backpack'):WaitForChild('Scripts')

local moduleStorage : Folder = ReplicatedStorage:WaitForChild('Modules')

local IsKiller : BoolValue = Scripts:WaitForChild('Killer')

local Modules = {
	Data = require(moduleStorage:WaitForChild('Data'))
}

local Settings = {}

local HasGuardian, GuardianTier = Modules.Data:GetPerk("Guardian")


if HasGuardian and not IsKiller.Value then
	local Links = {}

	local function FormLink(Character : Player, Player2 : Player) : "Forms Link Connection between point a and point b"
		if not Player2 then return end
		local Character2 = Player2.Character
		local A1, A2 = Instance.new('Attachment', Character:WaitForChild('LowerTorso')), Instance.new('Attachment', Character2:WaitForChild('LowerTorso'))
		local Beam = script:WaitForChild('Sample'):Clone()
		local healthstate = Players:WaitForChild(Character2.Name):WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState')
		local perks = Player2:WaitForChild('Data'):WaitForChild('Perks'):WaitForChild('Survivor')

		Beam.Enabled = false
		Beam.Parent = workspace
		Beam.Attachment0 = A1
		Beam.Attachment1 = A2

		Links[Character2.Name] = {
			Beam = Beam;
			Character = Character2;
			Health = healthstate;
			Perks = perks;
		}
	end

	RunService.Heartbeat:Connect(function()
		if IsKiller.Value then script.Disabled = true return end
		if not Player.Character then return end

		local OurHealth = Scripts:WaitForChild('values'):WaitForChild('HealthState').Value

		for _, plr : Player in pairs(game.Teams:WaitForChild('Survivor'):GetPlayers()) do

			if plr ~= Player then

				if not Links[plr.Name] then
					FormLink(Player.Character, plr)
				end
			end
		end

		for person, tbl in pairs(Links) do

			coroutine.resume(coroutine.create(function()
				script:WaitForChild("RemoteEvent"):FireServer({tbl.Character.Name, tbl.Beam.Enabled, Player.Character.PrimaryPart, tbl.Character.PrimaryPart})
			end))

			local hasguard = false

			for _, perkslot in pairs(tbl.Perks:GetChildren()) do
				if perkslot.Name == 'Guardian' then
					hasguard = true
				end
			end

			if not Player.Character or not Player.Character.PrimaryPart or not tbl.Character or not tbl.Character.PrimaryPart then
				tbl.Beam.Enabled = false
				continue
			end

			if OurHealth >= 2 -- we can give the healthstate
				and (workspace:GetServerTimeNow() - tonumber(CoolDown.Value)) >= Perk_Module.Cooldown -- time is elapsed
				and tbl.Health.Value > 0 -- they have some life to protect
				and not hasguard -- they do not have guardian equipped
				and (Player.Character.PrimaryPart.Position - tbl.Character.PrimaryPart.Position).Magnitude <= Perk_Module.Tiers[GuardianTier or 1] then

				tbl.Beam.Enabled = true
			else
				tbl.Beam.Enabled = false
			end
		end
	end)
end