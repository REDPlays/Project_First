local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MovementModule = require(ReplicatedStorage.RepFiles.Character.MovementModule)
local AnimationSystem = require(ReplicatedStorage.RepFiles.Character.AnimationSystem)
local ClientCombatSystem = require(ReplicatedStorage.RepFiles.Character.ClientCombatSystem)

local LocalGameManager = {}
LocalGameManager.isLoaded = false

function LocalGameManager:Init(character)
    LocalGameManager.character = character
    LocalGameManager.humanoid = LocalGameManager.character:WaitForChild("Humanoid")

    LocalGameManager:Setup()
end

function LocalGameManager:Setup()
    if LocalGameManager.isLoaded then
        return
    end

    LocalGameManager.isLoaded = true

    LocalGameManager.movement = MovementModule.new(LocalGameManager.character)
    LocalGameManager.animationSystem = AnimationSystem.new(LocalGameManager.character, LocalGameManager.movement)

    LocalGameManager.combatSystem = ClientCombatSystem.new()
    LocalGameManager.combatSystem:Init(LocalGameManager.character, LocalGameManager.animationSystem, LocalGameManager.movement)
end

function LocalGameManager:Heartbeat(deltaTime)
    if LocalGameManager.humanoid.Health <= 0 then
        --reset
        if LocalGameManager.movement then
            LocalGameManager.movement :Disconnect()
        end

        if LocalGameManager.animationSystem then
            LocalGameManager.animationSystem :Disconnect()
        end

        if LocalGameManager.combatSystem then
            LocalGameManager.combatSystem:Disconnect()
        end

        LocalGameManager.movement  = nil
        LocalGameManager.animationSystem = nil

        LocalGameManager.isLoaded = false
        return
    end

    if LocalGameManager.movement then
        LocalGameManager.movement:Update(deltaTime)
    end

    if LocalGameManager.animationSystem then
        LocalGameManager.animationSystem:Update(deltaTime)
    end

    if LocalGameManager.combatSystem then
        LocalGameManager.combatSystem:Update(deltaTime)
    end
end

return LocalGameManager