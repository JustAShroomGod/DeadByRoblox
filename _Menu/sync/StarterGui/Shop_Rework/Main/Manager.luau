local Utility = require(script.Parent:WaitForChild("Utility"))

local module = {
	Selected = "Characters";
	Custom_Selection = "Cosmetics";
}

function CreateNavigator()
	
	for _,v in pairs(script.Parent:WaitForChild("Navigator"):GetChildren()) do
		
		if v:IsA("TextButton") then
			
			v.MouseButton1Click:Connect(function()
				module.Selected = v.Name
				Utility.ChangeSelected(module.Selected)
			end)
		end
	end
end

function CreateCustomTabNavigation()

	for _,v in pairs(script.Parent:WaitForChild("Customization"):WaitForChild('Header'):GetChildren()) do

		if v:IsA("TextButton") then

			v.MouseButton1Click:Connect(function()
				module.Custom_Selection = v.Name
				Utility.ChangeCustomSelected(module.Custom_Selection)
			end)
		end
	end
end

function module.Init()
	Utility.CreateCharacters()
	Utility.CreatePerks()
	Utility.CreateCustomization()
	Utility.CreateCurrency()
	
	CreateNavigator()
	CreateCustomTabNavigation()
	
	Utility.ChangeSelected(module.Selected)
	Utility.ChangeCustomSelected(module.Custom_Selection)
end


return module
