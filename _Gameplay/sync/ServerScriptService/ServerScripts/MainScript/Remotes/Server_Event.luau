local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
local TweenService = game:GetService('TweenService')
local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local remote = {
	modules ={}
}

local function GrabRemote()
	
	for _,r in pairs(RemoteStorage:GetChildren())do
		
		if string.lower(r.Name) == string.lower(script.Name) then
			return r
		end
	end
	
	return false
end

function remote.new()
	local self = {}
	setmetatable(self, remote)
	
	local connection = GrabRemote()
	
	if connection then
		
		for _, submodule in pairs(script:WaitForChild('Modules'):GetChildren()) do
			remote.modules[submodule.Name] = require(submodule)
		end
		
		connection.OnServerEvent:Connect(function(player, ...)
			local args = {...}
			
			if args[1] == "Wiggle" then
				remote.modules['Struggle']:Fire(player, args)
			elseif args[1] == "Platform" and args[2] then
				player:SetAttribute("PLATFORM", args[2])
			elseif args[1] == "Cloak" then
				remote.modules["Cloak"]:Fire(player, args)
			elseif args[1] == "Slam" then
				remote.modules['Slam']:Fire(player, args)
			elseif args[1] == "Trap" then
				remote.modules["Trap"]:Fire(player, args)
			elseif args[1] == "Stalk" then
				remote.modules['Stalk']:Fire(player, args)
			elseif args[1] == "Shock" then
				remote.modules["Shock"]:Fire(player,args)
			elseif args[1] == "Locker" then
				remote.modules["Locker"]:Fire(player, args)
			elseif args[1] == "Hook" then
				remote.modules["Hook"]:Fire(player, args)
			elseif args[1] == "Carry" or args[1] == "Grasp" then
				remote.modules['Carry']:Fire(player, args)
			elseif args[1] == "Rage" then
				remote.modules['Rage']:Fire(player, args)
			elseif args[1] == "Pallet" then
				remote.modules['Pallet']:Fire(player, args)
			elseif args[1] == "Wall" then
				remote.modules['Wall']:Fire(player, args)
			elseif args[1] == "Generator" then
				remote.modules['Generator']:Fire(player, args)
			elseif args[1] == "Chainsaw" then
				remote.modules["Chainsaw"]:Fire(player, args)
			elseif args[1] == "Swift Charge" then
				remote.modules['Swift_Charge']:Fire(player, args)
			elseif args[1] == "Hatchet" then
				remote.modules['Hatchet']:Fire(player, args)
			elseif args[1] == "Totem" then
				remote.modules['Totem']:Fire(player, args)
			elseif args[1] == "BloodRage" then
				remote.modules['BloodRage']:Fire(player, args)
			elseif args[1] == "Blink" then
				remote.modules['Blink']:Fire(player, args)
			else
				print(args)
				warn(args[1], 'not a supported module/command!')
			end
		end)
		
		RemoteStorage:WaitForChild('Event').Event:Connect(function(...)
			local args = {...}
			
			if args[1] == "Hit" then
				remote.modules['HitPlayer']:Fire(...)
			end
		end)
	elseif script.Name ~= "Template" then
		warn('Remote does not exist:', script.Name)
	end
	
	return self
end

return remote.new()
