local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInput = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local Animations = ReplicatedStorage:WaitForChild("TestAnimations")

local defaultFadeTime = 0.100000001
local defaultWeight = 1
local defaultSpeed = 1

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
    self.animator = self.humanoid:WaitForChild("Animator")
    self.rootPart = self.character:WaitForChild("HumanoidRootPart")

    self.prevWalkSpeed = 0

    self.sprint = false
    self.crouch = false
    self.attack = false
    self.block = false

    self.attach = Instance.new("Attachment")
    self.attach.Parent = self.rootPart

    self:Setup()
    self:Connections()
end

function MovementModule:Setup()
    self.animations = {
        ["Walk"] = self.animator:LoadAnimation(Animations.Walk),
        ["Sprint"] = self.animator :LoadAnimation(Animations.Run),
        ["Crouch"] = self.animator :LoadAnimation(Animations.Crouch),
        ["CrouchWalk"] = self.animator :LoadAnimation(Animations.CrouchWalk),
    }
end

function MovementModule:Connections()
    self.inputBegan = UserInput.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent then
            if self.attack then
                return
            end

            if self.block then
                return
            end
            --sprinting
            if input.KeyCode == Enum.KeyCode.LeftShift then
                if not self.sprint then
                    if self.crouch then
                        return
                    end

                    self.sprint = true

                    if self.animations.Walk.IsPlaying then
                        self.animations.Walk:Stop()
                    end

                    self.animations.Sprint:Play()

                    self.prevWalkSpeed = self.humanoid.WalkSpeed
                    self.humanoid.WalkSpeed = 24
                end
            end

            if input.KeyCode == Enum.KeyCode.C then
                if not self.crouch then
                    self.crouch = true

                    if self.animations.Walk.IsPlaying then
                        self.animations.Walk:Stop()
                    end

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

    self.inputEnded = UserInput.InputEnded:Connect(function(input, gameProcessedEvent)
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

function MovementModule:CombatMovement(toggle)
    if not self.attach then
        return
    end

    if toggle then
        if self.sprint then
            self.sprint = false
            self.animations.Sprint:Stop()
            self.humanoid.WalkSpeed = self.prevWalkSpeed
            self.prevWalkSpeed = 0
        end

        if self.crouch then
            self.crouch = false

            if self.animations.CrouchWalk.IsPlaying then
                self.animations.CrouchWalk:Stop()
            end

            self.animations.Crouch:Stop()
            self.humanoid.WalkSpeed = self.prevWalkSpeed
            self.prevWalkSpeed = 0
        end

        self.attack = true

        self.prevWalkSpeed = self.humanoid.WalkSpeed
        self.humanoid.WalkSpeed = 0

        local vel = Instance.new("LinearVelocity")
        vel.Attachment0 = self.attach
        vel.MaxForce = 1e5
        vel.Enabled = true
        vel.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        vel.VectorVelocity = Vector3.new(0, 0, -15)
        vel.Parent = self.attach
        
        Debris:AddItem(vel, .1)
    else
        self.attack = false

        self.humanoid.WalkSpeed = self.prevWalkSpeed
        self.prevWalkSpeed = 0
    end
end

function MovementModule:BlockMovement(toggle)
    if toggle then
        if self.sprint then
            self.sprint = false
            self.animations.Sprint:Stop()
            self.humanoid.WalkSpeed = self.prevWalkSpeed
            self.prevWalkSpeed = 0
        end

        if self.crouch then
            self.crouch = false

            if self.animations.CrouchWalk.IsPlaying then
                self.animations.CrouchWalk:Stop()
            end

            self.animations.Crouch:Stop()
            self.humanoid.WalkSpeed = self.prevWalkSpeed
            self.prevWalkSpeed = 0
        end

        self.block = true

        self.prevWalkSpeed = self.humanoid.WalkSpeed
        self.humanoid.WalkSpeed = 4
    else
        self.block = false

        self.humanoid.WalkSpeed = self.prevWalkSpeed
        self.prevWalkSpeed = 0
    end
end

function MovementModule:Disconnect()
    if self.inputBegan then
        self.inputBegan:Disconnect()
        self.inputBegan = nil
    end

    if self.inputEnded then
        self.inputEnded:Disconnect()
        self.inputEnded = nil
    end
end

function MovementModule:Update(deltaTime)
    if self.humanoid then
        local moveDir = self.humanoid.MoveDirection.Magnitude
        
        --little to no movement
        if moveDir <= .5 then
            if self.animations.Walk.IsPlaying and not self.sprint and not self.crouch then
                self.animations.Walk:Stop()
            end

            if self.animations.Sprint.IsPlaying and self.sprint and not self.crouch then
                self.animations.Sprint:Stop()
            end

            if self.animations.CrouchWalk.IsPlaying and self.crouch then
                self.animations.CrouchWalk:Stop()
            end
        elseif moveDir > .5 then
            if not self.animations.Walk.IsPlaying and not self.sprint and not self.crouch then
                self.animations.Walk:Play()
            end

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