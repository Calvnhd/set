# Lua Guide for C++ Developers

This guide explains Lua-specific patterns and conventions found in the codebase, particularly for developers coming from a C++ background.

## 1. Tables as Objects, Arrays, and Maps

### Lua Pattern
```lua
local obj = {}
obj.key = value
obj[1] = value
```

### C++ Equivalent
```cpp
class MyClass { ... };
std::map<std::string, Value> obj;
std::vector<Value> arr;
```

**Key Differences:**
- Lua tables are used for objects, arrays, and maps; there is no distinction.
- Members/fields can be added or removed at runtime.
- No compile-time structure or type checking.
- Tables can be used as both arrays and maps simultaneously.

## 2. Module Pattern and Singleton Modules

### Lua Pattern
```lua
-- At top of file
local CardModel = {}

-- Define module contents
-- ...

-- At end of file
return CardModel
```

### C++ Equivalent
```cpp
// In header file (.h)
class CardModel { ... };

// In implementation file (.cpp)
#include "CardModel.h"
```

**Key Differences:**
- The returned table becomes the module's public API
- Loaded via `require('modulename')`
- No header files or linking
- Everything not returned is private to the module

## 3. No Type Declarations or Access Control

### Lua Pattern
```lua
function CardModel.create(color, shape, number, fill)
    -- No type information
end
```

### C++ Equivalent
```cpp
Card* CardModel::create(Color color, Shape shape, int number, Fill fill) {
    // Type-safe implementation
}
```

**Key Differences:**
- No compile-time type checking
- Any value can be passed as any parameter
- Runtime errors occur if wrong types are used
- Duck typing - if it has the right methods/properties, it works

**Additional Notes:**
- There is no `private`, `protected`, or `public` in Lua. All fields and functions are accessible unless hidden by local scope.
- Use `local` to restrict scope to a file or function.

## 4. Dot vs Colon Syntax

### Lua Pattern
```lua
CardModel.create(...)     -- Dot syntax: no implicit self
cardRef:someMethod()      -- Colon syntax: passes self as first arg
```

### C++ Equivalent
```cpp
CardModel::create(...)    // Static method
cardRef->someMethod()     // Instance method
```

**Key Differences:**
- `.` doesn't pass `self`, like C++ static methods
- `:` automatically passes the table as first parameter (like `this`)
- Easy to accidentally use wrong syntax

## 5. Global by Default and Defensive Programming

### Lua Pattern
```lua
local CardModel = {}      -- Must explicitly use 'local'
someVariable = 42         -- GLOBAL! (no 'local')
```

### C++ Equivalent
```cpp
// C++ variables are local by default
int someVariable = 42;    // Local to scope
```

**Key Differences:**
- Lua variables are global unless declared `local`
- Forgetting `local` creates accidental globals
- Can pollute global namespace easily
- Always use `local` unless you need a global

**Additional Notes:**
- Always use `local` for variables and functions unless you intend to make them global.
- Defensive programming is essential: check for `nil` and validate types at runtime.

## 6. Metatables and Metamethods

### Common Metamethods
```lua
__index     -- Lookup for missing keys (inheritance)
__newindex  -- Assignment to new keys
__call      -- Make table callable like function
__tostring  -- Custom string representation
__add       -- Operator overloading (+)
__eq        -- Equality comparison
```

### C++ Equivalent
```cpp
// Operator overloading
bool operator==(const Card& other);
Card operator+(const Card& other);
```

**Key Differences:**
- Metamethods provide operator overloading
- More flexible than C++ (can change at runtime)
- Double underscore prefix is Lua convention
- Only specific names are recognized

## 7. Variadic Functions, Multiple Returns, and ...

### Lua Pattern
```lua
function someFunc(a, ...)
    print(a, ...)
end

function SceneManager.changeScene(sceneName, ...)
    -- ...
    if currentScene.enter then
        currentScene.enter(...)
    end
end

function getPosition()
    return x, y, width, height
end
local x, y, w, h = getPosition()
```

### C++ Equivalent
```cpp
// Variadic templates (C++11)
template<typename... Args>
void changeScene(string sceneName, Args... args);

// Multiple returns via struct or tuple
struct Position { int x, y, width, height; };
Position getPosition();
// or
std::tuple<int, int, int, int> getPosition();
```

**Key Differences:**
- `...` captures any number of arguments
- Can return multiple values without containers
- No type safety for variadic arguments
- Arguments can be forwarded easily

