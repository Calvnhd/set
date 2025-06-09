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
    Logger.trace("SceneManager", "Initializing SceneManager")
    -- Register scenes
    SceneManager.registerScene(Constants.SCENE.MENU, MenuScene)
    SceneManager.registerScene(Constants.SCENE.GAME, GameScene)
    -- Subscribe to scene change events
    EventManager.subscribe(Events.SCENE.REQUEST_CHANGE, SceneManager.onSceneChangeRequested)
    -- Subscribe to input events
    EventManager.subscribe(Events.INPUT.KEY_PRESSED, SceneManager.onKeyPressed)
    EventManager.subscribe(Events.INPUT.MOUSE_PRESSED, SceneManager.onMousePressed)
    -- Start with menu scene
    SceneManager.changeScene(Constants.SCENE.MENU)
end

-- Register a scene
-- sceneName: a string of the name of the scene, SceneRegistry.<SCENETYPE>.NAME
-- sceneModule: the actual scene object, SceneRegistry.<SCENETYPE>.SCENE
function SceneManager.registerScene(sceneName, scene)
    registeredScenes[sceneName] = scene
    Logger.info("SceneManager", "Scene registered: %s", sceneName)
end

function SceneManager.onSceneChangeRequested(sceneName, ...)
    if not sceneName then
        Logger.error("SceneManager", "Scene change requested, but sceneName is nil")
        error("Scene change requested, but sceneName is nil")
    else
        Logger.info("SceneManager", "Requested scene change to: " .. sceneName)
        SceneManager.changeScene(sceneName, ...)
    end
end

-- Change to a new scene
function SceneManager.changeScene(sceneName, ...)
    local newScene = registeredScenes[sceneName]
    if not newScene then
        Logger.error("SceneManager", "Scene '%s' not registered", sceneName)
        error("Scene '" .. sceneName .. "' not found")
    end
    Logger.info("SceneManager", "Changing scene to: %s", sceneName)
    -- Exit current scene
    if currentScene and currentScene.exit then
        currentScene.exit()
    end
    currentScene = newScene
    -- Enter new scene with parameters
    currentScene.enter(...)
end

-- Love2D callbacks from main, delegates to current scene
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
-- input events, delegates to current scene
function SceneManager.onKeyPressed(key)
    if currentScene and currentScene.onKeyPressed then
        currentScene.onKeyPressed(key)
    end
end
function SceneManager.onMousePressed(x, y, button)
    if currentScene and currentScene.onMousePressed then
        currentScene.onMousePressed(x, y, button)
    end
end

return SceneManager
