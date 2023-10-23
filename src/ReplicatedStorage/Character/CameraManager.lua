local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local CameraManager = {}
CameraManager.__index = CameraManager

function CameraManager.new()
    local newCamera = {}
    setmetatable(newCamera, CameraManager)

    return newCamera
end

function CameraManager:Init(player: Player)
    self.player = player
    self.character = self.player.Character

    self.playerModule = require(self.player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))

    self.activeMouseLock = self.playerModule.cameras.activeMouseLockController

    self.isActive = false
    self.lockCamera = false

    self:Connections()
end

function CameraManager:Setup()
    
end

function CameraManager:Connections()
    self.inputBegan = UserInput.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent then
            if input.KeyCode == Enum.KeyCode.LeftControl then
                if self.lockCamera then
                    return
                end

                if not self.isActive then
                    self.isActive = true

                    self.activeMouseLock:DoMouseLockSwitch(
                        "MouseLockSwitchAction",
                        Enum.UserInputState.Begin,
                        Enum.KeyCode.LeftControl
                    )
                elseif self.isActive then
                    self.isActive = false

                    self.activeMouseLock:DoMouseLockSwitch(
                        "MouseLockSwitchAction",
                        Enum.UserInputState.Begin,
                        Enum.KeyCode.LeftControl
                    )
                end
            end
        end
    end)
end

function CameraManager:Disconnect()
    if self.inputBegan then
        self.inputBegan:Disconnect()
    end
end

function CameraManager:Update(deltaTime)
    
end

return CameraManager