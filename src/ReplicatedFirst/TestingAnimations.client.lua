local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TestingRigs = workspace:WaitForChild("TestingRigs")
local TestAnimations = ReplicatedStorage:WaitForChild("TestAnimations")

local AnimationConstants = require(ReplicatedStorage.RepFiles.Constants.AnimationConstants)

local CombatRig = TestingRigs:WaitForChild("Combat")

local rigTable = {}
for _, rig in pairs(TestingRigs:GetChildren()) do
	rigTable[rig.Name] = rig
end

local animationTable = {}
for _, animation in pairs(TestAnimations:GetChildren()) do
	if animation:IsA("Animation") then
		animationTable[animation.Name] = animation
	end
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

local CombatCounter = 0
while true do
	local humanoid = CombatRig:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")

	CombatCounter += 1
	if CombatCounter > 5 then
		task.wait(.5)
		CombatCounter = 1
	end

	local sequence = ""
	for i=1, CombatCounter do
		sequence ..= "L"
	end

	local track = animator:LoadAnimation(AnimationConstants[sequence])
	track:Play()

	track.Stopped:Wait()
end