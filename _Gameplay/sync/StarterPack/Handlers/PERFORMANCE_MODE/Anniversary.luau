local Player : Player = game:GetService("Players").LocalPlayer
local Character : Model = Player.Character or Player.CharacterAdded:Wait()
local PrimaryPart

local TweenService : TweenService = game:GetService("TweenService")
local CollectionService : CollectionService = game:GetService("CollectionService")

local Tag = "Balloon" 
local Balloons = {}

local Tweeninfo = TweenInfo.new(
	if math.sin(tick()) ~= 1 then 0.1 else 1---0.1
)

local function BalloonAdded(Object)
	if not Balloons[Object] then
		local Balloon = {
			["Object"] = Object.PrimaryPart
			,["StartPosition"] = Object.PrimaryPart.Position
		}

		Balloons[Object] = Balloon
	end
end

local function BalloonRemoved(Object)
	if Balloons[Object] then
		Balloons[Object] = nil
	end
end


local module = {}


function module.Init()
	--math.sin(tick()) -> it will always return number between 1 and -1
	local PositionHandler = coroutine.create(function()
		while task.wait(math.random(0,0.1)) do
			for _,Balloon in pairs(Balloons) do
				if (PrimaryPart.Position - Balloon.Object.Position).Magnitude <= 100 then
					local Tween = TweenService:Create(Balloon.Object,Tweeninfo,{Position = Balloon.StartPosition + Vector3.new(0,math.sin(tick()),0)})

					Tween:Play()
				end
			end
		end
	end)

	PrimaryPart	= Character.PrimaryPart

	CollectionService:GetInstanceAddedSignal(Tag):Connect(BalloonAdded)
	CollectionService:GetInstanceRemovedSignal(Tag):Connect(BalloonRemoved)

	for _, Object in pairs(CollectionService:GetTagged(Tag)) do
		BalloonAdded(Object)
	end
	
	coroutine.resume(PositionHandler)
end


return module
