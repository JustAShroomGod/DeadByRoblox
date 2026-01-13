local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

Character:WaitForChild("TrailParticleEmitter").TrailEmitter.Enabled = false
Character:WaitForChild("BodyParticleEmitter").BodyEmitter.Enabled = false

