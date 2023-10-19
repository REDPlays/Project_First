local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local ServerGameManager = require(ServerScriptService.GameFiles.ServerGameManager)
ServerGameManager:Init()

RunService.Heartbeat:Connect(function(deltaTime)
    ServerGameManager:Heartbeat(deltaTime)
end)