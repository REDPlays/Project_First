local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")
local KeyProvider = game:GetService("KeyframeSequenceProvider")

local AnimationConstants = require(ReplicatedStorage.RepFiles.Constants.AnimationConstants)

local HitboxSystem = require(ReplicatedStorage.RepFiles.HitboxSystem)

local ServerCombatSystem = {}
ServerCombatSystem.inCooldown = {}
ServerCombatSystem.cache = {}

local function checkCooldown(player, sequence)
    if ServerCombatSystem.inCooldown[player.UserId] then
        return false
    end

    ServerCombatSystem:Action(player, sequence)

    return true
end

function ServerCombatSystem:Action(player, sequence)
    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart then
        return false
    end

    local animationData = ServerCombatSystem:getAnimInfo(sequence)

    ServerCombatSystem.inCooldown[player.UserId] = true

    --hitboxLogic
    task.delay(animationData.hitboxDelay, function()
        HitboxSystem:CreateBox(character, rootPart.CFrame * CFrame.new(0, 0, -2), Vector3.new(4, 6, 4))
    end)

    --cooldown
    task.delay(animationData.length * .8, function()
        ServerCombatSystem.inCooldown[player.UserId] = nil

        Events.ClientToServer.Combat:InvokeClient(player)
    end)
end

function ServerCombatSystem:getAnimInfo(sequence)
    local animId = AnimationConstants[sequence].AnimationId
    if not animId then
        return false
    end

    if ServerCombatSystem.cache[animId] then
        return ServerCombatSystem.cache[animId]
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

    ServerCombatSystem.cache[animId] = {length = length, hitboxDelay = hitboxDelay}

    return ServerCombatSystem.cache[animId]
end

Events.ClientToServer.Combat.OnServerInvoke = checkCooldown

return ServerCombatSystem