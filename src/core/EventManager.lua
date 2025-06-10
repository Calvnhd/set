-- Event Manager - Publisher-subscriber pattern for decoupled communication
local EventManager = {}

-- required modules
local Logger = require('core.Logger')
local EventRegistry = require('config.EventRegistry')

-- local variables
local listeners = {} -- Table to store event subscriptions

---------------
-- functions --
---------------

-- Verify if an event exists in the Events registry
-- Returns true if the event name exists in the Events registry, false otherwise
function EventManager.checkEventExists(eventName)
    -- Nil check
    if not eventName then
        Logger.error("EventManager", "Event does not exist: eventName is nil")
        error("Event does not exist: eventName is nil")
        return false
    end
    -- Search through all event categories in the Events table
    for category, categoryEvents in pairs(EventRegistry) do
        if type(categoryEvents) == "table" then
            -- Check each event in this category
            for _, registeredEvent in pairs(categoryEvents) do
                if registeredEvent == eventName then
                    return true
                end
            end
        end
    end
    Logger.error("EventManager", "Event does not exist: " .. eventName)
    error("Event does not exist: " .. eventName)
    return false
end

-- Subscribe to an event.  Adds a callback to the listeners table for a specific event
function EventManager.subscribe(eventName, callback)
    EventManager.checkEventExists(eventName)
    if not listeners[eventName] then
        listeners[eventName] = {}
    end
    table.insert(listeners[eventName], callback)
end

-- Unsubscribe from an event (removes the first matching callback)
function EventManager.unsubscribe(eventName, callback)
    if listeners[eventName] then
        for i, listener in ipairs(listeners[eventName]) do
            if listener == callback then
                table.remove(listeners[eventName], i)
                break
            end
        end
    end
end

-- Emit an event to all subscribers
function EventManager.emit(eventName, ...)
    EventManager.checkEventExists(eventName)
    Logger.trace("EventManager", "Event emitted: " .. eventName)
    if listeners[eventName] then
        for _, callback in ipairs(listeners[eventName]) do
            callback(...)
        end
    end
end

-- Clear all listeners for an event
function EventManager.clear(eventName)
    listeners[eventName] = nil
end

-- Clear all listeners for all events
function EventManager.clearAll()
    listeners = {}
end

return EventManager