## 8. First-Class and Anonymous Functions, Closures

### Lua Pattern
```lua
EventManager.subscribe('event', function(data)
    print(data)
end)

local callback = GameController.handleKeypress

-- Functions as table values
local state = {
    enter = function() ... end,
    exit = function() ... end
}
```

### C++ Equivalent
```cpp
// Lambda functions and std::function
std::function<void(DataType)> callback = [](DataType data) { std::cout << data; };

// Function pointers
void (*callback)(string) = &GameController::handleKeypress;
```

**Key Differences:**
- Functions are values like any other
- No special syntax for function pointers
- Closures capture variables automatically
- Can modify function behavior at runtime

## 9. Event-Driven Patterns and Publisher-Subscriber

### Lua Pattern
```lua
-- EventManager pattern
EventManager.subscribe(Events.INPUT.KEY_PRESSED, GameController.handleKeypress)
EventManager.emit(Events.INPUT.KEY_PRESSED, key)

-- Anonymous functions as event handlers
EventManager.subscribe(Events.SCENE.CHANGE_TO_GAME, function(gameMode)
    SceneManager.changeScene(Events.SCENE.CHANGE_TO_GAME, gameMode)
end)
```

### C++ Equivalent
```cpp
// Observer pattern with function pointers or std::function
class EventManager {
    void subscribe(const std::string& event, std::function<void()> callback);
    void emit(const std::string& event);
};
```

**Key Differences:**
- Events are identified by strings, not enums or types
- Any function (including anonymous) can be a handler
- No compile-time checking of event names or signatures
- Flexible but error-prone (typos, wrong signatures)

## 10. Table-Based Configuration, Enums, and State

### Lua Pattern
```lua
local config = {
    boardSize = {columns = 4, rows = 3},
    scoring = {validSet = 2, invalidSet = -1}
}

RoundDefinitions.tutorial = {
    { id = "tutorial_1", ... },
    { id = "tutorial_2", ... }
}
```

### C++ Equivalent
```cpp
struct Config {
    struct BoardSize { int columns, rows; };
    BoardSize boardSize;
    struct Scoring { int validSet, invalidSet; };
    Scoring scoring;
};
std::vector<Config> tutorialRounds;
```

**Key Differences:**
- No compile-time structure validation
- Can mix types freely in tables
- Easy to make typos in keys
- Very flexible but error-prone

**Additional Notes:**
- Enums are simulated with tables of strings; typos are not caught at compile time.
- State machines and UI layouts are often just tables with dynamic keys.

## 11. Dynamic Dispatch and String-Based Method Calls

### Lua Pattern
```lua
function StateMachine:handleEvent(eventName, ...)
    local stateObj = self.states[self.currentState]
    if stateObj and stateObj[eventName] then
        stateObj[eventName](...)
    end
end
```

### C++ Equivalent
```cpp
// Would require std::map or reflection
std::map<std::string, std::function<void()>> methods;
if (methods.find(eventName) != methods.end()) {
    methods[eventName]();
}
```

**Key Differences:**
- Any string can be used as a table key
- Runtime method resolution
- No compile-time checking of method names
- Very flexible but can hide errors

## 12. Implicit Returns, nil, and Optional Values

### Lua Pattern
```lua
function getValue()
    if condition then
        return value
    end
    -- Implicit return nil
end

function doSomething()
    print("done")
    -- Returns nil
end
```

### C++ Equivalent
```cpp
// Must specify return type
Value* getValue() {
    if (condition) {
        return value;
    }
    return nullptr;  // Must be explicit
}

// Void functions
void doSomething() {
    cout << "done";
    // No return needed
}
```

**Key Differences:**
- All functions return at least `nil`
- Missing return statements return `nil`
- Can lead to unexpected nil values
- No compile-time warnings for missing returns

**Additional Notes:**
- Functions return `nil` by default if no value is returned.
- Setting a table entry to `nil` deletes it.
- There is no `std::optional`; use `nil` for missing/optional values.

## 13. Table Mutation, Reference Semantics, and Copying

### Lua Pattern
```lua
local a = {1,2,3}
local b = a  -- b is a reference to a, not a copy
a[1] = 99
print(b[1])  -- prints 99
```

### C++ Equivalent
```cpp
std::vector<int> a = {1,2,3};
std::vector<int> b = a; // b is a copy
a[0] = 99;
std::cout << b[0]; // prints 1
```

