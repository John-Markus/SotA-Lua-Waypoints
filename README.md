# SotA-Lua-Waypoints

This script adds waypoint navigation to the Shroud of the Avatar game client.

## How to use

New waypoints can be configured by typing following in the Chatbox
    
    \waypoints set [route parameters]

Route parameters is a JSON array *WITHOUT* the outermost []s
(Moonsharp JSON parser does not allow nested array as first element)

Following additional commands are available

    \waypoints get [comment]        - Mark current location
    \waypoints save                 - Save optimized listing of all marked locations
    \waypoints next                 - Choose next waypoint
    \waypoints stop                 - Stop navigating
    \waypoints restart              - Restart navigation from beginning
    \waypoints revert               - Restart from previous route (undo overwrites by others)
    \waypoints load [path]          - Load navigation file from disk (adds .txt automatically)

### Waypoint set
\waypoint set can be initiated by following parties:
* Yourself on any channel
* Anyone on party channel (configures everyone)
* Anybody on whisper (affects only the recipient)
* Any NPCs using Inky

## How the script works

This script monitors player's movement in the game to get the bearings. It monitors key input to identify irregular movements such as side strafing. Using current and target coordinates, and UI bearing, it shows in which direction the destination is located relative to the current UI rotations.

### Waypoint JSON syntaxes
The Moonsharp JSON parser on Shroud of the Avatar game client has following issues:
- Since Lua has only integer variables, floating point values and negative values must be represented as strings
- No nested tables allowed as first element

For this reason, the script encapsulates the input using "\[1," and "\]" before parsing, and removes the first item.

- You may also replace "\],\[" with "|" to save length.
- Parameter are ordered as following
    - X Y Z coordinates (floating point allowed)
    - Name of map (leave blank to make it same as previous map)
    - Comment
- If there are no values, items on the back may be left out.
- Use `["!<path>"]` to link to another navigation file (no relative paths)

Example route:

- Soltown to Ardoris Lighthouse bathtub

    \waypoints set ["60,31,193","Soltown"|"438,13,-311","Novia"|"399,11,-358"|"348,13,-398"|"154,56,194","Ardoris"|"143,56,137"|"93,56,-26"|"116,56,-35"|"102,53,-271"|"232,57,-263"|"238,46,-316"|"246,48,-316"|"257,65,-312"|"256,70,-321"|"258,76,-312"|"256,89,-322"]
