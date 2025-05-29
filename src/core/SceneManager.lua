-- Scene Manager - Manages scene transitions and Love2D callback delegation
local SceneManager = {}

-- required modules
local Logger = require('core.Logger')
local EventRegistry = require('core.EventRegistry')
local EventManager = require('core.EventManager')
local SceneRegistry = require('scenes.SceneRegistry')

-- local variables
local currentScene = nil
local registeredScenes = {}

---------------
-- functions --
---------------

function SceneManager.initialize()
    Logger.trace("Initializing SceneManager")
    -- Set background color
    love.graphics.setBackgroundColor(0.34, 0.45, 0.47)
    -- Register scenes
    SceneManager.registerScene(SceneRegistry.MENU.NAME, SceneRegistry.MENU.SCENE)
    SceneManager.registerScene(SceneRegistry.GAME.NAME, SceneRegistry.GAME.SCENE)
    -- Subscribe to scene change events
    EventManager.subscribe(EventRegistry.SCENE.CHANGE_TO_GAME, function()
        SceneManager.changeScene(SceneRegistry.GAME.NAME)
    end)
    EventManager.subscribe(EventRegistry.SCENE.CHANGE_TO_MENU, function()
        SceneManager.changeScene(SceneRegistry.MENU.NAME)
    end)
    -- Start with menu scene
    SceneManager.changeScene(SceneRegistry.MENU.NAME)
end

-- Register a scene
-- sceneName: a string of the name of the scene, SceneRegistry.<SCENETYPE>.NAME
-- sceneModule: the actual scene object, SceneRegistry.<SCENETYPE>.SCENE
function SceneManager.registerScene(sceneName, scene)
    registeredScenes[sceneName] = scene
    Logger.info("Scene registered: %s", sceneName)
end

-- Change to a new scene
function SceneManager.changeScene(sceneName, ...)
    local newScene = registeredScenes[sceneName]
    if not newScene then
        Logger.error("Scene '%s' not registered", sceneName)
        error("Scene '" .. sceneName .. "' not found")
    end
    Logger.info("Changing scene to: %s", sceneName)

    -- Exit current scene
    if currentScene and currentScene.exit then
        Logger.trace("Exiting current scene")
        currentScene.exit()
    end
    currentScene = newScene

    -- Enter new scene with parameters
    currentScene.enter(...)
end

return SceneManager
