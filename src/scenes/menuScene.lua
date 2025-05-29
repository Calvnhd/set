-- Enter the menu scene
function MenuScene.enter()
    -- Subscribe to input events
    EventManager.subscribe(Events.INPUT.KEY_PRESSED, MenuScene.keypressed)
    EventManager.subscribe(Events.INPUT.MOUSE_PRESSED, MenuScene.mousepressed)
end

-- Exit the menu scene
function MenuScene.exit()
    -- Unsubscribe from events
    EventManager.unsubscribe(Events.INPUT.KEY_PRESSED, MenuScene.keypressed)
    EventManager.unsubscribe(Events.INPUT.MOUSE_PRESSED, MenuScene.mousepressed)
end

-- Handle mouse press events
function MenuScene.mousepressed(x, y, button)
    
    if button == 1 then -- Left mouse button
        if MenuView.isClassicButtonClicked(x, y) then
            Logger.info("Classic mode button clicked")
            EventManager.emit(Events.SCENE.CHANGE_TO_GAME, 'classic')
        elseif MenuView.isRogueButtonClicked(x, y) then
            Logger.info("Rogue mode button clicked")
            EventManager.emit(Events.SCENE.CHANGE_TO_GAME, 'rogue')
        end
    end
end

