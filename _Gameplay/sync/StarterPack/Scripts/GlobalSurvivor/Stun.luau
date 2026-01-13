local Player = game.Players.LocalPlayer
local Character = Player.Character
local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
local Animator: Animator = Humanoid.Animator
local RootPart: Part = Character.PrimaryPart

local Backpack = Player:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")
local Values = Scripts:WaitForChild("values")
local Action = Values:WaitForChild("Action")

local PlayerScripts = Player.PlayerScripts
local Controls = require(PlayerScripts.PlayerModule):GetControls()

local StunTrack: AnimationTrack = nil
local StunAnim: Animation = script.Stun_Animation

local RemoteEvents = game.ReplicatedStorage.RemoteEvents
local betterUpdate = RemoteEvents:WaitForChild("NewPropertie")

local Modules = {
	Data = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'));
	Code = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Code'));
}

function Obfuscate(TYPE, VALUE1, VALUE2)
	local tablev = {}
	local List = {"Bbh1O", "D9v8", "Dbh1O", "Dvh1O", "Dhv8"}

	TYPE = string.lower(TYPE)

	if TYPE == 'string' then
		TYPE = 'S101'
	elseif TYPE == 'object' then
		TYPE = 'O101'
	elseif TYPE == 'number' then
		TYPE = 'I101'
	elseif TYPE == 'bool' then
		TYPE = 'B101'
	end

	local Packaged = {
		['C22'] = TYPE;
		['C21'] = VALUE1;
		['C20'] = VALUE2;
	}

	for _,key in pairs(List) do
		tablev[key] = Packaged
	end

	betterUpdate:FireServer(tablev)
end

local Stun = {}

function Stun.Apply(Duration)
	local IFrame, AFrame = Modules.Code:GetEffect("IFrame"), Modules.Code:GetEffect("AFrame")
	
	if ((IFrame and IFrame.Active) or (AFrame and AFrame.Active) or Modules.Code:IsDown(Player) or Modules.Code:IsHooked(Player)) then
		return
	end
	
	RootPart.Anchored = true
	Obfuscate("string", Action, "Stun")
	
	StunTrack = Animator:LoadAnimation(StunAnim)
	StunTrack:Play(0, 1, (1 / Duration))
	
	StunTrack.Ended:Connect(function()
		RootPart.Anchored = false
		Obfuscate("string", Action, "Nothing")
	end)
	
end

return Stun
