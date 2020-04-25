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

### Waypoint set
\waypoint set can be initiated by following parties:
* Yourself on any channel
* Anyone on party channel (configures everyone)
* Anybody on whisper (affects only the recipient)
* Any NPCs using Inky

## How the script works

This script monitors player's movement in the game to get the bearings. It monitors key input to identify irregular movements such as side strafing. Using current and target coordinates, and UI bearing, it shows in which direction the destination is located relative to the current UI rotations.
