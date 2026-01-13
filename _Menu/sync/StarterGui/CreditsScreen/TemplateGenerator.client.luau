local templateName = script.TemplateName
local templaterole = script.TemplateRole

local mbar = script.Parent.Credits.ModeratorsBar
local dbar = script.Parent.Credits.DevelopersBar

local developers = {
	["Bromeri"] = "Owner",
	["AerooDev and VeroxCode"] = "Gameplay Programmers",
	["PokeMiner29"] = "GFX Artist",
	["PoIarPatroller and PlsGiveMe_ATaco"] = "Map Creators",
	["KameronLP11"] = "Back-End Scripter",
	["K0_rd and cream_aw"] = "Animators",
	["pxpnoodle"] = "Sound Designer",
	["cheetamcu"] = "noob",
	["PaRK_JimIN9555"] = "Cosmetic Designer",
	["its_o9ine"] = "3D Modeler"
}

local moderators = {
	"GreatAnthony100",
	"SANICBOOMO",
	"juauelmior1212",
    "Eepyling",
	"Kum1lite",
    "12fp"
}


local function generateCreditBar(bar, names, isDeveloper)
	local sortedNames = {}

	if isDeveloper then
		for name in pairs(names) do
			table.insert(sortedNames, name:lower())
		end
	else
		for _, name in ipairs(names) do
			table.insert(sortedNames, name:lower())
		end
	end
	
	table.sort(sortedNames)

	for _, name in ipairs(sortedNames) do
		local originalName
		
		if isDeveloper then
			for key in pairs(names) do
				if key:lower() == name then
					originalName = key
					break
				end
			end
			local roleTemplate = templaterole:Clone()
			roleTemplate.Text = "<b>" .. names[originalName] .. "</b>"
			roleTemplate.Parent = bar.List
			roleTemplate.Name = names[originalName]
		else
			-- FIX FOR UNDERCASE MOD NAMES: we use the name from the original names table instead of the lowercase name
			for _, origName in ipairs(names) do
				if origName:lower() == name then
					originalName = origName
					break
				end
			end
		end

		local nameTemplate = templateName:Clone()
		nameTemplate.Text = "<b>" .. originalName .. "</b>"
		nameTemplate.Parent = bar.List
		nameTemplate.Name = originalName
	end
end

function GenerateDevelopers()

	for name, title in ipairs(developers) do
		local originalName

		local roleTemplate = templaterole:Clone()
		roleTemplate.Text = "<b>" .. title .. "</b>"
		roleTemplate.Parent = dbar.List
		roleTemplate.Name = title
		
		local nameTemplate = templateName:Clone()
		nameTemplate.Text = "<b>" .. name .. "</b>"
		nameTemplate.Parent = dbar.List
		nameTemplate.Name = name
	end
end

--GenerateDevelopers()
generateCreditBar(dbar, developers, true)
generateCreditBar(mbar, moderators, false)

task.wait(1)

script:Destroy()