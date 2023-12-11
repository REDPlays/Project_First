local DialogueSystem = {}
DialogueSystem.__index = DialogueSystem

function DialogueSystem.new()
    local newDialogueSystem = {}
    setmetatable(newDialogueSystem, DialogueSystem)

    return DialogueSystem
end

function DialogueSystem:Init()
    
end

function DialogueSystem:Update(deltaTime)
    
end

return DialogueSystem