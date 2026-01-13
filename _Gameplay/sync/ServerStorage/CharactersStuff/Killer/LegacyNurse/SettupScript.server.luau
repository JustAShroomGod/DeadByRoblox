local char = script.Parent.Parent
local folder = script.Parent
local part = folder.Union
local handle = folder.Handle

handle.Anchored = true

local primary = char:WaitForChild("Nurse")

handle.Transparency = 1
handle.CFrame = primary.Handle.CFrame

local weld = Instance.new("WeldConstraint", folder)
weld.Part0 = primary.Handle
weld.Part1 = handle

handle.Anchored = false

script:Destroy()