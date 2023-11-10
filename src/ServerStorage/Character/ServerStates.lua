local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebugSettings = require(ReplicatedStorage.RepFiles.DebugSettings)

local Animations = ReplicatedStorage:WaitForChild("TestAnimations")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local UI = Assets.UI

local ServerStates = {}

ServerStates.Stunned = {}
ServerStates.Blocking = {}
ServerStates.Rolling = {}
ServerStates.Untargetable = {}

ServerStates.Settings = {
    stunMax = 5,
    stunDegrade = 3,
}

--debuging
local debugTimer = 5
ServerStates.Blocking[workspace.BlockDummy] = {
    player = workspace.Dummy,
    blockHealth = 5,
    blockTime = os.clock()
}
workspace.BlockDummy:SetAttribute("Blocking", true)
local blockAnim = workspace.BlockDummy.Humanoid.Animator:LoadAnimation(Animations.Combat.Melee.Block)
blockAnim:Play()

--rounding helper
local function floor(x)
    return x - x % 1
end

function ServerStates:StunTarget(target: Model, duration)
    if not target then
        return
    end

    if not duration then
        return
    end

    if ServerStates.Stunned[target] then
        ServerStates.Stunned[target].currTime = 0
        ServerStates.Stunned[target].duration = duration
        ServerStates.Stunned[target].stunCount += 1

        local currCount = ServerStates.Stunned[target].duration - ServerStates.Stunned[target].currTime
        currCount = floor(currCount * (10^2)) / (10^2)

        ServerStates.Stunned[target].UI.Background.Duration.Text = currCount
        ServerStates.Stunned[target].UI.Background.Count.Text = ServerStates.Stunned[target].stunCount
        return
    end

    local rootPart = target:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local stunAttach = Instance.new("Attachment")
    stunAttach.Name = "stunAttach"
    stunAttach.Parent = rootPart
    stunAttach.CFrame = CFrame.new(0, 5, 0)

    local infoUI = UI.StunCounter:Clone()
    infoUI.Adornee = stunAttach
    infoUI.Parent = target

    ServerStates.Stunned[target] = {
        target = target,
        duration = duration,
        currTime = 0,
        stunCount = 1,
        Attachment = stunAttach,
        UI = infoUI
    }

    target:SetAttribute("Stunned", true)

    local currCount = ServerStates.Stunned[target].duration - ServerStates.Stunned[target].currTime
    currCount = floor(currCount * (10^2)) / (10^2)

    ServerStates.Stunned[target].UI.Background.Duration.Text = currCount
    ServerStates.Stunned[target].UI.Background.Count.Text = ServerStates.Stunned[target].stunCount
end

function ServerStates:Block(character: Model, isActive: boolean)
    if not character then
        return
    end
    
    if isActive == true then
        if ServerStates.Blocking[character] then
            return
        end

        ServerStates.Blocking[character] = {
            player = character,
            blockHealth = 5,
            blockTime = os.clock()
        }
    elseif isActive == false then
        if not ServerStates.Blocking[character] then
            return
        end

        ServerStates.Blocking[character] = nil
    end
end

function ServerStates:UpdateBlock(target: Model, damage)
   if not target then
        return
   end 

   if not ServerStates.Blocking[target] then
        return
   end

   ServerStates.Blocking[target].blockHealth -= 1
   local health = ServerStates.Blocking[target].blockHealth

   if ServerStates.Blocking[target].blockHealth <= 0 then
        ServerStates.Blocking[target] = nil
   end

   return health
end

function ServerStates:Update(deltaTime)
    for targetId, data in pairs(ServerStates.Stunned) do
        data.currTime += deltaTime

        local currCount = data.duration - data.currTime
        currCount = floor(currCount * (10^2)) / (10^2)

        data.UI.Background.Duration.Text = currCount

        if data.stunCount > ServerStates.Settings.stunMax then
            data.UI.Background.Count.TextColor3 = Color3.fromRGB(255, 0, 0)
        end

        data.UI.Background.Count.Text = data.stunCount

        if data.currTime >= data.duration then
            if data.UI then
                data.UI:Destroy()
                data.UI = nil
            end

            if data.Attachment then
                data.Attachment:Destroy()
                data.Attachment = nil
            end

            ServerStates.Stunned[targetId] = nil
            data.target:SetAttribute("Stunned", false)
        end
    end

    for targetId, data in pairs(ServerStates.Blocking) do
        
    end

    if ServerStates.Stunned[workspace.BlockDummy] then
        if blockAnim.IsPlaying then
            blockAnim:Stop()
        end
    end

    if not workspace.BlockDummy:GetAttribute("Blocking") then
        debugTimer -= deltaTime
        if debugTimer <= 0 then
            ServerStates.Blocking[workspace.BlockDummy] = {
                player = workspace.BlockDummy,
                blockHealth = 5,
                blockTime = os.clock()
            }
            workspace.BlockDummy:SetAttribute("Blocking", true)

            blockAnim:Play()

            debugTimer = 5
        end
    end
end

return ServerStates