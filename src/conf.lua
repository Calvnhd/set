-- Love2D configuration

function love.conf(t)
    t.identity = "set-game"           -- Save directory name
    t.version = "11.4"                -- LÖVE version
    t.console = false                 -- Attach a console (Windows only)
    t.accelerometerjoystick = true    -- Enable accelerometer on mobile
    t.externalstorage = false         -- Enable external storage (Android only)
    t.gammacorrect = false            -- Enable gamma-correct rendering
    
    t.audio.mic = false               -- Request microphone permission (mobile)
    t.audio.mixwithsystem = true      -- Keep background music playing
    
    t.window.title = "Set Card Game"  -- Window title
    t.window.icon = nil               -- Filepath to icon (string)
    t.window.width = 1024             -- Window width
    t.window.height = 768             -- Window height
    t.window.borderless = false       -- Remove window border
    t.window.resizable = true         -- Let the window be resizable
    t.window.minwidth = 800           -- Minimum window width
    t.window.minheight = 600          -- Minimum window height
    t.window.fullscreen = false       -- Enable fullscreen
    t.window.fullscreentype = "desktop" -- Standard fullscreen or desktop fullscreen
    t.window.vsync = 1               -- Vertical sync mode
    t.window.msaa = 0                -- Number of MSAA samples
    t.window.depth = nil             -- Number of bits per sample in depth buffer
    t.window.stencil = nil           -- Number of bits per sample in stencil buffer
    t.window.display = 1             -- Monitor to show window on
    t.window.highdpi = false         -- Enable high-dpi mode (Apple Retina displays)
    t.window.usedpiscale = true      -- Enable automatic DPI scaling
    t.window.x = nil                 -- Window x coordinate
    t.window.y = nil                 -- Window y coordinate
    
    t.modules.audio = true           -- Enable the audio module
    t.modules.data = true            -- Enable the data module
    t.modules.event = true           -- Enable the event module
    t.modules.font = true            -- Enable the font module
    t.modules.graphics = true        -- Enable the graphics module
    t.modules.image = true           -- Enable the image module
    t.modules.joystick = true        -- Enable the joystick module
    t.modules.keyboard = true        -- Enable the keyboard module
    t.modules.math = true            -- Enable the math module
    t.modules.mouse = true           -- Enable the mouse module
    t.modules.physics = false        -- Enable the physics module (not needed for this game)
    t.modules.sound = true           -- Enable the sound module
    t.modules.system = true          -- Enable the system module
    t.modules.thread = true          -- Enable the thread module
    t.modules.timer = true           -- Enable the timer module
    t.modules.touch = true           -- Enable the touch module
    t.modules.video = false          -- Enable the video module (not needed)
    t.modules.window = true          -- Enable the window module
end
