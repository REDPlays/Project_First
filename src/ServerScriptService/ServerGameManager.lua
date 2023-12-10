local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Http = game:GetService("HttpService")

local ServerCombatSystem = require(ServerStorage.RepFiles.Character.ServerCombatSystem)
local ServerStates = require(ServerStorage.RepFiles.Character.ServerStates)
local DialogueNPC = require(ReplicatedStorage.RepFiles.NPCs.DialogueNPC)

local Events = ReplicatedStorage:WaitForChild("Events")

local NPCs = workspace.NPCs

local ServerGameManager = {}
ServerGameManager.dialogueNPCs = {}

local function createNPCs()
    for _, npc in pairs(NPCs:GetChildren()) do
        local uniqueID = Http:GenerateGUID(false)

        npc:SetAttribute("ID", uniqueID)

        local newDialogue = DialogueNPC.new(npc)
        newDialogue:Init()

        ServerGameManager.dialogueNPCs[uniqueID] = {
            npc = npc,
            dialogue = newDialogue
        }
    end
end

function ServerGameManager:Init()
    createNPCs()
end

function ServerGameManager:Heartbeat(deltaTime)
    ServerStates:Update(deltaTime)
end

local function sendNPCs(player)
    local data = {}
    for ID, info in pairs(ServerGameManager.dialogueNPCs) do
        data[ID] = info.npc
    end

    return data
end

Events.ClientToServer.RequestNPC.OnServerInvoke = sendNPCs

return ServerGameManager