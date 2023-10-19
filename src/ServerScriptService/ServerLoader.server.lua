local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Events = ReplicatedStorage:WaitForChild("Events")

local ServerGameManager = require(ServerScriptService.GameFiles.ServerGameManager)
ServerGameManager:Init()

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        Events.ServerToClient.CharacterLoaded:FireClient(player)
    end)
end)

RunService.Heartbeat:Connect(function(deltaTime)
    ServerGameManager:Heartbeat(deltaTime)
end)