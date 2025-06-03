# Logging System Specification

A comprehensive logging system for the Set card game that provides structured, configurable logging capabilities with multiple severity levels and file output. The system will enable developers to trace execution flow, debug issues, and monitor application behavior. This is a moderate-impact addition that introduces a new core module without modifying existing game logic, making it a safe enhancement to the codebase.

## Overall design

The logging system follows the **Singleton pattern** to ensure consistent logging behavior across the entire application. It implements a **Strategy pattern** for output destinations (file vs console) and uses **Command pattern** principles for log message formatting and processing.

Key design principles:
- **Centralized logging**: Single entry point for all log messages
- **Configurable severity levels**: TRACE, DETAILED, WARNING, ERROR with filtering capabilities
- **File-based persistence**: Logs written to `/logs/` directory structure
- **Performance-conscious**: Minimal overhead when logging is disabled
- **Lua-idiomatic**: Uses tables for configuration and Lua's string formatting capabilities

The system integrates with the existing EventManager pattern and follows the project's boolean naming conventions (`bEnabled`, `bInitialized`, etc.).

## Change list

### Core Module: logger.lua
- **Changes**: Create new logging module in `src/core/logger.lua`
- **Outcome**: Centralized logging functionality with file output and level filtering
- **Reason and importance**: Provides essential debugging and monitoring capabilities without disrupting existing code

### Main Application: main.lua
- **Changes**: Initialize logger in `love.load()` and shutdown in `love.quit()`
- **Outcome**: Logger lifecycle managed by main application loop
- **Reason and importance**: Ensures logging is available throughout application lifetime

### Directory Structure: /logs/
- **Changes**: Create logs directory and add to .gitignore
- **Outcome**: Log files stored locally but excluded from version control
- **Reason and importance**: Prevents log file pollution in repository while maintaining local debugging capability

### Configuration: .gitignore
- **Changes**: Add `/logs/` entry to prevent log file commits
- **Outcome**: Log files remain local to development environment
- **Reason and importance**: Avoids cluttering repository with developer-specific log files

## Design plan

### Stage 1: Core Logger Implementation
1. Create `src/core/logger.lua` with the following components:
   - Log level constants (TRACE=1, DETAILED=2, WARNING=3, ERROR=4)
   - Configuration table with boolean flags following naming conventions
   - Core logging function with level filtering and formatting
   - Public API functions: `trace()`, `detailed()`, `warning()`, `error()`
   - Configuration functions: `setEnabled()`, `setMinLevel()`, `setLogFile()`

2. Implement file handling using Love2D's filesystem API:
   - File creation and writing to `/logs/` directory
   - Automatic directory creation if not exists
   - Log rotation when files exceed size limits
   - Proper file handle management and cleanup

### Stage 2: Integration and Configuration
1. Update `main.lua` to initialize logging system:
   - Call `Logger.initialize()` in `love.load()`
   - Call `Logger.shutdown()` in `love.quit()`
   - Add initial startup logging messages

2. Create `/logs/` directory structure:
   - Ensure directory exists for log file output
   - Add appropriate .gitignore entries

### Stage 3: Message Formatting and Output
1. Implement timestamp formatting using `os.date()`
2. Add log level prefixes to messages
3. Support printf-style string formatting with variadic arguments
4. Dual output capability (console + file) with individual enable/disable

### Stage 4: Performance Optimization
1. Implement early return when logging is globally disabled
2. Add level-based filtering before message formatting
3. Lazy initialization of file handles
4. Minimal memory allocation for disabled log calls

### Stage 5: Testing and Validation
1. Test all log levels with various message formats
2. Verify file creation and writing in `/logs/` directory
3. Test configuration changes (enable/disable, level filtering)
4. Validate log rotation functionality
5. Confirm .gitignore correctly excludes log files

## Other Considerations

**Performance Impact**: The logging system is designed with minimal performance overhead. When globally disabled, log calls return immediately without string formatting or file I/O operations.

**Thread Safety**: Love2D is single-threaded, so no concurrency concerns exist for this implementation.

**Error Handling**: The logger includes graceful fallbacks when file operations fail, ensuring the game continues running even if logging fails.

**Extensibility**: The modular design allows for future enhancements such as:
- Network logging for remote debugging
- Log compression for long-running sessions
- Custom formatting templates
- Integration with external debugging tools

**Development Workflow**: Developers can easily add logging to existing functions without modifying core game logic, following the pattern:
```lua
local Logger = require('core.Logger ')
Logger.info("Function called with parameters: %s, %s", param1, param2)
```

**Memory Management**: Log file handles are properly managed through Love2D's file system API, with automatic cleanup on application shutdown.

**Configuration Persistence**: While the current design uses runtime configuration, future versions could persist logging preferences to a configuration file for consistency across game sessions.
