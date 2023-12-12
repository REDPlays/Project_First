local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Events = ReplicatedStorage:WaitForChild("Events")

local DialogueController = {}
DialogueController.__index = DialogueController

function DialogueController.new()
    local newDialogue = {}
    setmetatable(newDialogue, DialogueController)

    return newDialogue
end

function DialogueController:Init(player: Player, uniqueID)
    self.player = player
    self.playerGui = self.player:WaitForChild("PlayerGui")
    self.gui = self.playerGui:WaitForChild("Gui")
    self.uniqueID = uniqueID

    self.DialogueFrame = self.gui:WaitForChild("DialogueFrame")
    self.Holder = self.DialogueFrame:WaitForChild("Holder")
    self.Options = self.Holder:WaitForChild("Options")
    self.NPCName = self.Holder:WaitForChild("NPCName")
    self.Subject = self.Holder:WaitForChild("Subject")

    self.dialogueTree = {}
    self.dialogueTree[1] = self:RequestDialogue(1)

    self.currentBranch = self.dialogueTree[1]

    self.buttons = {}
    self.buttonConnections = {}
    self:Reset()

    self:createButtons()
end

function DialogueController:Reset()
    self.Holder.GroupTransparency = 1
end

function DialogueController:RequestDialogue(tier: number)
    local dialogueBranch = Events.ClientToServer.DialogueBranch:InvokeServer(self.uniqueID, tier)
    if not dialogueBranch then
        error("Failed to get dialogue branch for NPC:", dialogueBranch)
        return
    end

    return dialogueBranch
end

function DialogueController:createButtons()
    for i, btn in pairs(self.Options:GetChildren()) do
        self.buttons[i] = btn
    end
end

function DialogueController:BuildButtons(tier: number)
    self.currentBranch = self.dialogueTree[tier]

    local numAnswers = 0
    for _, _ in pairs(self.currentBranch.answers) do
        numAnswers += 1
    end

    for i, btn in pairs(self.buttons) do
        --ignore functionality if you exceed count of answers
        if i > numAnswers then
            btn.Visible = false
            continue
        end

        btn.Description.Text = self.currentBranch.answers[i]

        self.buttonConnections[i] = btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                print(self.currentBranch.answers[i])

                for i, connection in pairs(self.buttonConnections) do
                    self.buttonConnections[i]:Disconnect()
                end

                if i == numAnswers then
                    self:PlayOut()
                end
            end
        end)
    end
end

function DialogueController:PlayIn(tier: number)
    self:BuildButtons(tier)
    
    local info = TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    TweenService:Create(self.Holder, info, {GroupTransparency = 0}):Play()
end

function DialogueController:PlayOut()
    local info = TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    TweenService:Create(self.Holder, info, {GroupTransparency = 1}):Play()
end

return DialogueController