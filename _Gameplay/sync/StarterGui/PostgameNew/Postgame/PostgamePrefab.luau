folder = Instance.new("Folder", game:GetService("ReplicatedStorage"))
local insert = function (self) self.Parent = folder end



PREFIX = "rbxassetid://"
localPlayer = game:GetService("Players").LocalPlayer
screen = script.Parent.Parent
screen_body = screen.Body

killerprefab = screen_body.Scoreboard.Survivors.SurvivorPrefab:Clone()
killerprefab.Design:Destroy()
killerprefab.Status.Image.Image = PREFIX.. tostring(6304439495) --TODO this is supposed to be the image of a knife
killerprefab.Name = "KillerPrefab"

insert(screen_body.Navegator.Checkboxes.NavegatorCheckboxesPrefab)
insert(screen_body.BloodpointsEarned.Categories.CategoriesPrefab)
insert(screen_body.OnlineGrade.Emblems.EmblemsPrefab)
insert(screen_body.OnlineGrade.Rank.Checkboxes.P1.CheckboxesPrefab)
insert(screen_body.Scoreboard.Survivors.SurvivorPrefab.Offering.OfferingPrefab)
insert(screen_body.Scoreboard.Survivors.SurvivorPrefab)
insert(killerprefab)

folder.OfferingPrefab.Amount.Visible = false

return folder