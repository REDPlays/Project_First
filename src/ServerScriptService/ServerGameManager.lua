local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ServerCombatSystem = require(ServerStorage.RepFiles.Character.ServerCombatSystem)
local ServerStates = require(ServerStorage.RepFiles.Character.ServerStates)

local ServerGameManager = {}

function ServerGameManager:Init()
    
end

function ServerGameManager:Heartbeat(deltaTime)
    ServerStates:Update(deltaTime)
end

return ServerGameManager