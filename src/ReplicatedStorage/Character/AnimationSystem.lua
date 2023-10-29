local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Animations = ReplicatedStorage:WaitForChild("TestAnimations")

local KeyProvider = game:GetService("KeyframeSequenceProvider")

local AnimationConstants = require(ReplicatedStorage.RepFiles.Constants.AnimationConstants)

local AnimationSystem = {}
AnimationSystem.__index = AnimationSystem

local defaultFadeTime = 0.100000001
local defaultWeight = 1
local defaultSpeed = 1

function AnimationSystem.new(character, movementSystem)
    local newAnimationSystem = {}
    setmetatable(newAnimationSystem, AnimationSystem)

    newAnimationSystem:Init(character, movementSystem)

    return newAnimationSystem
end

function AnimationSystem:Init(character, movementSystem)
    self.character = character
    self.humanoid = self.character:FindFirstChild("Humanoid")
    self.animator = self.humanoid:FindFirstChild("Animator")

    self.movementSystem = movementSystem

    self.currentAnimations = {}
    self.cache = {}

    self:Setup()
end

function AnimationSystem:Setup()
    self.currentAnimations.Idle = self.animator:LoadAnimation(Animations.Idle)
    self.currentAnimations.Idle.Priority = Enum.AnimationPriority.Idle
    self.currentAnimations.Idle:Play()
end

function AnimationSystem:Disconnect()
    for name, track in pairs(self.currentAnimations) do
        track:Stop()
    end
end

function AnimationSystem:getAnimInfo(sequence)
    local animId = AnimationConstants[sequence].AnimationId
    if not animId then
        return false
    end

    if self.cache[animId] then
        return self.cache[animId]
    end

    local newSequence = KeyProvider:GetKeyframeSequenceAsync(animId)
    local Keyframes = newSequence:GetKeyframes()

    local length = 0
    local hitboxDelay = 0

    for i=1, #Keyframes do
        local Time = Keyframes[i].Time
        if Time > length then
            length = Time

            local markers = Keyframes[i]:GetMarkers()
            if markers[1] then
                hitboxDelay = Time
            end
        end
    end

    newSequence:Destroy()

    self.cache[animId] = {length = length, hitboxDelay = hitboxDelay}

    return self.cache[animId]
end

function AnimationSystem:Play(animationName, priority, weight, speed, fadeTime)
    if not  AnimationConstants[animationName] then
        warn("invalid name")
        return
    end

    priority = priority or Enum.AnimationPriority.Action
    weight = weight or defaultWeight
    speed = speed or defaultSpeed
    fadeTime = fadeTime or defaultFadeTime

    local track = AnimationConstants[animationName]

    self.currentAnimations[animationName] = self.animator:LoadAnimation(track)
    self.currentAnimations[animationName].Priority = priority
    self.currentAnimations[animationName]:Play(fadeTime, weight, speed)

    local animInfo = self:getAnimInfo(animationName)

    return animInfo
end

function AnimationSystem:Pause()
    
end

function AnimationSystem:Stop(animationName, fadeTime)
    if not self.currentAnimations[animationName] then
        warn("invalid name")
        return
    end

    self.currentAnimations[animationName]:Stop()
    self.currentAnimations[animationName] = nil
end

function AnimationSystem:Update(deltaTime)
    if self.movementSystem.sprint or self.movementSystem.crouch then
        if self.currentAnimations.Idle.IsPlaying then
            self.currentAnimations.Idle:Stop()
        end
    elseif not self.movementSystem.sprint and not self.movementSystem.crouch then
        if not self.currentAnimations.Idle.IsPlaying then
            self.currentAnimations.Idle:Play()
        end
    end
end

return AnimationSystem