-- State Machine - Formal state management with transition validation

local StateMachine = {}
StateMachine.__index = StateMachine

-- Create a new state machine
function StateMachine.new(initialState)
    local sm = setmetatable({}, StateMachine)
    sm.currentState = initialState
    sm.states = {}
    sm.transitions = {}
    return sm
end

-- Add a state to the state machine
function StateMachine:addState(stateName, stateObject)
    self.states[stateName] = stateObject
end

-- Add a valid transition between states
function StateMachine:addTransition(fromState, toState, condition)
    if not self.transitions[fromState] then
        self.transitions[fromState] = {}
    end
    self.transitions[fromState][toState] = condition or function() return true end
end

-- Transition to a new state
function StateMachine:transitionTo(newState)
    -- Check if transition is valid
    if self.transitions[self.currentState] and 
       self.transitions[self.currentState][newState] and
       self.transitions[self.currentState][newState]() then
        
        -- Exit current state
        local currentStateObj = self.states[self.currentState]
        if currentStateObj and currentStateObj.exit then
            currentStateObj.exit()
        end
        
        -- Change state
        local oldState = self.currentState
        self.currentState = newState
        
        -- Enter new state
        local newStateObj = self.states[newState]
        if newStateObj and newStateObj.enter then
            newStateObj.enter()
        end
        
        return true
    end
    
    return false -- Transition not allowed
end

-- Get current state
function StateMachine:getCurrentState()
    return self.currentState
end

-- Update current state
function StateMachine:update(dt)
    local stateObj = self.states[self.currentState]
    if stateObj and stateObj.update then
        stateObj.update(dt)
    end
end

-- Handle events for current state
function StateMachine:handleEvent(eventName, ...)
    local stateObj = self.states[self.currentState]
    if stateObj and stateObj[eventName] then
        stateObj[eventName](...)
    end
end

return StateMachine
