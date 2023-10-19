local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInput = game:GetService("UserInputService")

local Animations = ReplicatedStorage:WaitForChild("TestAnimations")

local MovementModule = {}
MovementModule.__index = MovementModule

function MovementModule.new(character)
    local newMovement = {}
    setmetatable(newMovement, MovementModule)

    newMovement:Init(character)
    
    return newMovement
end

function MovementModule:Init(character)
    self.character = character
    self.humanoid = self.character:WaitForChild("Humanoid")
    self.rootPart = self.character:WaitForChild("HumanoidRootPart")

    self.prevWalkSpeed = 0

    self.sprint = false
    self.crouch = false

    self:Setup()
    self:Connections()
end

function MovementModule:Setup()
    self.animations = {
        ["Sprint"] = self.humanoid.Animator:LoadAnimation(Animations.Run),
        ["Crouch"] = self.humanoid.Animator:LoadAnimation(Animations.Crouch),
        ["CrouchWalk"] = self.humanoid.Animator:LoadAnimation(Animations.CrouchWalk),
    }
end

function MovementModule:Connections()
    UserInput.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent then
            --sprinting
            if input.KeyCode == Enum.KeyCode.LeftShift then
                if not self.sprint then
                    if self.crouch then
                        return
                    end

                    self.sprint = true

                    self.animations.Sprint:Play()

                    self.prevWalkSpeed = self.humanoid.WalkSpeed
                    self.humanoid.WalkSpeed = 24
                end
            end

            if input.KeyCode == Enum.KeyCode.C then
                if not self.crouch then
                    self.crouch = true

                    if self.animations.Sprint.IsPlaying then
                        self.animations.Sprint:Stop()
                    end

                    if self.sprint then
                        self.humanoid.WalkSpeed = self.prevWalkSpeed
                        self.sprint = false
                    end

                    self.animations.Crouch:Play()

                    self.prevWalkSpeed = self.humanoid.WalkSpeed
                    self.humanoid.WalkSpeed = 6

                elseif self.crouch then
                    self.crouch = false

                    if self.animations.CrouchWalk.IsPlaying then
                        self.animations.CrouchWalk:Stop()
                    end

                    self.animations.Crouch:Stop()

                    self.humanoid.WalkSpeed = self.prevWalkSpeed
                    self.prevWalkSpeed = 0
                end
            end
        end
    end)

    UserInput.InputEnded:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent then
            --sprinting
            if input.KeyCode == Enum.KeyCode.LeftShift then
                if self.sprint then
                    if self.crouch then
                        return
                    end

                    self.sprint = false

                    self.animations.Sprint:Stop()

                    self.humanoid.WalkSpeed = self.prevWalkSpeed
                    self.prevWalkSpeed = 0
                end
            end
        end
    end)
end

function MovementModule:Update(deltaTime)
    if self.humanoid then
        local moveDir = self.humanoid.MoveDirection.Magnitude
        
        --little to no movement
        if moveDir <= .5 then
            if self.animations.Sprint.IsPlaying and self.sprint and not self.crouch then
                self.animations.Sprint:Stop()
            end

            if self.animations.CrouchWalk.IsPlaying and self.crouch then
                self.animations.CrouchWalk:Stop()
            end
        elseif moveDir > .5 then
            if not self.animations.Sprint.IsPlaying and self.sprint and not self.crouch then
                self.animations.Sprint:Play()
            end

            if not self.animations.CrouchWalk.IsPlaying and self.crouch then
                self.animations.CrouchWalk:Play()
            end
        end
    end
end

return MovementModule