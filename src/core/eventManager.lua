-- Event Manager - Publisher-subscriber pattern for decoupled communication
local Logger = require('core.logger')

local EventManager = {}

-- Table to store event subscriptions
local listeners = {}

-- Subscribe to an event
function EventManager.subscribe(eventName, callback)
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
    Logger.trace("Event emitted: "..eventName)
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
