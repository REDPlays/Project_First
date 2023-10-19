local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestingRigs = workspace:WaitForChild("TestingRigs")
local TestAnimations = ReplicatedStorage:WaitForChild("TestAnimations")

local rigTable = {}
for _, rig in pairs(TestingRigs:GetChildren()) do
	rigTable[rig.Name] = rig
end

local animationTable = {}
for _, animation in pairs(TestAnimations:GetChildren()) do
	animationTable[animation.Name] = animation
end

for rigName, rig in pairs(rigTable) do
	if not animationTable[rigName] then
		continue
	end
	local humanoid = rig:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")
	
	local anim = animator:LoadAnimation(animationTable[rigName])
	anim:Play()
end