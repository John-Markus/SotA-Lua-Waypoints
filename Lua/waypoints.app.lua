-- waypoints.app by John Markus
-- uses screen bearings to navigate players


local modulesPath = "\\waypoints\\modules\\"
local ui_bearings = false
local lib_waypoints = false

local test_course = "[\"316.7,104.0,-124.3\",\"Kai\",\"John さんの家の周りをまわりましょう！\"|\"361.8,103.4,-127.3\"|\"366.3,104.0,-64.4\",\"\",\"この先には秘密の迷路が！？\"|\"321.7,104.3,-59.5\",\"\",\"ここは入口反転型の家\"|\"318.1,104.0,-124.4\",\"\",\"ゴールまであと少しです。\"]"


function __(ident, msg)
  if localizations[ident] then
    return localizations[ident]
  end
    
  return msg
end

function minmax(a, b, c) 
  if a < b then a = b end
  if a > c then a = c end
  return a
end


waypoints = {
  VERSION = "1.0.2",
  CONFIG = { arrival_max = 5, -- maximum 3d distance for arrival
             arrival_min = 2, -- minimum 3d distance for arrival
             arrival_vdist = 2, -- maximum vertical distance for arrival
           },
  ui_initialized = 0,
  enabled = 0,
  visible = 1,
  arrow_size = 40,
  adraw = { cx, cy, scale },
  window = { right = 100, top = 75, width = 200, height = 137},
  window_box = { left, top, right, bottom },
  arrow_box = { left, top, right, bottom },
  arrow_angle = 0,
  gui_time = { l, s, t},
  textures = { backdrop, alert, button, arrows = {}, stairs, },
  alerts = { msg, timeout = 0},  
  win_hider_x = 0,
  waypoint_set_by = "",
}

localizations = {
  msg_shroud_on_start = "WAYPOINTS.lua loaded version %s",
  msg_move_map_short = "マップ移動: %s",
  msg_move_map_long = "マップ %s に移動してください。",
  msg_guide_completed_short = "案内は終了しました。",  
  msg_distance_short = "目的地まで %0.1f",
  msg_next_node_found_long = "次の目的地を設定しました。 %s",
  msg_next_location_long = "次の目的地： %s",
  msg_next_objective_long = "次: %s",
  msg_last_objective_long = "前: %s",
  msg_arrived_long = "目的地に到着しました。",
  msg_command_stop = "目的地のガイドを中断しました。",  
  msg_no_comment = "周辺に注意して移動しましょう。",
  
  button_next = "次へ",
  button_restart = "再開始",
  button_mark = "座標記録",
  button_stop = "中断",
  button_close = "閉じる",
}

function doRequire(filename)
    local _modulesPath = ShroudLuaPath .. modulesPath
    local file = io.open(_modulesPath .. filename .. ".lua")
    local data = file:read("*all")
    file:close()
    _G["init_" .. filename] = assert(loadsafe(data))
end

function ShroudOnStart() 
  doRequire('lib_ui_bearings')
  ui_bearings = init_lib_ui_bearings()
  
  doRequire('lib_waypoints')
  lib_waypoints = init_lib_waypoints()
  
end

function InitApp()  
  if (waypoints.ui_initialized == 1) then return end
  
  waypoints.ui_initialized = 1  
  
  waypoints.gui_time.l = os.time()
  
  lib_waypoints.doSetLast(test_course)
  
  waypoints.textures.backdrop = ShroudLoadTexture("waypoints/images/backdrop.png", true)
  waypoints.textures.alert    = ShroudLoadTexture("waypoints/images/alert.png", true)
  waypoints.textures.button   = ShroudLoadTexture("waypoints/images/blank.png", true)
  waypoints.textures.stairs   = ShroudLoadTexture("waypoints/images/stairs.png", true)
  
  waypoints.textures.arrows = {}
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-0.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-1.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-2.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-3.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-4.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-5.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-6.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-7.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-8.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-9.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-10.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-11.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-12.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-13.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-14.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/images/arrow-15.png", true)
  
  ConsoleLog(string.format(__("msg_shroud_on_start", "WAYPOINTS.lua loaded version %s"), waypoints.VERSION))
  
end

function drawAngleText(angle, distance, text)
  local nx, ny
  
  angle = (angle - ui_bearings.bearingFocused) / 180 * math.pi

  nx = math.sin(angle) * distance * waypoints.adraw.scale + waypoints.adraw.cx
  ny = -math.cos(angle) * distance * waypoints.adraw.scale + waypoints.adraw.cy
  
  ShroudGUILabel(nx, ny, 32, 32, text)
  
