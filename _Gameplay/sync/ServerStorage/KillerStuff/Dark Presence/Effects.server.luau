local Character = script.Parent.Parent

local BodyMotor = Instance.new("Motor6D")
BodyMotor.Name = "BodyMotor"
BodyMotor.Parent = Character.PrimaryPart
BodyMotor.Part0 = Character.PrimaryPart
BodyMotor.Part1 = script.BodyParticleEmitter
BodyMotor.C1 = CFrame.new(0, 10, 0.25)

local TrailMotor = Instance.new("Motor6D")
TrailMotor.Name = "TrailMotor"
TrailMotor.Parent = Character.PrimaryPart
TrailMotor.Part0 = Character.PrimaryPart
TrailMotor.Part1 = script.TrailParticleEmitter
TrailMotor.C1 = CFrame.new(0, 6, 0.25)

script.BodyParticleEmitter.CollisionGroup = "NoCollision"
script.TrailParticleEmitter.CollisionGroup = "NoCollision"

script.TrailParticleEmitter.Parent = Character
script.BodyParticleEmitter.Parent = Character

local TrailAppearance = script.TrailAppearance
TrailAppearance.Parent = Character
TrailAppearance.Enabled = true

local LTrailAppearance = script.LocalTrail
LTrailAppearance.Parent = Character
LTrailAppearance.Enabled = true

script.Silhouette.Parent = Character

script:Remove()