local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MovementModule = require(ReplicatedStorage.RepFiles.Character.MovementModule)

local LocalGameManager = {}

function LocalGameManager:Init(character)
    LocalGameManager.character = character

    LocalGameManager:Setup()
end

function LocalGameManager:Setup()
    LocalGameManager.movement = MovementModule.new(LocalGameManager.character)
end

function LocalGameManager:Heartbeat(deltaTime)
    if LocalGameManager.movement then
        LocalGameManager.movement:Update(deltaTime)
    end
end

return LocalGameManager