end

function showMainUIStatus(msg)
  if not ShroudIsCharacterSheetActive() then
    ShroudGUILabel(waypoints.window_box.left + 3, waypoints.window_box.bottom - 20, waypoints.window.width, 20, msg)
  end
end


function doNavigate()
  ShroudGUILabel(waypoints.window_box.left + 3, waypoints.window_box.top - 2, waypoints.window.width, 20, "<color=#000000FF>WAYPOINTS.lua</color>")
  
  if waypoints.enabled == 0 then
    showMainUIStatus(__("msg_guide_completed_short", "Done guiding."))
    return
  end
  
  local angle, distance, hdiff
  local hdist, vdist
  local mx, my, mouseOver = 0
  local comment = lib_waypoints.target.comment
  if comment == "" then
    comment = __("msg_no_comment", "Please move along")
  end
  
  mx = ShroudMouseX
  my = ShroudMouseY
  
  if (mx >= waypoints.window_box.left) and (mx <= waypoints.window_box.left + 100) and (my >= waypoints.window_box.top) and (my <= waypoints.window_box.bottom) then
    if not ShroudIsCharacterSheetActive() then
      mouseOver = 1
    end
  end
  
  if lib_waypoints.target.map != "" then
    if lib_waypoints.target.map != lib_waypoints.getSafeMapName() then
      showMainUIStatus(string.format(__("msg_move_map_short", "Move to: %s"), lib_waypoints.target.map))
      if mouseOver == 1 then
        showAlert(string.format(__("msg_move_map_long", "Please move to map: %s"), lib_waypoints.target.map), 2)
      end
      return
    end
  end
  
  angle = math.atan2(lib_waypoints.target.x- ShroudPlayerX, lib_waypoints.target.z - ShroudPlayerZ)  
  angle = (angle / math.pi * 180)  
  
  distance = math.sqrt(math.pow(lib_waypoints.target.x - ShroudPlayerX, 2) + math.pow(lib_waypoints.target.y - ShroudPlayerY, 2) + math.pow(lib_waypoints.target.z - ShroudPlayerZ, 2))
  hdist = math.sqrt(math.pow(lib_waypoints.target.x - ShroudPlayerX, 2) + math.pow(lib_waypoints.target.z - ShroudPlayerZ, 2))
  vdist = math.abs(lib_waypoints.target.y - ShroudPlayerY)
  
  if not ShroudIsCharacterSheetActive() then
    if distance > 20 then
      drawAngleText(angle, 2, "x")
    else
      drawAngleText(angle, distance / 10, "o")
    end
  end
  
  showMainUIStatus(string.format(__("msg_distance_short", "Distance: %0.1f"), distance))
  
  local distance_limit
  distance_limit = math.max(1, waypoints.CONFIG.arrival_min, math.min(10, waypoints.CONFIG.arrival_max, lib_waypoints.next_distance / 2 - 1))
  
  if distance < distance_limit then
    if vdist < math.max(1, waypoints.CONFIG.arrival_vdist) then
      doNext()
    end
  end
  
  hdiff = lib_waypoints.target.y- ShroudPlayerY
  if not ShroudIsCharacterSheetActive() then
    if hdiff < 0 then
      local hy = hdiff
      if (hdiff < -24) then hy = -24 end
      ShroudGUILabel(waypoints.window_box.left + 105, waypoints.window_box.top + waypoints.window.height / 2 - hy * 2 - 10, 40, 20, string.format("%0.1f", hdiff))
    end
    if hdiff > 0 then
      local hy = hdiff
      if (hdiff > 24) then hy = 24 end
      ShroudGUILabel(waypoints.window_box.left + 105, waypoints.window_box.top + waypoints.window.height / 2 - hy * 2 - 10, 40, 20, string.format("+%0.1f", hdiff))
    end
    
    if mouseOver == 1 then
      showAlert(string.format(__("msg_next_objective_long", "Next Objective: %s"), comment), 2)    
    end
  end
  
  local client_width 　= ShroudGetScreenX()
  local client_height = ShroudGetScreenY()
  
  local angle_diff = angle - ui_bearings.bearingFocused
  local scale = math.sqrt(math.pow(waypoints.arrow_box.right - waypoints.arrow_box.left, 2) + math.pow(waypoints.arrow_box.bottom - waypoints.arrow_box.top, 2)) / 2
  local ax, ay
  
  if distance < 20 then
    scale = scale * (distance / 20)
  end
  
  -- check for stairs
  if (hdist < 20) and (vdist > 5) then
    if lib_waypoints.target.y - ShroudPlayerY > 0 then
      angle_diff = 0
    else
      angle_diff = 180
    end
  end
  
  -- Do a Constant Angular Velocity on arrow rotation
  waypoints.arrow_angle = ui_bearings.CAVRotate(waypoints.arrow_angle, angle_diff, 180 * waypoints.gui_time.s)
  
  ax = (client_width  / 2) + math.sin(waypoints.arrow_angle / 180 * math.pi) * scale
  ay = (client_height / 2) - math.cos(waypoints.arrow_angle / 180 * math.pi) * scale
  
  ax = minmax(ax, waypoints.arrow_box.left, waypoints.arrow_box.right)
  ay = minmax(ay, waypoints.arrow_box.top, waypoints.arrow_box.bottom)
  
  --ConsoleLog(ax .. "," .. ay)
  
  local imgidx = math.floor((waypoints.arrow_angle + 22.5 / 2) / 22.5)
  while imgidx < 0 do
    imgidx = imgidx + 16
  end
  while imgidx >= 16 do
    imgidx = imgidx - 16
  end
  
  if (hdist < 20) and (vdist > 5) then
    ShroudDrawTexture(ax- waypoints.arrow_size, ay -waypoints.arrow_size / 2 - 16, waypoints.arrow_size  * 1.5, waypoints.arrow_size * 1.5, waypoints.textures.stairs, StretchToFill)
  end
  
  
  ShroudDrawTexture(ax -waypoints.arrow_size / 2, ay -waypoints.arrow_size / 2, waypoints.arrow_size, waypoints.arrow_size, waypoints.textures.arrows[imgidx + 1], StretchToFill)
  
  -- center text
  local text = string.format("%0.1f (%0.1f)", distance, distance_limit)
  ShroudGUILabel(ax - #text * 3, ay + waypoints.arrow_size / 2, #text * 7, 40, text)
  
end

function showAlert(msg, timeout)
  waypoints.alerts.msg = msg
  waypoints.alerts.timeout = os.time() + timeout
end

function ShroudOnGUI()
  if waypoints.ui_initialized == 0 then return end
  
  -- check time slice
  waypoints.gui_time.t = os.time()
  waypoints.gui_time.s = waypoints.gui_time.t - waypoints.gui_time.l
  waypoints.gui_time.l = waypoints.gui_time.t
  
  ui_bearings.doFocusBearings()
  
  local client_width 　= ShroudGetScreenX()
  local client_height = ShroudGetScreenY()
  
  if waypoints.alerts.timeout > os.time() then
    local tx = client_width / 2 - 300
    local ty = waypoints.window.top
    ShroudDrawTexture(tx, ty, 600, 40, waypoints.textures.alert, StretchToFill)
    ShroudGUILabel(tx + 3, ty - 2, 600, 20, "<color=#000000FF>WAYPOINTS.lua</color>")    
    ShroudGUILabel(tx + 3, ty + 16, 600, 24, "<size=16>" .. waypoints.alerts.msg .. "</size>")
    
    if lib_waypoints.last_comment != nil then
      ShroudDrawTexture(tx, ty + 40, 600, 40, waypoints.textures.alert, StretchToFill)
      
      ShroudGUILabel(tx + 3, ty + 40 + 16, 600, 24, "<size=16>" .. string.format(__("msg_last_objective_long", "Last Objective: %s"), lib_waypoints.last_comment) .. "</size>")
    end    
    
  end
  
  if waypoints.visible == 0 then
    return
  end  
  
  if ShroudIsCharacterSheetActive() then  
    waypoints.win_hider_x = waypoints.win_hider_x - 2000 * waypoints.gui_time.s
    if (waypoints.win_hider_x < 3) then waypoints.win_hider_x = 3 end
  else
    local hider_limit = waypoints.window.right + waypoints.window.width
    waypoints.win_hider_x = waypoints.win_hider_x + 2000 * waypoints.gui_time.s
    if (waypoints.win_hider_x > hider_limit) then waypoints.win_hider_x = hider_limit end
  end
    
  
  -- set window box size for events
  waypoints.window_box.left = client_width - waypoints.win_hider_x
  waypoints.window_box.top  = waypoints.window.top
  waypoints.window_box.right = waypoints.window_box.left + waypoints.window.width
  waypoints.window_box.bottom = waypoints.window_box.top + waypoints.window.height
  
  -- set arrow box size for edge limiting
  waypoints.arrow_box.left = waypoints.window.right + waypoints.window.width
  waypoints.arrow_box.right = client_width - waypoints.arrow_box.left
  waypoints.arrow_box.top = waypoints.window.top + waypoints.window.height
  waypoints.arrow_box.bottom = client_height - waypoints.arrow_box.top
  
  
  if waypoints.textures.backdrop != nil then
    if waypoints.textures.backdrop > 0 then
      ShroudDrawTexture(waypoints.window_box.left, waypoints.window_box.top, waypoints.window.width, waypoints.window.height, waypoints.textures.backdrop, StretchToFill)
    end
  end
  
    
  if not ShroudIsCharacterSheetActive() then  
    if waypoints.textures.button > 0 then
      if ShroudButton(waypoints.window_box.left + 130, waypoints.window_box.top + 16 + 24 * 0, 64, 21, waypoints.textures.button, __("button_next", "Next"), "") then
        doNext()
        return
      end
      if ShroudButton(waypoints.window_box.left + 130, waypoints.window_box.top + 16 + 24 * 1, 64, 21, waypoints.textures.button, __("button_restart", "Restart"), "") then
        lib_waypoints.doRestart()
        doNext()
        return
      end
      if ShroudButton(waypoints.window_box.left + 130, waypoints.window_box.top + 16 + 24 * 2, 64, 21, waypoints.textures.button, __("button_mark", "Mark Here"), "") then
        local current_loc = lib_waypoints.getWaypointString("")
        ConsoleLog("+WAYPOINT: " .. current_loc)      
      end
      if ShroudButton(waypoints.window_box.left + 130, waypoints.window_box.top + 16 + 24 * 3, 64, 21, waypoints.textures.button, __("button_stop", "Stop"), "") then
        waypoints.enabled = 0
      end
      if ShroudButton(waypoints.window_box.left + 130, waypoints.window_box.top + 16 + 24 * 4, 64, 21, waypoints.textures.button, __("button_close", "Close UI"), "") then
        waypoints.visible = 0
      end  
      
    end
  
  
  -- Set center of navigation
  
    waypoints.adraw.scale = 20
    waypoints.adraw.cx = waypoints.window_box.left + 50
    waypoints.adraw.cy = waypoints.window_box.top + 57
    
    drawAngleText(0, 1, "N")
    drawAngleText(90, 1, "E")
    drawAngleText(180, 1, "S")
    drawAngleText(270, 1, "W")
  end
  
  doNavigate()
  
end

function ShroudOnUpdate()  
  if waypoints.ui_initialized == 0 then
    InitApp()
    return
  end
  
  if (ui_bearings) then
    ui_bearings.doDetectBearings()
  end
end

function ShroudOnConsoleInput(channel, sender, message) 
  local src, dst, msg = string.match(message, "^(.-) to (.-) %[.-:%s*(.*)$")
  if sender == "" then sender = src end
  if sender == "" then sender = ShroudGetPlayerName() end
  if string.byte(msg) == 92 then
    local cmd, arg = string.match(msg, "^\\(%w+)%s*(.*)$")
    if cmd == "waypoints" then dispatchCommand(channel, sender, cmd, arg) end
    if cmd == "waypoint"  then dispatchCommand(channel, sender, cmd, arg) end
  end
end

function doNext()
    waypoints.enabled = 0
    if lib_waypoints.doNext() then
      ConsoleLog("WAYPOINTS: Waypoint Set. " .. lib_waypoints.getCount() .. " waypoints remaining.")
      showAlert(waypoints.waypoint_set_by .. string.format(__("msg_next_node_found_long", "Next waypoint found. %s"), lib_waypoints.target.comment), 5)
      waypoints.waypoint_set_by = ""
      waypoints.enabled = 1
    else      
      ConsoleLog("WAYPOINTS: End of route.");
      showAlert(string.format(__("msg_arrived_long", "Arrived at destination.")), 5)
    end
end  

function dispatchCommand(channel, sender, cmd, arg)
  --ConsoleLog(channel .. "|" .. sender .. "|" .. cmd .. "|" .. arg)
  
  local as_self, as_friend, valid_arg
  
  as_self = 0
  as_friend = 0
  valid_arg = 0
  
  if arg == "" then arg = "get" end
  if sender == ShroudGetPlayerName() then as_self = 1 end
  if channel == "Party" then as_friend = 1 end  
  if channel == "NPC" then as_friend = 1 end  
  if channel == "Private" then 
    as_friend = 1     
    -- do not react to yourselves
    if sender == ShroudGetPlayerName() then return end
    
  end  
  
  -- get current waypoint
  if (arg == "get") and (as_self == 1) then
    local current_loc = lib_waypoints.getWaypointString("")
    ConsoleLog("+WAYPOINT: " .. current_loc)
    return
  end  
  
  -- get current waypoint
  if (string.sub(arg, 1, 4) == "get ") and (as_self == 1) then
    local current_loc = lib_waypoints.getWaypointString(string.sub(arg, 5))
    ConsoleLog("+WAYPOINT: " .. current_loc)
    return
  end  
  
  -- get current waypoint
  if (string.sub(arg, 1, 5) == "load ") and (as_self == 1) then
    waypoints.is_enabled = 0
    if lib_waypoints.doLoad(string.sub(arg, 6)) then
      doNext()
     end
    return
  end  
  
  -- get next waypoint
  if (arg == "next") and (as_self == 1) then
    doNext()
    return
  end  
  
  if (arg == "restart") and (as_self == 1) then
    lib_waypoints.doRestart()
    doNext()
    return
  end    
  
  if (arg == "revert") and (as_self == 1) then
    lib_waypoints.doRevert()
    doNext()
    return
  end    
  
  
  if (arg == "stop") and (as_self == 1) then
    waypoints.enabled = 0
    showAlert(__("msg_command_stop", "Guide terminated"), 5)
    return
  end  
  
  
  if (arg == "test") and (as_self == 1) then
    waypoints.enabled = 0
    if lib_waypoints.doSetJson(test_course) then
        ConsoleLog("WAYPOINTS: Waypoint Set. " .. lib_waypoints.getCount() .. " waypoints read.")
        doNext()
        waypoints.enabled = 1      
    else
        ConsoleLog("WAYPOINTS: Test course load failed.")
    end
    return    
  end
  
    if (arg == "save") and (as_self == 1) then
      
      waypoints.enabled = 0
      local route = lib_waypoints.doGetOptimized()
      ConsoleLog("USE THESE WAYPOINTS: \\waypoints set " .. route)
      lib_waypoints.doSetLast(route)
      return    
    end
  
  -- set waypoints
  if string.sub(arg, 1, 4) == "set " then
    if (as_self == 1) or (as_friend == 1) then
      waypoints.enabled = 0
      if lib_waypoints.doSetJson(string.sub(arg, 5)) then
        waypoints.waypoint_set_by = ""
        if sender != ShroudGetPlayerName() then
          waypoints.waypoint_set_by = string.format("%s: ", sender)
        end
        ConsoleLog("WAYPOINTS: Waypoint Set. " .. lib_waypoints.getCount() .. " waypoints read.")
        doNext()
        waypoints.enabled = 1
      else
        ConsoleLog("WAYPOINTS: JSON Parse Failed")
      end
      return
    end
  end
   
  if valid_arg == 1 then return end
  if as_self == 0 then return end
  ShroudConsoleLog("Syntax: \\" .. cmd .. " get [comment] - " .. __("help_get",  "Mark current location"))
  ShroudConsoleLog("Syntax: \\" .. cmd .. " save          - " .. __("help_save", "Optimize marked location and dump listing"))
  
  ShroudConsoleLog("Syntax: \\" .. cmd .. " set [route]   - " .. __("help_set", "Set new route to navigate"))
  ShroudConsoleLog("Syntax: \\" .. cmd .. " next          - " .. __("help_next", "Move to next waypoint"))
  
  ShroudConsoleLog("Syntax: \\" .. cmd .. " restart       - " .. __("help_restart", "Restart navigation from beginning"))  
  ShroudConsoleLog("Syntax: \\" .. cmd .. " revert        - " .. __("help_revert", "Rollback to previous route"))
  ShroudConsoleLog("Syntax: \\" .. cmd .. " load [path]   - " .. __("help_load", "Load route from file"))
  
end