**Key Differences:**
- Assigning a table copies the reference, not the contents
- Mutations affect all references to the same table
- Use explicit copy functions for deep/shallow copies

## 14. Idiomatic Iteration and Table Traversal

### Lua Pattern
```lua
for i, v in ipairs(list) do ... end
for k, v in pairs(map) do ... end
```

### C++ Equivalent
```cpp
for (size_t i = 0; i < list.size(); ++i) { ... }
for (const auto& [k, v] : map) { ... }
```

**Key Differences:**
- `ipairs` for array-like tables (integer keys)
- `pairs` for all key-value pairs (including non-integer keys)
- No distinction between array and map at the type level

## 15. Error Handling with pcall

### Lua Pattern
```lua
local success, result = pcall(function() ... end)
if not success then print("Error:", result) end
```

### C++ Equivalent
```cpp
try {
    // ...
} catch (const std::exception& e) {
    std::cout << "Error: " << e.what();
}
```

**Key Differences:**
- `pcall` (protected call) catches errors and prevents crashes
- Returns status and error message
- No try/catch syntax; error handling is explicit

## 16. Love2D Engine Conventions and Global State

### Lua Pattern
```lua
function love.load() ... end
function love.update(dt) ... end
function love.draw() ... end
```

**Key Differences:**
- Love2D expects global functions with specific names; these are called by the engine.
- There is no explicit main loop; Love2D manages the game loop and state.
- All game state must be managed by the developer, often using module singletons or global tables.
- Love2D's global state (e.g., `love.graphics`, `love.window`) is always available and mutable.

## 17. Table Unpacking and Dynamic Arguments

### Lua Pattern
```lua
love.graphics.setColor(unpack(COLORS.ui.selected))
local r, g, b, a = getPaleComplementaryColor(cardData.color)
```

### C++ Equivalent
```cpp
// No direct equivalent; would use arrays or structs
Color c = getColor();
setColor(c.r, c.g, c.b, c.a);
```

**Key Differences:**
- `unpack(table)` expands a table into multiple return values
- Used for passing dynamic argument lists to functions
- No type or length checking; errors if table is missing values

## 18. Table-Based UI State, Layout, and Resource Management

### Lua Pattern
```lua
local classicButton = { x = 0, y = 0, width = 200, height = 60, text = "Classic Mode" }
classicButton.x = windowWidth / 2 - classicButton.width / 2
```

### C++ Equivalent
```cpp
struct Button { int x, y, width, height; std::string text; };
Button classicButton;
classicButton.x = ...;
```

**Key Differences:**
- UI elements are described as tables, not structs/classes
- Fields can be added/removed at runtime
- No compile-time layout or type checking

## 19. Best Practices for C++ Developers

1. **Always use `local`** - Avoid accidental globals.
2. **Check for nil** - Defensive programming for dynamic types.
3. **Use underscore prefix** - For pseudo-private fields.
4. **Document types** - Use comments to indicate expected types.
5. **Validate inputs** - Add runtime type checking where critical.
6. **Use consistent patterns** - Stick to either OOP or functional style.
7. **Avoid deep nesting** - Tables can get complex quickly.
8. **Test edge cases** - Dynamic typing hides many errors.
9. **Be explicit with returns** - Don't rely on implicit nil.
10. **Name your anonymous functions** - For better stack traces.
11. **Validate table structures** - Add checks for required fields.
12. **Use descriptive event names** - String-based dispatch can be confusing.

## 20. Common Pitfalls

1. **Forgetting `local`** - Creates global variables.
2. **Wrong self syntax** - Using `.` instead of `:`.
3. **Nil index errors** - Accessing `nil.field`.
4. **Type mismatches** - Passing wrong types to functions.
5. **Table mutation** - Accidentally modifying shared tables.
6. **Missing returns** - Functions return `nil` by default.
7. **Closure variable capture** - Capturing more than intended.
8. **String typos in keys** - No compile-time checking.
9. **Assuming order in tables** - `pairs()` doesn't guarantee order.
10. **Boolean confusion** - Empty tables are truthy.

## 21. Debugging Tips

1. Use `print()` liberally - No debugger needed.
2. Check types with `type(variable)`.
3. Use `assert()` for preconditions.
4. Pretty-print tables with custom functions.
5. Watch for silent `nil` returns.
6. Use strict mode to catch undefined globals.
7. Add type checking functions for critical paths.
8. Log event names and parameters.
9. Validate table structures early.
10. Use meaningful error messages with context.