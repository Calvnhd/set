-- Scene Manager - Manages scene transitions and Love2D callback delegation
local SceneManager = {}

-- required modules
local Logger = require('core.Logger')
local Events = require('config.EventRegistry')
local EventManager = require('core.EventManager')
local Constants = require('config.Constants')
local MenuScene = require('scenes.MenuScene')
local GameScene = require('scenes.GameScene')

-- local variables
local currentScene = nil
local registeredScenes = {}

---------------
-- functions --
---------------

function SceneManager.initialize()
    Logger.trace("Initializing SceneManager")
    -- Register scenes
    SceneManager.registerScene(Constants.SCENE.MENU, MenuScene)
    SceneManager.registerScene(Constants.SCENE.GAME, GameScene)
    -- Subscribe to scene change events
    EventManager.subscribe(Events.SCENE.REQUEST_CHANGE, SceneManager.onSceneChangeRequested)
    -- Start with menu scene
    SceneManager.changeScene(Constants.SCENE.MENU)
end

-- Register a scene
-- sceneName: a string of the name of the scene, SceneRegistry.<SCENETYPE>.NAME
-- sceneModule: the actual scene object, SceneRegistry.<SCENETYPE>.SCENE
function SceneManager.registerScene(sceneName, scene)
    registeredScenes[sceneName] = scene
    Logger.info("Scene registered: %s", sceneName)
end

function SceneManager.onSceneChangeRequested(sceneName, ...)
    if not sceneName then
        Logger.error("Scene change requested, but sceneName is nil")
        error("Scene change requested, but sceneName is nil")
    else
        Logger.info("Requested scene change to: " .. sceneName)
        SceneManager.changeScene(sceneName, ...)
    end
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
        currentScene.exit()
    end
    currentScene = newScene
    -- Enter new scene with parameters
    currentScene.enter(...)
end

-- Love2D callbacks from main
-- Delegates to current scene
function SceneManager.update(dt)
    if currentScene and currentScene.update then
        currentScene.update(dt)
    end
end
function SceneManager.draw()
    if currentScene and currentScene.draw then
        currentScene.draw()
    end
end
function SceneManager.keypressed(key)
    if currentScene and currentScene.keypressed then
        currentScene.keypressed(key)
    end
end
function SceneManager.mousepressed(x, y, button)
    if currentScene and currentScene.mousepressed then
        currentScene.mousepressed(x, y, button)
    end
end
function SceneManager.mousereleased(x, y, button)
    if currentScene and currentScene.mousereleased then
        currentScene.mousereleased(x, y, button)
    end
end

return SceneManager
