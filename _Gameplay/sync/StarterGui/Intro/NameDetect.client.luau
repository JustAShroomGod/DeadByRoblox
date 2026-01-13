local player = game.Players.LocalPlayer

local nameValue = game.ReplicatedStorage.Match.MapName

local plrgui = player:WaitForChild("PlayerGui")

local tti = script.Parent
local tti2 = plrgui:WaitForChild("HUD"):WaitForChild("MatchMenu"):WaitForChild("UpperFrame") --plrgui:WaitForChild("GameMenu").MainFrame.DownFrame.Line

local Maps = {

	-- Normal Maps -- 
	["Test Map"] = {"Please report any issues you find to the discord server, thanks!", true},
	["Dead Dawg Saloon"] = {"Grave of Glenvale", true},
	["Coal Tower"] = {"The MacMillan Estate", true},
	["Haddonfield"] = {"Lampkin Lane", true},
	["Rotten Fields"] = {"Coldwind Farm", true},
	--["Old Rotten Fields"] = {"Forgotten Memories", true},
	["The Forest"] = {"Grounded Thicket", true},
	["Fractured Space"] = {"Fancreation by PoIarPatroller", true},
	["Sanctum of Wrath"] = {"Yamaoka Estate", true},
	["Fractured Cowshed"] = {"Coldwind farm", true},
	--["Old Fractured Cowshed"] = {"Forgotten Memories", true},
	--["Old Blood Lodge"] = {"Forgotten Memories", true},
	["Classic"] = {"Rose Tinted Glasses", true},
	["The Library"] = {"", true},
	["The Ruins"] = {"Green Inferno", true},
	--["Forgotten Memories"] = {"Forgotten Memories", true},
	["Charon Co. Ferry Tours"] = {"Black Mire Bog", true},
	["Stratinns Cellar"] = {"Dead Forest", true},
	["Blood Lodge"] = {"Autohaven Wreckers", true},
	["Azarovs Resting Place"] = {"Autohaven Wreckers", true},
	["Wreckers Yard"] = {"Autohaven Wreckers", true},
	["Johnson's Heartbeat"] = {"Sunny Dale Ranch", true},
	["The Abomination"] = {"Sunny Dale Ranch", true},
	["Unbridled Force"] = {"Sunny Dale Ranch", true},
	--['No Red Paint'] = {"Sunny Dale Ranch", true},
	["Infinite Cornrows"] = {"Sunny Dale Ranch", true},

	--[""] = {"Name", true},
	-- Name of map first then name of realm

	-- Winter Maps --

	--["Dead Dawg Saloon"] = {"Grave of Glenvale", true},
	--["Winter Tower"] = {"The MacMillan Estate", true},
	--["Winter Lodge"] = {"Autohaven Wreckers", true},
	--["Winter Cowshed"] = {"Coldwind farm", true},
	--["Haddonfield"] = {"Lampkin Lane", true},
	--["Fractured Winter"] = {"Fancreation by PoIarPatroller", true},

	-- Fan Maps -- 
	["Camping Woods"] = {"Fancreation by professo10", true},
	["Flower Garden"] = {"Fancreation by PaRK_JimIN9555", true},
	["Nightmare Forest"] = {"Fancreation by Kum1lite", true};
	["Haunted Village"] = {"Fancreation by JelloIsHereToo", true};
	["Grace Abounds Church"] = {"Fancreation by offici4l_n4m3 and its_o9ine" , true};
	["Ormond Port Blox"] = {"Fancreation by Kum1lite" , true};
	['Dead Tree Sanctuary'] = {"Fancreation by will0666 and finishedLite", true};
	['Dead Sands'] = {"Fancreation by ergo1239", true};
	['Retro Castle'] = {"Fancreation by galaxypuffsv3 and offici41_n4m3", true};
	['Crucifixion Woods'] = {"Fancreation by galaxypuffsv3", true};
}

tti.CutsceneFrame.MainFrame.Line.MapName.Text = nameValue.Value
--tti2.MapName.Text = nameValue.Value

tti2.Map.Text = nameValue.Value ..  if Maps[nameValue.Value] then tostring(" - " .. Maps[nameValue.Value][1]) else "" 

if Maps[nameValue.Value] then
	tti.CutsceneFrame.MainFrame.Line.MapSubName.Text = Maps[nameValue.Value][1]
	--tti2.MapSubName.Text = Maps[nameValue.Value][1]
	--tti2.MapSubName.Visible = Maps[nameValue.Value][2]
else
	tti.CutsceneFrame.MainFrame.Line.MapSubName.Text = ""
	--tti2.MapSubName.Visible = false
end


