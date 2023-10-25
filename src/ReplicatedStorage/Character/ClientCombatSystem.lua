local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInput = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local Events = ReplicatedStorage:WaitForChild("Events")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Misc = Assets:WaitForChild("Misc")
local Sounds = Assets:WaitForChild("Sounds")
local CombatSounds = Sounds:WaitForChild("Combat")
local MeleeSounds = CombatSounds:WaitForChild("Melee")

local HitboxSystem = require(ReplicatedStorage.RepFiles.HitboxSystem)

local ClientCombatSystem = {}
ClientCombatSystem.__index = ClientCombatSystem

function ClientCombatSystem.new()
    local newClientCombat = {}
    setmetatable(newClientCombat, ClientCombatSystem)

    return newClientCombat
end

function ClientCombatSystem:Init(character, animationSystem, movementSystem)
    self.character = character
    self.humanoid = self.character:WaitForChild("Humanoid")
    self.rootPart = self.character:WaitForChild("HumanoidRootPart")
    self.animator = self.humanoid:WaitForChild("Animator")

    self.animationSystem = animationSystem
    self.movementSystem = movementSystem

    self:Setup()
    self:Connections()
end

function ClientCombatSystem:Setup()
    self.debounce = false
    self.block = false
    self.cooldown = 1

    self.sequence = ""
    self.maxSeq = 5
    self.currTime = 0
    self.prevTime = 0
end

function ClientCombatSystem:GetSound()
    --function for getting the type/style of combat being used i.e, fist, swords, shields, etc.
    local soundHolder = Misc.SoundHolder:Clone()
    soundHolder.CFrame = self.rootPart.CFrame
    soundHolder.Parent = workspace.VFX

    local swingSFX = MeleeSounds.Swing:Clone()
    swingSFX.Parent = soundHolder
    swingSFX:Play()

    Debris:AddItem(soundHolder, 1)
end

function ClientCombatSystem:Connections()
    self.inputBegan = UserInput.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent then
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if self.debounce then
                    return
                end

                if self.block then
                    return
                end

                self.currTime = os.clock()
                self.debounce = true

                self.sequence ..= "L"
                if string.len(self.sequence) > self.maxSeq then
                    self.sequence = "L"
                end

                if self.currTime - self.prevTime >= 1 then
                    self.sequence = "L"
                end

                local canAction = Events.ClientToServer.Combat:InvokeServer(self.sequence)
                if not canAction then
                    self.debounce = false
                    return
                end

                if canAction.value == true then
                    local animInfo = self.animationSystem:Play(self.sequence, Enum.AnimationPriority.Action)

                    --swinging sound fx
                    self:GetSound()

                    self.movementSystem:CombatMovement(true)

                    task.delay(animInfo.hitboxDelay, function()
                        HitboxSystem:CreateBox(self.character, self.rootPart.CFrame * CFrame.new(0, 0, -2), Vector3.new(4, 6, 4), nil, self.sequence)
                    end)

                    task.delay(animInfo.length * .8, function()
                        self.movementSystem:CombatMovement(false)
                    end)
                elseif canAction.value == false then
                    warn("reason:", canAction.reason)

                    self.debounce = false
                end
            elseif input.KeyCode == Enum.KeyCode.F then
                if self.debounce then
                    return
                end

                if not self.block then
                    self.block = true

                    local canBlock = Events.ClientToServer.Block:InvokeServer(self.block)
                    if canBlock.value == true then
                        local animInfo = self.animationSystem:Play("MeleeBlock", Enum.AnimationPriority.Action)

                        --movement system
                        --self.movementSystem
                    elseif canBlock.value == false then
                        warn("reason:", canBlock.reason)
                        self.block = false
                    end
                end
            end
        end
    end)

    local function runCooldown()
        self:runCoolDown()
    end

    Events.ClientToServer.Combat.OnClientInvoke = runCooldown
end

function ClientCombatSystem:Disconnect()
    if self.inputBegan then
        self.inputBegan:Disconnect()
        self.inputBegan = nil
    end
end

function ClientCombatSystem:runCoolDown()
    self.prevTime = self.currTime

    if string.len(self.sequence) >= self.maxSeq then
        task.wait(self.cooldown)
        self.debounce = false
    else
        self.debounce = false
    end
end

function ClientCombatSystem:Update(deltaTime)
    
end

return ClientCombatSystem