local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VisualEffects = ReplicatedStorage:WaitForChild("VisualEffects")
local CombatVFX = VisualEffects:WaitForChild("Combat")
local MeleeVFX = CombatVFX:WaitForChild("Melee")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")
local CombatSounds = Sounds:WaitForChild("Combat")
local MeleeSounds = CombatSounds:WaitForChild("Melee")

local Melee = {}

function Melee:Spawn(user, target, conditionalData)
    if not target then
        return
    end

    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    conditionalData.sequenceLength = conditionalData.sequenceLength or 1

    local folder = Instance.new("Folder")
    folder.Name = "meleevfx"
    folder.Parent = workspace.VFX
    Debris:AddItem(folder, .5)

    if conditionalData.sequenceLength < 5 then
        Melee:Normal(folder, targetRoot)
    else
        Melee:Empowered(folder, targetRoot)
    end
end

function Melee:Normal(folder, targetRoot)
    local HitEffects = MeleeVFX.HitEffects:Clone()
    HitEffects.Transparency = 1
    HitEffects.CFrame = targetRoot.CFrame
    HitEffects.Parent = folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = HitEffects
    weld.Part1 = targetRoot
    weld.Parent = weld.Part0

    local randomPitch = math.random(95, 105)/100

    local sfx = MeleeSounds.Punch:Clone()
    sfx.PitchShift.Octave = randomPitch
    sfx.Parent = HitEffects
    sfx:Play()

    HitEffects.Attachment.Ring:Emit(2)
    HitEffects.Attachment.Spheres:Emit(16)
    HitEffects.Attachment.Stars:Emit(3)
end

function Melee:Empowered(folder, targetRoot)
    
end

return Melee