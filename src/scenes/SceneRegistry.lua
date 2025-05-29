-- Scene Registry - Centralized name and module constants

local MenuScene = require('scenes.MenuScene')
local GameScene = require('scenes.GameScene')

local SceneRegistry = {
    MENU = {
        NAME = "menu",
        SCENE = MenuScene
    },
    GAME = {
        NAME = "game",
        SCENE = GameScene
    }
}
return SceneRegistry
