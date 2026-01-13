folder = Instance.new("Folder", game:GetService("ReplicatedStorage"))
local insert = function (self) self.Parent = folder end



warn("ATTEMPT TO START USING SURVIVOR UIPREFAB EVEN THO WE AREN'T PLAYING SURVIVOR")
localPlayer = game:GetService("Players").LocalPlayer
localPlayer:WaitForChild("PlayerGui")
screen = script.Parent.Parent



insert(script.ItemAndAddons.P1.ItemPrefab)
insert(script.ItemAndAddons.P1.Addons.P1.AddonsPrefab)
insert(script.Perks.Layout1.P1.PerksPrefab)

folder.ItemPrefab.Amount.Visible = false
--folder.AddonsPrefab.Plus.Visible = false
folder.AddonsPrefab.Amount.Visible = false

return folder