--- @meta _
--- An "addon" to the CC Tweaked addon for the Lua Language Server (heh)

--- @alias ccTweaked.directionalSide
--- | " top"
--- | "bottom"
--- | "left"
--- | "right"
--- | "back"
--- | "front"

--- Yes this seems a bit redundant
--- @alias ccTweaked.side string

--- @alias ccTweaked.os_event
--- | "alarm"
--- | "char"
--- | "computer_command"
--- | "disk"
--- | "disk_eject"
--- | "http_check"
--- | "http_failure"
--- | "http_success"
--- | "key"
--- | "key_up"
--- | "modem_message"
--- | "monitor_resize"
--- | "monitor_touch"
--- | "mouse_click"
--- | "mouse_drag"
--- | "mouse_scroll"
--- | "mouse_up"
--- | "paste"
--- | "peripheral"
--- | "peripheral_detach"
--- | "rednet_message"
--- | "redstone"
--- | "speaker_audio_empty"
--- | "task_complete"
--- | "term_resize"
--- | "terminate"
--- | "timer"
--- | "turtle_inventory"
--- | "websocket_closed"
--- | "websocket_failure"
--- | "websocket_message"
--- | "websocket_success"


--- @alias ccTweaked.colours.colour ccTweaked.colors.color
--- @alias ccTweaked.colours.colourSet ccTweaked.colors.colorSet


--- BELOW TAKEN FROM THE CC TWEAKED LUA LANGUAGE SERVER ADDON (Editing to use British English spelling instead)
--- Any licensing and other issues and questions is better found/asked at their gitlab: https://gitlab.com/carsakiller/cc-tweaked-documentation
--[[
    MIT License
    Copyright (c) 2024 carsakiller
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
--]]

