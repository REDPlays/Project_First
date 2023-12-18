local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local MovementModule = require(ReplicatedStorage.RepFiles.Character.MovementModule)
local AnimationSystem = require(ReplicatedStorage.RepFiles.Character.AnimationSystem)
local ClientCombatSystem = require(ReplicatedStorage.RepFiles.Character.ClientCombatSystem)
local VisualEffectsManager = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectsManager)
local CameraManager = require(ReplicatedStorage.RepFiles.Character.CameraManager)

local GuiController = require(ReplicatedStorage.RepFiles.UI.guiController)
--local DialogueNPC = require(ReplicatedStorage.RepFiles.NPCs.DialogueNPC_Client)


local LocalGameManager = {}
LocalGameManager.isLoaded = false

LocalGameManager.dialogueNPCs = {}

function LocalGameManager:Init(player)
    LocalGameManager.player = player
    LocalGameManager.character = LocalGameManager.player.Character
    LocalGameManager.humanoid = LocalGameManager.character:WaitForChild("Humanoid")

    LocalGameManager.guiController = GuiController.new(player)
    LocalGameManager.guiController:Init()

    LocalGameManager:Setup()
end

function LocalGameManager:Setup()
    if LocalGameManager.isLoaded then
        return
    end

    LocalGameManager.isLoaded = true

    LocalGameManager.movement = MovementModule.new(LocalGameManager.character)
    LocalGameManager.animationSystem = AnimationSystem.new(LocalGameManager.character, LocalGameManager.movement)

    LocalGameManager.combatSystem = ClientCombatSystem.new()
    LocalGameManager.combatSystem:Init(LocalGameManager.character, LocalGameManager.animationSystem, LocalGameManager.movement)

    LocalGameManager.cameraSystem = CameraManager.new()
    LocalGameManager.cameraSystem:Init(LocalGameManager.player)
end

function LocalGameManager:RequestNPC(npcList)
   --[==[for ID, npc in pairs(npcList) do
        local newDialogue = DialogueNPC.new(npc)
        newDialogue:Init(Players.LocalPlayer)

        LocalGameManager.dialogueNPCs[ID] = {
            npc = npc,
            dialogue = newDialogue
        }
    end]==]
end

function LocalGameManager:Heartbeat(deltaTime)
    if LocalGameManager.humanoid.Health <= 0 then
        --reset
        if LocalGameManager.movement then
            LocalGameManager.movement :Disconnect()
        end

        if LocalGameManager.animationSystem then
            LocalGameManager.animationSystem :Disconnect()
        end

        if LocalGameManager.combatSystem then
            LocalGameManager.combatSystem:Disconnect()
        end

        LocalGameManager.movement  = nil
        LocalGameManager.animationSystem = nil

        LocalGameManager.isLoaded = false
        return
    end

    if LocalGameManager.guiController then
        LocalGameManager.guiController:Update(deltaTime) 
    end

    VisualEffectsManager:Update(deltaTime)

    if LocalGameManager.movement then
        LocalGameManager.movement:Update(deltaTime)
    end

    if LocalGameManager.animationSystem then
        LocalGameManager.animationSystem:Update(deltaTime)
    end

    if LocalGameManager.combatSystem then
        LocalGameManager.combatSystem:Update(deltaTime)
    end

    if  LocalGameManager.cameraSystem then
        LocalGameManager.cameraSystem:Update(deltaTime)
    end
end

return LocalGameManager