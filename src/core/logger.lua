-- Logger - Centralized logging system with file output and level filtering
local Logger = {}

-- Log levels (higher numbers = more severe)
local LOG_LEVELS = {
    TRACE = 1,
    INFO = 2,
    WARNING = 3,
    ERROR = 4
}

-- Log level names for output
local LEVEL_NAMES = {
    [LOG_LEVELS.TRACE] = "TRACE",
    [LOG_LEVELS.INFO] = "INFO",
    [LOG_LEVELS.WARNING] = "WARNING",
    [LOG_LEVELS.ERROR] = "ERROR"
}

-- Logger configuration
-- Note that the only directory that love.filesystem will write to is %APPDATA%/LOVE/  
-- see https://love2d.org/wiki/love.filesystem
local config = {
    bEnabled = true, -- Global logging enable/disable
    minLevel = LOG_LEVELS.TRACE, -- Minimum level to log
    logFile = "/logs/set.log", -- Log file path
    bWriteToConsole = true, -- Also output to console
    bIncludeTimestamp = true, -- Include timestamps
    bIncludeLevel = true, -- Include log level in output
    maxFileSize = 1024 * 1024, -- 1MB max file size
    bRotateFiles = true -- Enable log rotation
}

-- Internal state 
local logFileHandle = nil
local bInitialized = false

-- Initialize the logging system
function Logger.initialize()
    if bInitialized then
        return true
    end

    -- Create logs directory if it doesn't exist
    local bDirSuccess = love.filesystem.createDirectory("logs")
    print()
    if not bDirSuccess then
        print("[LOGGER] Warning: Could not create logs directory")
    end

    -- Try to open log file for writing
    logFileHandle = love.filesystem.newFile(config.logFile)
    local bOpenSuccess, error = logFileHandle:open("w")

    if not bOpenSuccess then
        print("[LOGGER] Failed to open log file:", error)
        logFileHandle = nil
        -- Continue without file logging - graceful fallback
    end

    bInitialized = true
    Logger.info("Logger initialized - " .. config.logFile)
    return true
end

-- Shutdown the logging system
function Logger.shutdown()
    if logFileHandle then
        Logger.info("Logger shutting down")
        logFileHandle:close()
        logFileHandle = nil
    end
    bInitialized = false
end

-- Core logging function with level filtering and formatting
local function writeLog(level, message, ...)
    -- Early return for performance when logging is disabled
    if not config.bEnabled then
        return
    end

    -- Level-based filtering before message formatting
    if level < config.minLevel then
        return
    end

    -- Lazy initialization of file handles
    if not bInitialized then
        Logger.initialize()
    end

    -- Format the message with variadic arguments (printf-style)
    local formattedMessage = message
    if select('#', ...) > 0 then
        local bFormatSuccess, result = pcall(string.format, message, ...)
        if bFormatSuccess then
            formattedMessage = result
        else
            -- Graceful fallback for format errors
            formattedMessage = message .. " [FORMAT ERROR: " .. result .. "]"
        end
    end

    -- Build the log line with timestamp and level
    local logLine = ""

    if config.bIncludeTimestamp then
        logLine = logLine .. "[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] "
    end

    if config.bIncludeLevel then
        logLine = logLine .. "[" .. LEVEL_NAMES[level] .. "] "
    end

    logLine = logLine .. formattedMessage

    -- Dual output capability - console
    if config.bWriteToConsole then
        print(logLine)
    end

    -- Dual output capability - file
    if logFileHandle then
        -- Log rotation when files exceed size limits
        if config.bRotateFiles then
            local fileSize = logFileHandle:getSize()
            if fileSize and fileSize > config.maxFileSize then
                Logger._rotateLogFile()
            end
        end

        local bWriteSuccess = logFileHandle:write(logLine .. "\n")
        if bWriteSuccess then
            logFileHandle:flush() -- Ensure immediate write
        end
    end
end

-- Public API functions
function Logger.trace(message, ...)
    writeLog(LOG_LEVELS.TRACE, message, ...)
end

function Logger.info(message, ...)
    writeLog(LOG_LEVELS.INFO, message, ...)
end

function Logger.warning(message, ...)
    writeLog(LOG_LEVELS.WARNING, message, ...)
end

function Logger.error(message, ...)
    writeLog(LOG_LEVELS.ERROR, message, ...)
end

-- Configuration functions
function Logger.setEnabled(bEnabled)
    config.bEnabled = bEnabled
    if bEnabled then
        Logger.info("Logging enabled")
    end
end

function Logger.isEnabled()
    return config.bEnabled
end

function Logger.setMinLevel(level)
    config.minLevel = level
    Logger.info("Minimum log level set to: " .. LEVEL_NAMES[level])
end

function Logger.setLogFile(filename)
    if logFileHandle then
        logFileHandle:close()
    end
    config.logFile = filename
    bInitialized = false
    Logger.initialize()
end

function Logger.setConsoleOutput(bEnabled)
    config.bWriteToConsole = bEnabled
end

function Logger.setIncludeTimestamp(bEnabled)
    config.bIncludeTimestamp = bEnabled
end

function Logger.setIncludeLevel(bEnabled)
    config.bIncludeLevel = bEnabled
end

-- Log file rotation with proper file handle management
function Logger._rotateLogFile()
    if not logFileHandle then
        return
    end

    -- Close current file
    logFileHandle:close()

    -- Create backup filename with timestamp
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local backupName = "logs/game_" .. timestamp .. ".log"

    -- Read current log content and write to backup
    local currentContent = love.filesystem.read(config.logFile)
    if currentContent then
        love.filesystem.write(backupName, currentContent)
    end

    -- Open new log file
    logFileHandle = love.filesystem.newFile(config.logFile)
    local bSuccess = logFileHandle:open("w")
    if not bSuccess then
        logFileHandle = nil
    end
end

-- Get current configuration (for debugging)
function Logger.getConfig()
    return config
end

-- Export log levels for external use
Logger.LEVELS = LOG_LEVELS

return Logger
