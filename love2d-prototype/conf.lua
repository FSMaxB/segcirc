-- Segcirc watchface prototype
-- Copyright (C) 2014 Max Bruckner (FSMaxB)

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

function love.conf( t )
	t.version = "0.9.1"                -- The LÖVE version this game was made for (string)

	t.window.title = "pebble watchface"  -- The window title (string)
	t.window.width = 144               -- The window width (number)
	t.window.height = 168              -- The window height (number)
	t.window.borderless = false        -- Remove all border visuals from the window (boolean)
	t.window.resizable = false          -- Let the window be user-resizable (boolean)

	t.modules.audio = false            -- Enable the audio module (boolean)
	t.modules.event = true             -- Enable the event module (boolean)
	t.modules.graphics = true          -- Enable the graphics module (boolean)
	t.modules.image = true             -- Enable the image module (boolean)
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
