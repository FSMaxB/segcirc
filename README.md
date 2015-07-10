Segcirc watchface
=================

![screenshot of segcirc](https://github.com/FSMaxB/segcirc/blob/master/screenshot.png "screenshot of segcirc")

This is a watchface for the pebble smartwatch inspired by the studioclock watchface.

The Watchface is located in the `segcirc` subdirectory. To compile and install it you need the Pebble SDK,
follow the instructions by pebble.

The subdirectory `love2d-prototype` contains a prototype written in Lua with the LÖVE (Love 2D) game framework. To run it you need the LÖVE gameframework ( http://love2d.org ), then run it with `love main.lua`.

Date and weekday are in german notation.

Known Bugs
----------
* The numbers 3 and 7 aren't displayed properly in the date. They're missing a vertical line of pixels. I haven't been able to fix this problem, it is probably related with the font I use, which I made myself due to the lack of free alternatives ( https://github.com/FSMaxB/FourteenSegments ).

License
-------
This software is licensed under the GPL version 3 or any later version.

The FourteenSegments font is licensed under the SIL Open Font License 1.1.
