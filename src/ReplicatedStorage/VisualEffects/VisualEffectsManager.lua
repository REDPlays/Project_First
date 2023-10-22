local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Events = ReplicatedStorage:WaitForChild("Events")

local VisualEffectData = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectData)

local defaultRender = 1000

local VisualEffectsManager = {}

function VisualEffectsManager:SpawnEffects(vfxId, user, target, conditionalData, renderDistance)
    if not vfxId or not VisualEffectData[vfxId] then
        return
    end
    
    if not user then
        return
    end
    
    conditionalData = conditionalData or {}
    renderDistance = renderDistance or defaultRender

    local localPlayerChar = Players.LocalPlayer.Character
    if not localPlayerChar then
        return
    end

    local localRoot = localPlayerChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then
        return
    end

    local userRoot = user:FindFirstChild("HumanoidRootPart")
    if not userRoot then
        return
    end

    local distance = (localRoot.Position - userRoot.Position).Magnitude
    if distance > renderDistance then
        return
    end

    VisualEffectData[vfxId]:Spawn(user, target, conditionalData)
end

function VisualEffectsManager:Update(deltaTime)
    
end

local function spawnEffects(vfxId, user, target, conditionalData, renderDistance)
    VisualEffectsManager:SpawnEffects(vfxId, user, target, conditionalData, renderDistance)
end

Events.ServerToClient.VFX.OnClientEvent:Connect(spawnEffects)

return VisualEffectsManager