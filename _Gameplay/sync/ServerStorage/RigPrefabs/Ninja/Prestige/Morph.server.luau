local Character = script.Parent
local Texture_Id = "rbxassetid://9296411675"

--print('Morph the body of', Character.Name)

local face = Instance.new('Decal', Character:WaitForChild('Head'))
face.Texture = Texture_Id

Character:WaitForChild('Neck'):WaitForChild('Handle').Color = Color3.fromRGB(86, 66, 54)

script:Remove()