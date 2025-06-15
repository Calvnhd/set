-- Logger - Centralized logging system with file output and level filtering
local Logger = {}

-- Log Levels
local LOG_LEVELS = {
    TRACE = 1,
    INFO = 2,
    WARNING = 3,
    ERROR = 4
}

-- String representation of level names for output
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
    bEnabled = true,
    minLevel = LOG_LEVELS.TRACE,
    logFile = "/logs/set.log",
    bWriteToConsole = true,
    maxFileSize = 1024 * 1024,
    bRotateFiles = true
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
    end    bInitialized = true
    Logger.info("LOGGER", "Initialized - %s", config.logFile)
    return true
end

-- Shutdown the logging system
function Logger.shutdown()
    if logFileHandle then
        Logger.info("LOGGER", "Shutting down")
        logFileHandle:close()
        logFileHandle = nil
    end
    bInitialized = false
end

-- Core logging function with level filtering and formatting
local function writeLog(level, originOrMessage, messageOrArg, ...)
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
    
    -- Handle both new and old calling patterns
    local origin = "X"
    local message = originOrMessage
    local args = {...}
    
    -- If there are at least two arguments, the first is origin and the second is message
    if messageOrArg ~= nil then
        origin = originOrMessage
        message = messageOrArg
        -- args stays the same
    end
      -- Format the message with variadic arguments (printf-style)
    local formattedMessage = message
    if #args > 0 then
        local bFormatSuccess, result = pcall(string.format, message, unpack(args))
        if bFormatSuccess then
            formattedMessage = result
        else
            -- Graceful fallback for format errors
            formattedMessage = message .. " [FORMAT ERROR: " .. result .. "]"
        end
    end
    
    -- Build the log line with timestamp, origin, and level
    local logLine = "[" .. os.date("%Y-%m-%d %H:%M:%S") .. "][" .. origin .. "][" .. LEVEL_NAMES[level] .. "] " .. formattedMessage
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
function Logger.trace(originOrMessage, messageOrArg, ...)
    writeLog(LOG_LEVELS.TRACE, originOrMessage, messageOrArg, ...)
end
function Logger.info(originOrMessage, messageOrArg, ...)
    writeLog(LOG_LEVELS.INFO, originOrMessage, messageOrArg, ...)
end
function Logger.warning(originOrMessage, messageOrArg, ...)
    writeLog(LOG_LEVELS.WARNING, originOrMessage, messageOrArg, ...)
end
function Logger.error(originOrMessage, messageOrArg, ...)
    writeLog(LOG_LEVELS.ERROR, originOrMessage, messageOrArg, ...)
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
    local backupName = "logs/set_" .. timestamp .. ".log"

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

return Logger