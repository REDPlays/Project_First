local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local UI = Assets:WaitForChild("UI")
local InteractUI = UI:WaitForChild("Interact")

local Events = ReplicatedStorage:WaitForChild("Events")

local UIS = game:GetService("UserInputService")

local DialogueNPC_Client = {}
DialogueNPC_Client.__index = DialogueNPC_Client

function DialogueNPC_Client.new(npc: Model)
    local newNPC = {}
    setmetatable(newNPC, DialogueNPC_Client)

    newNPC.npc = npc

    return newNPC
end

function DialogueNPC_Client:Init()
    self.rootPart = self.npc:WaitForChild("HumanoidRootPart")

   self.proximity = self.rootPart:WaitForChild("ProximityPrompt")

   self.guiAttach = Instance.new("Attachment")
   self.guiAttach.Name = "guiAttach"
   self.guiAttach.Parent = self.rootPart
   self.guiAttach.CFrame = CFrame.new(0, 3, 0)
    
    self:Connections()
end

function DialogueNPC_Client:Connections()
    self.shown = self.proximity.PromptShown:Connect(function(inputType)
        self.button = InteractUI:Clone()
        self.button .Adornee = self.guiAttach
        self.button.Parent = self.rootPart

        self.input = UIS.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.E then
                if self.input then
                    self.input:Disconnect()
                    self.input = nil
                end

                local npcID = self.npc:GetAttribute("ID")

                local canInteract = Events.ClientToServer.RequestDialogue:InvokeServer(npcID)
                if canInteract.interact then
                    warn("User can speak to NPC")
                else
                    warn(canInteract.reason)
                end
            end
        end)
    end)

    self.hidden = self.proximity.PromptHidden:Connect(function()
        if self.button  then
            self.button:Destroy()
            self.button = nil
        end

        if self.input then
            self.input:Disconnect()
            self.input = nil
        end
    end)
end

return DialogueNPC_Client