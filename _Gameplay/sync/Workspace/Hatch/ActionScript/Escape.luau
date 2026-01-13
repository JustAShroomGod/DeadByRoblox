local TweenService = game:GetService('TweenService')

local Code = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Match : Folder = game.ReplicatedStorage:WaitForChild('Match')
local Hatch = script.Parent.Parent
local module = {}

function RetrievePlayerValue(Player : Player)
	return Match:WaitForChild('Players'):WaitForChild(Player.Name)
end

function Invisible(Character : Model?)

	for _,Part in pairs(Character:GetDescendants()) do

		if Part:IsA('BasePart') then
			Part.Transparency = 1
		elseif Part.ClassName == "Accessory" or Part.ClassName == "Decal" then
			Part:Destroy()
		end
	end
end

function module:Escape(Player : Player, Escape)
	local match_player = RetrievePlayerValue(Player)
	local rootPart = Player.Character.PrimaryPart

	rootPart.Anchored = true

	local thisCFrame = CFrame.new(Hatch.HumanoidRootPart.Position.X, rootPart.Position.Y, Hatch.HumanoidRootPart.Position.Z)
	rootPart.CFrame = CFrame.new(rootPart.Position, thisCFrame.Position)

	local JumpTrack = Player.Character:WaitForChild('Humanoid'):LoadAnimation(script:WaitForChild('Hop'))

	local Connection Connection = JumpTrack.KeyframeReached:Connect(function(frame)

		if frame == "AirFrame" then
			TweenService:Create(rootPart, TweenInfo.new(1), {
				CFrame = rootPart.CFrame * CFrame.new(0, 0, -(rootPart.Position - thisCFrame.Position).Magnitude)
			}):Play()
		end

		if JumpTrack.TimePosition > (JumpTrack.Length - .3) then
			Connection:Disconnect()

			Invisible(Player.Character)
			match_player:SetAttribute("Escaped", true)
			Code:AddEscape(Player)
		end
	end)

	JumpTrack:Play()
	JumpTrack:AdjustSpeed(3.37)
end

return module
