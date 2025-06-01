-- Configuration Validator Service - Validate round configurations and game settings
local ConfigValidator = {}



-- Get valid attribute options (for configuration builders)
function ConfigValidator.getValidAttributes()
    return VALID_ATTRIBUTES
end

-- Get valid end condition types (for configuration builders)
function ConfigValidator.getValidEndConditions()
    return VALID_END_CONDITIONS
end

return ConfigValidator
