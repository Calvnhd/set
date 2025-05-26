-- Configuration Validator Service - Validate round configurations and game settings

local ConfigValidator = {}

-- Valid attribute names and their possible values
local VALID_ATTRIBUTES = {
    number = {1, 2, 3},
    color = {"red", "green", "blue"},
    shape = {"diamond", "oval", "squiggle"},
    fill = {"empty", "solid", "stripes"}
}

-- Valid end condition types
local VALID_END_CONDITIONS = {"score", "sets"}

-- Validate a round configuration
function ConfigValidator.validateRoundConfig(config)
    if type(config) ~= "table" then
        return false, "Configuration must be a table"
    end
    
    -- Required fields
    if not config.id or type(config.id) ~= "string" then
        return false, "Configuration must have a valid 'id' string"
    end
    
    if not config.name or type(config.name) ~= "string" then
        return false, "Configuration must have a valid 'name' string"
    end
    
    -- Validate attributes
    local bValid, message = ConfigValidator.validateAttributes(config.attributes)
    if not bValid then
        return false, "Invalid attributes: " .. message
    end
      -- Validate set size
    if config.setSize then
        if type(config.setSize) ~= "number" or config.setSize < 3 or config.setSize > 4 then
            return false, "Set size must be a number between 3 and 4 (2-card sets are not valid for Set rules)"
        end
    end
    
    -- Validate board size
    if config.boardSize then
        local bValid, message = ConfigValidator.validateBoardSize(config.boardSize)
        if not bValid then
            return false, "Invalid board size: " .. message
        end
    end
    
    -- Validate scoring
    if config.scoring then
        local bValid, message = ConfigValidator.validateScoring(config.scoring)
        if not bValid then
            return false, "Invalid scoring: " .. message
        end
    end
    
    -- Validate end condition
    if config.endCondition then
        local bValid, message = ConfigValidator.validateEndCondition(config.endCondition)
        if not bValid then
            return false, "Invalid end condition: " .. message
        end
    end
    
    return true, "Configuration is valid"
end

-- Validate attributes configuration
function ConfigValidator.validateAttributes(attributes)
    if type(attributes) ~= "table" then
        return false, "Attributes must be a table"
    end
    
    for attrName, attrValues in pairs(attributes) do
        -- Check if attribute name is valid
        if not VALID_ATTRIBUTES[attrName] then
            return false, "Unknown attribute: " .. tostring(attrName)
        end
        
        -- Check if values are valid
        if type(attrValues) ~= "table" then
            return false, "Attribute values must be a table for: " .. attrName
        end
        
        if #attrValues == 0 then
            return false, "Attribute must have at least one value for: " .. attrName
        end
        
        for _, value in ipairs(attrValues) do
            local bFoundValid = false
            for _, validValue in ipairs(VALID_ATTRIBUTES[attrName]) do
                if value == validValue then
                    bFoundValid = true
                    break
                end
            end
            if not bFoundValid then
                return false, "Invalid value '" .. tostring(value) .. "' for attribute: " .. attrName
            end
        end
    end
    
    return true, "Attributes are valid"
end

-- Validate board size configuration
function ConfigValidator.validateBoardSize(boardSize)
    if type(boardSize) ~= "table" then
        return false, "Board size must be a table"
    end
    
    if type(boardSize.columns) ~= "number" or boardSize.columns < 1 or boardSize.columns > 10 then
        return false, "Columns must be a number between 1 and 10"
    end
    
    if type(boardSize.rows) ~= "number" or boardSize.rows < 1 or boardSize.rows > 10 then
        return false, "Rows must be a number between 1 and 10"
    end
    
    local totalCards = boardSize.columns * boardSize.rows
    if totalCards < 3 or totalCards > 50 then
        return false, "Total board size must be between 3 and 50 cards"
    end
    
    return true, "Board size is valid"
end

-- Validate scoring configuration
function ConfigValidator.validateScoring(scoring)
    if type(scoring) ~= "table" then
        return false, "Scoring must be a table"
    end
    
    local requiredFields = {"validSet", "invalidSet", "noSetCorrect", "noSetIncorrect"}
    for _, field in ipairs(requiredFields) do
        if scoring[field] == nil or type(scoring[field]) ~= "number" then
            return false, "Scoring must have numeric field: " .. field
        end
    end
    
    return true, "Scoring is valid"
end

-- Validate end condition configuration
function ConfigValidator.validateEndCondition(endCondition)
    if type(endCondition) ~= "table" then
        return false, "End condition must be a table"
    end
    
    if not endCondition.type or type(endCondition.type) ~= "string" then
        return false, "End condition must have a 'type' string"
    end
    
    local bValidType = false
    for _, validType in ipairs(VALID_END_CONDITIONS) do
        if endCondition.type == validType then
            bValidType = true
            break
        end
    end
    if not bValidType then
        return false, "Invalid end condition type: " .. endCondition.type
    end
    
    if not endCondition.target or type(endCondition.target) ~= "number" or endCondition.target <= 0 then
        return false, "End condition must have a positive numeric 'target'"
    end
    
    return true, "End condition is valid"
end

-- Validate a sequence of round configurations
function ConfigValidator.validateRoundSequence(rounds)
    if type(rounds) ~= "table" then
        return false, "Round sequence must be a table"
    end
    
    if #rounds == 0 then
        return false, "Round sequence must contain at least one round"
    end
    
    local usedIds = {}
    for i, config in ipairs(rounds) do
        local bValid, message = ConfigValidator.validateRoundConfig(config)
        if not bValid then
            return false, "Round " .. i .. ": " .. message
        end
        
        -- Check for duplicate IDs
        if usedIds[config.id] then
            return false, "Duplicate round ID: " .. config.id
        end
        usedIds[config.id] = true
    end
    
    return true, "Round sequence is valid"
end

-- Get valid attribute options (for configuration builders)
function ConfigValidator.getValidAttributes()
    return VALID_ATTRIBUTES
end

-- Get valid end condition types (for configuration builders)
function ConfigValidator.getValidEndConditions()
    return VALID_END_CONDITIONS
end

return ConfigValidator
