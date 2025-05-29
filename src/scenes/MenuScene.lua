-- Menu Scene - Main menu 
local MenuScene = {}

-- required modules
local EventManager = require('core.EventManager')
local Events = require('core.EventRegistry')
local Logger = require('core.Logger')

---------------
-- functions --
---------------

function MenuScene.enter()
    Logger.trace("Entering main menu scene")
end

return MenuScene
