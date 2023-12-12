local DialogueSystem = {}
DialogueSystem.__index = DialogueSystem

function DialogueSystem.new()
    local newDialogueSystem = {}
    setmetatable(newDialogueSystem, DialogueSystem)

    return DialogueSystem
end

function DialogueSystem:Init()
    self.dialogueTree = {}
    self.dialogueTree[1] = self:CreateBasicA()

end

function DialogueSystem:CreateBasicA()
    local dialogueBranch = {}
    dialogueBranch.subject = ""
    dialogueBranch.answers = {}

    dialogueBranch.subject = "Hey, how's it going?"

    dialogueBranch.answers[1] = "It's going great!"
    dialogueBranch.answers[2] = "It could be better."
    dialogueBranch.answers[3] = "Leave me alone."

    return dialogueBranch
end

function DialogueSystem:Update(deltaTime)
    
end

return DialogueSystem