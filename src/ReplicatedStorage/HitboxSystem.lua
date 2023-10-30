local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Events = ReplicatedStorage:WaitForChild("Events")

local VisualConstants = require(ReplicatedStorage.RepFiles.Constants.VisualConstants)

local ServerStorage
local ServerStates

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
    damage = damage or 10

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
            if parent:GetAttribute("Blocking") then
                return
            else
                local plrVector = Vector3.new(character.HumanoidRootPart.Position.X, rootPart.Position.Y, character.HumanoidRootPart.Position.Z)
                rootPart.CFrame = CFrame.new(rootPart.Position, plrVector)
            end

            local plrVector = Vector3.new(character.HumanoidRootPart.Position.X, rootPart.Position.Y, character.HumanoidRootPart.Position.Z)
            rootPart.CFrame = CFrame.new(rootPart.Position, plrVector)

            HitboxSystem:SmallKnockBack(rootPart, sequence)

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

            local sequenceLength = string.len(sequence)

            Events.ServerToClient.VFX:FireAllClients(VisualConstants.Melee, character, parent, {sequenceLength = sequenceLength})

            ServerStates:StunTarget(parent, HitboxSystem.stunLength)

            local stunData = ServerStates.Stunned[parent]
                if stunData then
                    if stunData.stunCount > ServerStates.Settings.stunMax then
                        local percentage = damage * (stunData.stunCount * ServerStates.Settings.stunDegrade) / 100
                        damage  -= percentage
                    end
                end
            --warn("damage:", damage)

            damage = math.clamp(damage, 1, 100)
            
            humanoid:TakeDamage(damage)
        end

        return
    end
end

function HitboxSystem:SmallKnockBack(rootPart, sequence)
    local attach = Instance.new("Attachment")
    attach.Parent = rootPart

    local vel = Instance.new("LinearVelocity")
	vel.Attachment0 = attach
	vel.MaxForce = 1e5
	vel.Enabled = true
	vel.RelativeTo = Enum.ActuatorRelativeTo.Attachment0

    if string.len(sequence) < 5 then
        vel.VectorVelocity = Vector3.new(0, 0, 20)
    else
        vel.VectorVelocity = Vector3.new(0, 0, 60)
    end
	vel.Parent = rootPart

    Debris:AddItem(vel, .1)
    Debris:AddItem(attach, .1)
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

return HitboxSystem