local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Events = ReplicatedStorage:WaitForChild("Events")

local LocalGameManager = require(ReplicatedStorage.RepFiles.LocalGameManager)

local function CharacterLoaded()
    LocalGameManager:Init(Players.LocalPlayer.Character)

    RunService.Heartbeat:Connect(function(deltaTime)
        LocalGameManager:Heartbeat(deltaTime)
    end)
end

Events.ServerToClient.CharacterLoaded.OnClientEvent:Connect(CharacterLoaded)