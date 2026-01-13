local remoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local betterUpdate = remoteEvents:WaitForChild("NewPropertie")
local crouchEvent = remoteEvents:WaitForChild("Crouch")
local userInputService = game:GetService("UserInputService")
local plr = game.Players.LocalPlayer
local char = workspace:WaitForChild(plr.Name)
local Backpack = plr:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")
local values = Scripts:WaitForChild("values")
local killer = Scripts:WaitForChild("Killer")
local action = values:WaitForChild("Action")
local healthState = values:WaitForChild("HealthState")
local shift = Scripts:WaitForChild("MovementSpeedScript"):WaitForChild("Shift")
local crouching = values:WaitForChild("Crouching")

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


userInputService.InputBegan:connect(function(input)
	
	if input.KeyCode == Enum.KeyCode.LeftControl
		or input.KeyCode == Enum.KeyCode.RightControl
		or input.KeyCode == Enum.KeyCode.ButtonL2 then
		
		if healthState.Value > 0 and not killer.Value and shift.Value == false then
			
			if action.Value == "Nothing" or action.Value == "UsingFlashlight" then
				local newPropertie = true
				crouching.Value = newPropertie
				Obfuscate("bool", crouching, newPropertie)
				char:SetAttribute("Crouch", true)
				
				return
			end
		end
	end
end)

userInputService.InputEnded:connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftControl
		or input.KeyCode == Enum.KeyCode.RightControl
		or input.KeyCode == Enum.KeyCode.ButtonL2 then
		
		if not killer.Value then
			
			if healthState.Value > 0 then
				local newPropertie = false
				crouching.Value = newPropertie
				
				Obfuscate("bool", crouching, newPropertie)
				char:SetAttribute("Crouch", false)
				
				crouchEvent:FireServer()
			end
		end
	end
end)

healthState.Changed:Connect(function()
	if healthState.Value == 0 then
		
		local newPropertie = false
		crouching.Value = newPropertie
		Obfuscate("bool", crouching, newPropertie)
		char:SetAttribute("Crouch", false)
		
		return
	end
end)


plr.Character:GetAttributeChangedSignal("LastHit"):Connect(function(test)
	Obfuscate("bool", crouching, false)
	char:SetAttribute("Crouch", false)
end)