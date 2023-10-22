local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VisualConstants = require(ReplicatedStorage.RepFiles.Constants.VisualConstants)

local VisualEffectData = {}

VisualEffectData[VisualConstants.Melee] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("VisualEffects"):WaitForChild("Melee"))

return VisualEffectData