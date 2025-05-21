-- Configuration file for LÖVE
-- https://love2d.org/wiki/Config_Files

function love.conf(t)
    -- Identity
    t.identity = "set_game"            -- The name of the save directory
    t.version = "11.4"                -- The LÖVE version this game was made for
    t.console = false                  -- Attach a console (boolean, Windows only)

    -- Window settings
    t.window.title = "Set Game"        -- The window title
    t.window.icon = nil                -- Filepath to the window icon
    t.window.width = 800               -- Window width
    t.window.height = 600              -- Window height
    t.window.borderless = false        -- Remove all border visuals (boolean)
    t.window.resizable = false         -- Let the window be user-resizable (boolean)
    t.window.minwidth = 800            -- Minimum window width if resizable
    t.window.minheight = 600           -- Minimum window height if resizable
    t.window.fullscreen = false        -- Enable fullscreen (boolean)
    t.window.fullscreentype = "desktop" -- Choose between "desktop" and "exclusive" fullscreen modes
    t.window.vsync = 1                 -- Vertical sync mode (number)
    t.window.msaa = 0                  -- The number of samples to use with multi-sampled antialiasing
    t.window.depth = nil               -- The number of bits per sample in the depth buffer
    t.window.stencil = nil             -- The number of bits per sample in the stencil buffer
    t.window.display = 1               -- Index of the monitor to show the window in (number)
    t.window.highdpi = false           -- Enable high-dpi mode for the window on a Retina display (boolean)
    
    -- Modules settings
    t.modules.audio = true             -- Enable the audio module (boolean)
    t.modules.data = true              -- Enable the data module (boolean)
    t.modules.event = true             -- Enable the event module (boolean)
    t.modules.font = true              -- Enable the font module (boolean)
    t.modules.graphics = true          -- Enable the graphics module (boolean)
    t.modules.image = true             -- Enable the image module (boolean)
    t.modules.joystick = false         -- Enable the joystick module (boolean)
    t.modules.keyboard = true          -- Enable the keyboard module (boolean)
    t.modules.math = true              -- Enable the math module (boolean)
    t.modules.mouse = true             -- Enable the mouse module (boolean)
    t.modules.physics = false          -- Enable the physics module (boolean)
    t.modules.sound = true             -- Enable the sound module (boolean)
    t.modules.system = true            -- Enable the system module (boolean)
    t.modules.thread = false           -- Enable the thread module (boolean)
    t.modules.timer = true             -- Enable the timer module (boolean)
    t.modules.touch = false            -- Enable the touch module (boolean)
    t.modules.video = false            -- Enable the video module (boolean)
    t.modules.window = true            -- Enable the window module (boolean)
end
