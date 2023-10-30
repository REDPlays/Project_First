local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VisualConstants = require(ReplicatedStorage.RepFiles.Constants.VisualConstants)

local VisualEffectData = {}

VisualEffectData[VisualConstants.Melee] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("VisualEffects"):WaitForChild("Melee"))
VisualEffectData[VisualConstants.BlockBreak] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("VisualEffects"):WaitForChild("BlockBreak"))
VisualEffectData[VisualConstants.Block] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("VisualEffects"):WaitForChild("Block"))

return VisualEffectData