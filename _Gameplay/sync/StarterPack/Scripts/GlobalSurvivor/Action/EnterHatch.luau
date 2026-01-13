local Player = game.Players.LocalPlayer

local Action = {
	Key = "Interact2";
	ActionName = "ESCAPE (HATCH)";
	InteractDistance = 5.5;
	Priority = 3; -- scale of 1-5
	ActionInfo = {

	},
	Debounces = {
		InputEnter = tick()
	}
}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Hatch : Model = actionList.Hatch
	local Current_User = Hatch:GetAttribute("User")
	if not Hatch then return false end
	
	if (Current_User and Current_User ~= "" and Current_User ~= Player.Name) then return end -- Can not input hatch commands if someone else is using
	
	if (Hatch:WaitForChild("HumanoidRootPart").CFrame.Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance -- Distance Check
		and currentValues.Action.Value == "Nothing"
		and not currentValues.Hooked.Value
		and not currentValues.Holded.Value
		and not Hatch:GetAttribute("User")
		and Hatch:GetAttribute('State') == "Open" then
		
		CanRun = true
	end
	
	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 5 then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	
	remoteList.Hatch:FireServer("Use")
end

function Action:Process(...) : boolean | "Returns true if this action can be ran"
	local args = {...}
	local actionList, remoteList = args[1], args[2]
	
	if Constraints(actionList) then
		return true
	end
	
	return false
end

return Action
