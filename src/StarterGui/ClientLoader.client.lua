local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalGameManager = require(ReplicatedStorage.RepFiles.LocalGameManager)

RunService.Heartbeat:Connect(function(deltaTime)
    LocalGameManager:Heartbeat(deltaTime)
end)