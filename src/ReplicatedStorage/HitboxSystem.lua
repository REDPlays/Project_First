local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local HitboxSystem = {}
HitboxSystem.hitboxColor = Color3.fromRGB(255, 255, 255)

if RunService:IsClient() then
    HitboxSystem.hitboxColor = Color3.fromRGB(0, 0, 255)
elseif RunService:IsServer() then
    HitboxSystem.hitboxColor = Color3.fromRGB(255, 0, 0)
end

function HitboxSystem:ShowHitbox(spawnCFrame, size)
    local box = Instance.new("Part")
    box.Size = size
    box.Color = HitboxSystem.hitboxColor
    box.Material = Enum.Material.ForceField
    box.Transparency = .75
    box.CFrame = spawnCFrame
    box.Anchored = true
    box.CanCollide = false
    box.CanQuery = true
    box.CanTouch = true
    box.Parent = workspace.Ignore

    Debris:AddItem(box, 1)

    return box
end

function HitboxSystem:CreateBox(character, spawnCFrame, size, damage)
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
            warn("play vfx")
            local plrVector = Vector3.new(character.HumanoidRootPart.Position.X, rootPart.Position.Y, character.HumanoidRootPart.Position.Z)
            rootPart.CFrame = CFrame.new(rootPart.Position, plrVector)

            --HitboxSystem:SmallKnockBack(rootPart)

        elseif RunService:IsServer() then
            warn("damage", parent.Name)
            humanoid:TakeDamage(damage)

            HitboxSystem:SmallKnockBack(rootPart)
        end

        return
    end
end

function HitboxSystem:SmallKnockBack(rootPart)
    local attach = Instance.new("Attachment")
    attach.Parent = rootPart

    local vel = Instance.new("LinearVelocity")
	vel.Attachment0 = attach
	vel.MaxForce = 1e5
	vel.Enabled = true
	vel.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	vel.VectorVelocity = Vector3.new(0, 0, 15)
	vel.Parent = rootPart

   Debris:AddItem(vel, .1)
    Debris:AddItem(attach, .1)
end

return HitboxSystem