--- Contains constants and functions for colour values. Useful in conjunction
--- with Bundled Cables from mods like [Project
--- Red](https://projectredwiki.com/wiki/Main_Page), and colors on Advanced
--- Computers and Advanced Monitors.
---
--- For a British English version, replace colors with colours. This alternative
--- API is exactly the same except the colours use British English (e.g.
--- colors.gray is spelt colours.grey).
---
--- On basic non-color terminals, all the colors are converted to grayscale. This
--- means you can still use all 16 colors on the screen, but they will appear as
--- the nearest tint of gray. You can check if a terminal supports color by using
--- the function `term.isColor`. Grayscale colors are calculated by taking the
--- average of the three components, i.e. `(red + green + blue) / 3`.
------
--- [Official Documentation](https://tweaked.cc/module/colors.html)
colours = {}

--- **Hex**: `#F0F0F0`\
--- **RGB**: `240, 240, 240`
--- @type ccTweaked.colours.colour
colours.white = 1

--- **Hex**: `#F2B233`\
--- **RGB**: `242, 178, 51`
--- @type ccTweaked.colours.colour
colours.orange = 2

--- **Hex**: `#E57FD8`\
--- **RGB**: `229, 127, 216`
--- @type ccTweaked.colours.colour
colours.magenta = 4

--- **Hex**: `#99B2F2`\
--- **RGB**: `153, 178, 242`
--- @type ccTweaked.colours.colour
colours.lightBlue = 8

--- **Hex**: `#DEDE6C`\
--- **RGB**: `222, 222, 108`
--- @type ccTweaked.colours.colour
colours.yellow = 16

--- **Hex**: `#7FCC19`\
--- **RGB**: `127, 204, 25`
--- @type ccTweaked.colours.colour
colours.lime = 32

--- **Hex**: `#F2B2CC`\
--- **RGB**: `242, 178, 204`
--- @type ccTweaked.colours.colour
colours.pink = 64

--- **Hex**: `#4C4C4C`\
--- **RGB**: `76, 76, 76`
--- @type ccTweaked.colours.colour
colours.gray = 128

--- **Hex**: `#999999`\
--- **RGB**: `153, 153, 153`
--- @type ccTweaked.colours.colour
colours.lightGray = 256

--- **Hex**: `#4C99B2`\
--- **RGB**: `76, 153, 178`
--- @type ccTweaked.colours.colour
colours.cyan = 512

--- **Hex**: `#B266E5`\
--- **RGB**: `178, 102, 229`
--- @type ccTweaked.colours.colour
colours.purple = 1024

--- **Hex**: `#3366CC`\
--- **RGB**: `51, 102, 204`
--- @type ccTweaked.colours.colour
colours.blue = 2048

--- **Hex**: `#7F664C`\
--- **RGB**: `127, 102, 76`
--- @type ccTweaked.colours.colour
colours.brown = 4096

--- **Hex**: `#57A64E`\
--- **RGB**: `87, 166, 78`
--- @type ccTweaked.colours.colour
colours.green = 8192

--- **Hex**: `#CC4C4C`\
--- **RGB**: `204, 76, 76`
--- @type ccTweaked.colours.colour
colours.red = 16384

--- **Hex**: `#111111`\
--- **RGB**: `17, 17, 17`
--- @type ccTweaked.colours.colour
colours.black = 32768

--- Combines colors into a set. Useful for Bundled Cables
--- @vararg ccTweaked.colours.colour
--- @return ccTweaked.colours.colourSet set The result of combining the provided colors
--- ## Example
--- ```
--- colors.combine(colors.white, colors.magenta, colours.lightBlue)
----- > 13
--- ```
------
--- [Official Documentation](https://tweaked.cc/module/colors.html#v:combine)
function colours.combine(...) end

--- Removes one or more colors from a set. Useful for Bundled Cables.
--- @param colour ccTweaked.colours.colour The color to subtract from
--- @vararg ccTweaked.colours.colour
--- @return ccTweaked.colours.colourSet set The result of subtracting the provided colors
--- ## Example
--- ```
--- colors.subtract(colours.lime, colours.orange, colours.white)
----- > 32
--- ```
------
--- [Official Documentation](https://tweaked.cc/module/colors.html#v:subtract)
function colours.subtract(colour, ...) end

--- Test whether a color is contained within a color set
--- @param set ccTweaked.colours.colourSet
--- @param colour ccTweaked.colours.colour
--- ## Example
--- ```
--- colors.test(colors.combine(colors.white, colors.magenta, colours.lightBlue), colors.lightBlue)
----- > true
--- ```
------
--- [Official Documentation](https://tweaked.cc/module/colors.html#v:test)
function colours.test(set, colour) end

--- Combine an RGB value into one hexadecimal representation
--- @param r number The red channel (0 - 1)
--- @param g number The green channel (0 - 1)
--- @param b number The blue channel (0 - 1)
--- @return number hex The hexadecimal representation of the RGB value
--- ## Example
--- ```
--- colors.packRGB(0.7, 0.2, 0.6)
----- > 0xb23399
--- ```
------
--- [Official Documentation](https://tweaked.cc/module/colors.html#v:packRGB)
function colours.packRGB(r, g, b) end

--- Convert a hex value into separate r, g, b, values
--- @param hex number
--- @return number r Red component (0 - 1)
--- @return number g Green component (0 - 1)
--- @return number b Blue component (0 - 1)
--- ## Example
--- ```
--- colors.unpackRGB(0xb23399)
----- > 0.7, 0.2, 0.6
--- ```
function colours.unpackRGB(hex) end

--- Calls either `colors.packRGB` or `colors.unpackRGB` depending on how many
--- arguments it receives.
--- @deprecated
--- @param r number The red channel (0 - 1)
--- @param g number The green channel (0 - 1)
--- @param b number The blue channel (0 - 1)
--- @return number hex The hexadecimal representation of the RGB value
--- 🚮 **Deprecated in `v1.81.0`**, use `colors.packRGB()`
--- ## Example
--- ```
--- colors.rgb8(0.7, 0.2, 0.6)
----- > 0xb23399
--- ```
------
--- [Official Documentation](https://tweaked.cc/module/colors.html#v:rgb8)
function colours.rgb8(r, g, b) end

--- Calls either `colors.packRGB` or `colors.unpackRGB` depending on how many
--- arguments it receives.
--- @deprecated
--- @param hex number
--- @return number r Red component (0 - 1)
--- @return number g Green component (0 - 1)
--- @return number b Blue component (0 - 1)
--- 🚮 **Deprecated in `v1.81.0`**, use `colors.unpackRGB()`
--- ## Example
--- ```
--- colors.rgb8(0xb23399)
----- > 0.7, 0.2, 0.6
--- ```
------
--- [Official Documentation](https://tweaked.cc/module/colors.html#v:rgb8)
function colours.rgb8(hex) end

--- Converts a color into a blit hex character for use with `term.blit()`
--- @param colour ccTweaked.colours.colour The color to convert
--- @return string blit The blit hex character that represents the given color
--- ## Example
--- ```
--- colors.toBlit(colors.magenta)
----- > "2"
--- ```
------
--- [Official Documentation](https://tweaked.cc/module/colors.html#v:toBlit)
function colours.toBlit(colour) end

--- END OF TAKEN FROM ADDON

--- TOOD: Add certain modules that are defined in ccTweaked addon but not as classes or global variables and therefore...just don't work (like io)
