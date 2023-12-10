local guiController = {}
guiController.__index = guiController

function guiController.new(player: Player)
    local newGuiController = {}
    setmetatable(newGuiController, guiController)

    newGuiController.player = player

    return newGuiController
end

function guiController:Init()
    self.character = self.player

    self.playerGui = self.player:WaitForChild("PlayerGui")
    self.gui = self.playerGui:WaitForChild("Gui")

    self.DialogueFrame = self.gui:WaitForChild("DialogueFrame")
end

function guiController:Update(deltaTime)
    
end

return guiController