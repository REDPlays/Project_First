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
    --createNPCs()
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

local function sendDialogue(player, npcID)
    local info = {interact = false, reason = ""}

    if not npcID then
        info.reason = "NO NPC ID"
        return info
    end

    if not ServerGameManager.dialogueNPCs[npcID] then
        info.reason = "INVALID NPC"
        return info
    end

    --get dialogue system
    info.interact = true
    return info
end

local function getDialogue(player, npcID, tier)
    if not npcID then
        return
    end
    
    if not ServerGameManager.dialogueNPCs[npcID] then
        return
    end
    
    tier = tier or 1
   
    return ServerGameManager.dialogueNPCs[npcID].dialogue:GetBranch(tier)
end

Events.ClientToServer.RequestNPC.OnServerInvoke = sendNPCs
Events.ClientToServer.RequestDialogue.OnServerInvoke = sendDialogue
Events.ClientToServer.DialogueBranch.OnServerInvoke = getDialogue

return ServerGameManager