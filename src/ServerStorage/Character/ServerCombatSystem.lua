local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")
local KeyProvider = game:GetService("KeyframeSequenceProvider")
local ServerStorage = game:GetService("ServerStorage")

local AnimationConstants = require(ReplicatedStorage.RepFiles.Constants.AnimationConstants)

local HitboxSystem = require(ReplicatedStorage.RepFiles.HitboxSystem)

local ServerStates = require(ServerStorage.RepFiles.Character.ServerStates)

local ServerCombatSystem = {}
ServerCombatSystem.inCooldown = {}
ServerCombatSystem.cache = {}

local function checkCooldown(player, sequence)
    if ServerStates.Stunned[player.Character] then
        return {value = false, reason = "stunned"}
    end
    if ServerCombatSystem.inCooldown[player.UserId] then
        return {value = false, reason = "cooldown"}
    end

    ServerCombatSystem:Action(player, sequence)

    return {value = true, reason = "none"}
end

local function checkBlock(player, isActive)
    --unblocking
    if ServerStates.Blocking[player.Character] then
        ServerCombatSystem:Block(player, isActive)
        return {value = true, reason = "unblocking"}
    end

    if ServerStates.Stunned[player.Character] then
        return {value = false, reason = "stunned"}
    end

    if ServerCombatSystem.inCooldown[player.UserId] then
        return {value = false, reason = "cooldown"}
    end

    ServerCombatSystem:Block(player, isActive)

    return {value = true, reason = "none"}
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
        HitboxSystem:CreateBox(character, rootPart.CFrame * CFrame.new(0, 0, -2), Vector3.new(4, 6, 4), nil, sequence)
    end)

    --cooldown
    task.delay(animationData.length * .8, function()
        ServerCombatSystem.inCooldown[player.UserId] = nil

        if not Players:FindFirstChild(player.Name) then
            return
        end

        Events.ClientToServer.Combat:InvokeClient(player)
    end)
end

function ServerCombatSystem:Block(player, isActive)
    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart then
        return false
    end

    if not ServerCombatSystem.inCooldown[player.UserId] then
        ServerCombatSystem.inCooldown[player.UserId] = true
    elseif ServerCombatSystem.inCooldown[player.UserId] then
        task.delay(1, function()
            ServerCombatSystem.inCooldown[player.UserId] = nil
        end)
    end

    character:SetAttribute("Blocking", isActive)

    ServerStates:Block(character, isActive)
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
Events.ClientToServer.Block.OnServerInvoke = checkBlock

return ServerCombatSystem