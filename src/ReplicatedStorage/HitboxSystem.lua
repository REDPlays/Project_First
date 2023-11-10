local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Events = ReplicatedStorage:WaitForChild("Events")

local VisualConstants = require(ReplicatedStorage.RepFiles.Constants.VisualConstants)

local ServerStorage
local ServerStates
local knockbackThreads = {}

local DebugSettings = require(ReplicatedStorage.RepFiles.DebugSettings)

local HitboxSystem = {}
HitboxSystem.hitboxColor = Color3.fromRGB(255, 255, 255)
HitboxSystem.stunLength = 1
HitboxSystem.blockBreakStunLength = 3

if RunService:IsClient() then
    HitboxSystem.hitboxColor = Color3.fromRGB(0, 0, 255)
elseif RunService:IsServer() then
    HitboxSystem.hitboxColor = Color3.fromRGB(255, 0, 0)

    ServerStorage = game:GetService("ServerStorage")
    ServerStates = require(ServerStorage.RepFiles.Character.ServerStates)
end

function HitboxSystem:ShowHitbox(spawnCFrame, size)
    local box = Instance.new("Part")
    box.Size = size
    box.Color = HitboxSystem.hitboxColor
    box.Material = Enum.Material.ForceField
    box.Transparency = 1
    box.CFrame = spawnCFrame
    box.Anchored = true
    box.CanCollide = false
    box.CanQuery = true
    box.CanTouch = true
    box.Parent = workspace.Ignore

    Debris:AddItem(box, 1)

    return box
end

function HitboxSystem:CreateBox(character, spawnCFrame, size, damage, sequence, callBackFunction)
    damage = damage or .1 --10

    local box = HitboxSystem:ShowHitbox(spawnCFrame, size)

    local touched = box.Touched:Connect(function() end)
    local list = box:GetTouchingParts()

    if touched then
        touched:Disconnect()
    end

    for i=1, #list do
        local object = list[i]
        local parent = object.Parent

        if not parent:IsA("Model") then
            continue
        end

        if parent == character  then
            continue
        end

        local humanoid = parent:FindFirstChild("Humanoid")
        if not humanoid then
            continue
        end

        local rootPart = parent:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            continue
        end

        if RunService:IsClient() then
            if character:GetAttribute("Stunned") then
                return
            end
        elseif RunService:IsServer() then
            if ServerStates.Blocking[parent] then
                local blockHealth = ServerStates:UpdateBlock(parent, 1)
                if blockHealth <= 0 then
                    HitboxSystem:BlockBreak(character, parent, callBackFunction)
                else
                    Events.ServerToClient.VFX:FireAllClients(VisualConstants.Block, character, parent, {})
                end
                return
            end

            --im stunned
            if ServerStates.Stunned[character] then
                return
            end

            humanoid.AutoRotate = false
            task.delay(HitboxSystem.stunLength, function ()
                humanoid.AutoRotate = true
            end)

            local sequenceLength = string.len(sequence)

            SmallKnockBack(parent, character, sequence)

            Events.ServerToClient.VFX:FireAllClients(VisualConstants.Melee, character, parent, {sequenceLength = sequenceLength})

            local targetPlayer = Players:GetPlayerFromCharacter(parent)
            if targetPlayer then
                Events.ServerToClient.Stun:FireClient(targetPlayer, HitboxSystem.stunLength)
            end

            ServerStates:StunTarget(parent, HitboxSystem.stunLength)

            local stunData = ServerStates.Stunned[parent]
                if stunData then
                    if stunData.stunCount > ServerStates.Settings.stunMax then
                        local percentage = damage * (stunData.stunCount * ServerStates.Settings.stunDegrade) / 100
                        damage  -= percentage
                    end
                end
            --warn("damage:", damage)

            damage = math.clamp(damage, .1, 100) --1
            
            humanoid:TakeDamage(damage)
        end

        return
    end
end

function HitboxSystem:SmallKnockBack(target, rootPart, sequence)
    if knockbackThreads[target] then
        knockbackThreads[target].currTime = 0
        if string.len(sequence) < 5 then
            knockbackThreads[target].speed = 1
        else
            knockbackThreads[target].speed = 2
        end
        return
    end

    knockbackThreads[target] = {
        target = target,
        rootPart = rootPart,
        duration = .1,
        currTime = 0,
        speed = 0,
    }

    if string.len(sequence) < 5 then
        knockbackThreads[target].speed = 20
    else
        knockbackThreads[target].speed = 50
    end
end


function HitboxSystem:BlockBreak(character, target, callBackFunction)
    if not target then
        return
    end

    target:SetAttribute("Blocking", false)

    ServerStates:StunTarget(target, HitboxSystem.blockBreakStunLength)

    local targetPlayer = Players:GetPlayerFromCharacter(target)
    if targetPlayer then
        callBackFunction(targetPlayer)
        Events.ClientToServer.Block:InvokeClient(targetPlayer, HitboxSystem.blockBreakStunLength)
    end

    Events.ServerToClient.VFX:FireAllClients(VisualConstants.BlockBreak, character, target, {})
end

function SmallKnockBack(target, character, sequence)
    if not target then
        return
    end

    local rootPart = target:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    if target:GetAttribute("Blocking") then
        return
    end

    local plrVector = Vector3.new(character.HumanoidRootPart.Position.X, rootPart.Position.Y, character.HumanoidRootPart.Position.Z)
    rootPart.CFrame = CFrame.new(rootPart.Position, plrVector)

    HitboxSystem:SmallKnockBack(target, rootPart, sequence)
end

if RunService:IsServer() then
    RunService.Heartbeat:Connect(function(deltaTime)
        for target, data in pairs(knockbackThreads) do
            if not data.rootPart then
                continue
            end

            if data.speed == 0 then
                continue
            end

            data.currTime += deltaTime
            if data.currTime >= data.duration then
                knockbackThreads[target] = nil
            end

            data.rootPart.CFrame *= CFrame.new(0, 0, data.speed * deltaTime)
        end
    end)
end

return HitboxSystem