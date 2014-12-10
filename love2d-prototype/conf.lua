function love.conf( t )
	t.version = "0.9.1"                -- The LÖVE version this game was made for (string)

	t.window.title = "pebble watchface"  -- The window title (string)
	t.window.width = 144               -- The window width (number)
	t.window.height = 160              -- The window height (number)
	t.window.borderless = false        -- Remove all border visuals from the window (boolean)
	t.window.resizable = false          -- Let the window be user-resizable (boolean)

	t.modules.audio = false            -- Enable the audio module (boolean)
	t.modules.event = true             -- Enable the event module (boolean)
	t.modules.graphics = true          -- Enable the graphics module (boolean)
	t.modules.image = false             -- Enable the image module (boolean)
	t.modules.joystick = false         -- Enable the joystick module (boolean)
	t.modules.keyboard = true          -- Enable the keyboard module (boolean)
	t.modules.math = true              -- Enable the math module (boolean)
	t.modules.mouse = false             -- Enable the mouse module (boolean)
	t.modules.physics = false          -- Enable the physics module (boolean)
	t.modules.sound = false            -- Enable the sound module (boolean)
	t.modules.system = false            -- Enable the system module (boolean)
	t.modules.timer = true             -- Enable the timer module (boolean)
	t.modules.window = true            -- Enable the window module (boolean)
	t.modules.thread = false           -- Enable the thread module (boolean)
end
