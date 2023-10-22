local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Animations = ReplicatedStorage:WaitForChild("TestAnimations")

local AnimationConstants = {}

AnimationConstants["L"] = Animations.Combat.Melee.M1
AnimationConstants["LL"] = Animations.Combat.Melee.M2
AnimationConstants["LLL"] = Animations.Combat.Melee.M3
AnimationConstants["LLLL"] = Animations.Combat.Melee.M4
AnimationConstants["LLLLL"] = Animations.Combat.Melee.M5

return AnimationConstants