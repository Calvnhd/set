-- Scene Manager - Manages scene transitions and Love2D callback delegation

local SceneManager = {}

local currentScene = nil
local scenes = {}

-- Register a scene
function SceneManager.registerScene(name, scene)
    scenes[name] = scene
end

-- Change to a new scene
function SceneManager.changeScene(sceneName)
    local newScene = scenes[sceneName]
    if not newScene then
        error("Scene '" .. sceneName .. "' not found")
    end
    
    -- Exit current scene
    if currentScene and currentScene.exit then
        currentScene.exit()
    end
    
    -- Set new scene
    currentScene = newScene
    
    -- Enter new scene
    if currentScene.enter then
        currentScene.enter()
    end
end

-- Get current scene name
function SceneManager.getCurrentScene()
    for name, scene in pairs(scenes) do
        if scene == currentScene then
            return name
        end
    end
    return nil
end

-- Love2D callbacks - delegate to current scene
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
