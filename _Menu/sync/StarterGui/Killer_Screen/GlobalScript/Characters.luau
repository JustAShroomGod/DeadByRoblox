local ReplicatedStorage = game:GetService('ReplicatedStorage')

local ModuleStorage, Game_Data = ReplicatedStorage:WaitForChild('Modules'), ReplicatedStorage:WaitForChild('Game_Data')

local Character_Frame = script.Parent.Parent:WaitForChild('Content'):WaitForChild('Characters')
local Modules = {
	Data = require(ModuleStorage:WaitForChild('Data'));
	Hover = require(game.Players.LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('HUD'):WaitForChild('Hover_Module'));
}

local Handler = {
	Data_Template = Modules.Data:GetRaw();
	Connections = {};
	Hover_Connections = {
		Enter = {};
		Leave = {};
	};
}

function Create_New(Killer, Killer_Data)
	local Killer_Module =  Game_Data:WaitForChild('Killers'):FindFirstChild(Killer)
	
	if Killer_Module then
		local New_Frame, Killer_Module = script:WaitForChild('Template'):Clone(), require(Killer_Module)

		New_Frame.Name = Killer
		
		if not Killer_Data.Other.Unlocked or 1 == 2 then -- check if locked/unlocked
			print('Still not unlocked!')

			New_Frame:WaitForChild('Image').ImageColor3 = Color3.fromRGB(27, 27, 27)
		else
			New_Frame:WaitForChild('Image').ImageColor3 = Color3.fromRGB(255, 255, 255)

			Handler.Connections[Killer] = New_Frame:WaitForChild('Image').MouseButton1Click:Connect(function()
				Modules.Data:EquipKiller(Killer)
			end)
		end
		
		-- Hover Controls --
		if not Handler.Hover_Connections.Enter[New_Frame] then

			Handler.Hover_Connections.Enter[New_Frame] = New_Frame:WaitForChild('Image').MouseEnter:Connect(function()
				Modules.Hover:Display("Killer", Killer_Module)
			end)
		end

		if not Handler.Hover_Connections.Leave[New_Frame] then

			Handler.Hover_Connections.Leave[New_Frame] = New_Frame:WaitForChild('Image').MouseLeave:Connect(function()
				Modules.Hover:Hide()
			end)
		end
		
		if not Killer_Module.Active then
			New_Frame.Visible = false
		end

		New_Frame:WaitForChild('Level').Text = tostring(Killer_Data.Other.Level)
		New_Frame:WaitForChild('Title').TextColor3 = if Killer_Data.Other.Level >= 50 then Color3.fromRGB(255, 0, 0) else Color3.fromRGB(255, 255, 255)
		New_Frame:WaitForChild('Level').TextColor3 = if Killer_Data.Other.Level >= 50 then Color3.fromRGB(255, 0, 0) else Color3.fromRGB(255, 255, 255)

		New_Frame.Parent = Character_Frame:WaitForChild('Roster')
		
		New_Frame:WaitForChild('Image').Image = Killer_Module.Killer_Image
	else
		warn('Can not find module for:', Killer)
	end
end

function Update_Frame(New_Frame, Killer_Data)
	New_Frame:WaitForChild('Level').Text = tostring(Killer_Data.Other.Level)
	New_Frame:WaitForChild('Title').TextColor3 = if Killer_Data.Other.Level >= 50 then Color3.fromRGB(255, 0, 0) else Color3.fromRGB(255, 255, 255)
	New_Frame:WaitForChild('Level').TextColor3 = if Killer_Data.Other.Level >= 50 then Color3.fromRGB(255, 0, 0) else Color3.fromRGB(255, 255, 255)
end

function Handler:Update() -- update
	
	for character, character_data in pairs(Handler.Data_Template) do
		if character == "Main" then continue end
		character = character:gsub("^%l", string.upper)
		
		local character_frame = Character_Frame:WaitForChild('Roster'):FindFirstChild(character)
		
		if not character_frame then
			Create_New(character, character_data)
		else
			Update_Frame(character_frame, character_data)
		end
	end
	
	--print('Done Updating')
end

return Handler