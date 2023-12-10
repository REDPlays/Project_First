local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DialogueNPC = {}
DialogueNPC.__index = DialogueNPC

function DialogueNPC.new(npc: Model)
    local newNPC = {}
    setmetatable(newNPC, DialogueNPC)

    newNPC.npc = npc

    return newNPC
end

function DialogueNPC:Init()
    self.rootPart = self.npc:WaitForChild("HumanoidRootPart")

    self.proximity = Instance.new("ProximityPrompt")
    self.proximity.MaxActivationDistance = 15
    self.proximity.Style = Enum.ProximityPromptStyle.Custom
    self.proximity.RequiresLineOfSight = false
    self.proximity.Parent = self.rootPart
end

function DialogueNPC:Update(deltaTime)
    
end

return DialogueNPC