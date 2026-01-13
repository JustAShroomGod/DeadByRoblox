local templateName = script.TemplateName

local rbar = script.Parent.Rules.ReportableBar
local nrbar = script.Parent.Rules.NotReportableBar

local reportable = {
	"- Players hacking, such as speed hack, no-clip, fly hack, teleport etc..",
	"- Survivors escaping early, if hatch didn't spawn or if the generators weren't done.",
	"- People being excessively rude, offensive, or toxic in the chat.",
	"- People abusing collision oversights to climb up to unreachable areas to hold the game hostage.",
	"- Banned players alting.",
	"- Survivors teaming with the killer or sabotaging the team, for ex. they sandbag you and don't unhook you so you die."
}

local notreportable = {
	"- Survivors getting bugged that they have no control of, such as infinite hook bug etc.",
	"- Killers camping hooks or tunneling the same survivor or slugging.",
	"- Staff killing you with a shotgun",
}


local function generateRulesBar(bar, names)
	local sortedNames = {}

	for _, name in ipairs(names) do
		table.insert(sortedNames, name)
	end

	table.sort(sortedNames)

	for _, name in ipairs(sortedNames) do
		local originalName = name

		local nameTemplate = templateName:Clone()
		nameTemplate.Text = "<b>" .. originalName .. "</b>"
		nameTemplate.Parent = bar
		nameTemplate.Name = originalName
	end
end

generateRulesBar(rbar, reportable, false)
generateRulesBar(nrbar, notreportable, false)

task.wait(1)

script:Destroy()