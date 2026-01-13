local UserInputService : UserInputService, ReplicatedStorage : ReplicatedStorage = game:GetService("UserInputService"), game:GetService("ReplicatedStorage")

local IconManager = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Icon"))

local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local Defaults = 1;

local Action = {
	Key = "Interact11";
	ActionName = "#MatchMenu";
	Priority = 1; -- scale of 1-5
	ActionInfo = {},
	Debounces = {
		InputEnter = tick();
	}
}

local function MouseCheck()
	if PlayerGui:WaitForChild("HUD"):WaitForChild("MatchMenu").Visible then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	else
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
	end
end

local function Init()	
	if IconManager.getIcon("Menu") then return end

	local Icon = IconManager.new()

	Icon:setName("Menu")
	Icon:setLabel("Menu")

	Icon.selected:Connect(function()
		PlayerGui:WaitForChild("HUD"):WaitForChild("MatchMenu").Visible = not PlayerGui:WaitForChild("HUD"):WaitForChild("MatchMenu").Visible
		MouseCheck()
	end)

	Icon.deselected:Connect(function()
		PlayerGui:WaitForChild("HUD"):WaitForChild("MatchMenu").Visible = not PlayerGui:WaitForChild("HUD"):WaitForChild("MatchMenu").Visible
		MouseCheck()
	end)
end

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false

	if Player.Character:GetAttribute("IntroDone") then
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < .1 then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]

	PlayerGui:WaitForChild("HUD"):WaitForChild("MatchMenu").Visible = not PlayerGui:WaitForChild("HUD"):WaitForChild("MatchMenu").Visible
	MouseCheck()
end

function Action:Process(...) : boolean | "Returns true if this action can be ran"
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]

	if Constraints(actionList, modules) then
		return true
	end

	return false
end

Init()

return Action
