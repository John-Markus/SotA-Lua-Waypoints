-- waypoints.app by John Markus
-- uses screen bearings to navigate players
-- depends on libsota.0.4.x


local modulesPath = "\\waypoints\\"
local ui_bearings
local lib_waypoints

local test_course = "[\"316.7,104.0,-124.3\",\"Kai\",\"John さんの家の周りをまわりましょう！\"|\"361.8,103.4,-127.3\"|\"366.3,104.0,-64.4\",\"\",\"この先には秘密の迷路が！？\"|\"321.7,104.3,-59.5\",\"\",\"ここは入口反転型の家\"|\"318.1,104.0,-124.4\",\"\",\"ゴールまであと少しです。\"]"

waypoints = {
  enabled = 0,
  visible = 1,
  arrow_size = 40,
  adraw = { cx, cy, scale },
  window = { right = 100, top = 75, width = 200, height = 137},
  window_box = { left, top, right, bottom },
  arrow_box = { left, top, right, bottom },
  textures = { backdrop, alert, button, arrows = {} },
  alerts = { msg, timeout = 0},  
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
  lib_waypoints.doSetLast(test_course)
  
  waypoints.textures.backdrop = ShroudLoadTexture("waypoints/backdrop.png", true)
  waypoints.textures.alert    = ShroudLoadTexture("waypoints/alert.png", true)
  waypoints.textures.button   = ShroudLoadTexture("waypoints/blank.png", true)
  
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-0.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-1.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-2.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-3.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-4.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-5.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-6.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-7.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-8.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-9.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-10.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-11.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-12.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-13.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-14.png", true)
  waypoints.textures.arrows[1+#waypoints.textures.arrows] = ShroudLoadTexture("waypoints/arrow-15.png", true)
  
end

function drawAngleText(angle, distance, text)
  local nx, ny
  
  angle = (angle - ui_bearings.bearingFocused) / 180 * math.pi

  nx = math.sin(angle) * distance * waypoints.adraw.scale + waypoints.adraw.cx
  ny = -math.cos(angle) * distance * waypoints.adraw.scale + waypoints.adraw.cy
  
  ShroudGUILabel(nx, ny, 32, 32, text)
  
end

function doNavigate()
  ShroudGUILabel(waypoints.window_box.left + 3, waypoints.window_box.top - 2, waypoints.window.width, 20, "<color=#000000FF>WAYPOINTS.lua</color>")
  
  if waypoints.enabled == 0 then
    ShroudGUILabel(waypoints.window_box.left + 3, waypoints.window_box.bottom - 20, waypoints.window.width, 20, "案内は終了しました。")
    return
  end
  
  
  local angle, distance, hdiff
  local mx, my, mouseOver = 0
  
  mx = ShroudMouseX
  my = ShroudMouseY
  
  if (mx >= waypoints.window_box.left) and (mx <= waypoints.window_box.left + 100) and (my >= waypoints.window_box.top) and (my <= waypoints.window_box.bottom) then
    mouseOver = 1
  end
  
  if lib_waypoints.target.map != "" then
    if lib_waypoints.target.map != ShroudGetCurrentSceneName() then
      ShroudGUILabel(waypoints.window_box.left + 3, waypoints.window_box.bottom - 20, waypoints.window.width, 20, "マップ移動: " .. lib_waypoints.target.map)
      if mouseOver == 1 then
        showAlert("マップ " .. lib_waypoints.target.map .. " に移動してください。", 2)
      end      
      return
    end
  end
  
  angle = math.atan2(lib_waypoints.target.x- ShroudPlayerX, lib_waypoints.target.z - ShroudPlayerZ)  
  angle = (angle / math.pi * 180)  
  
  distance = math.sqrt(math.pow(lib_waypoints.target.x - ShroudPlayerX, 2) + math.pow(lib_waypoints.target.y - ShroudPlayerY, 2) + math.pow(lib_waypoints.target.z - ShroudPlayerZ, 2))
  
  
  
  if distance > 20 then
    drawAngleText(angle, 2, "x")
  else
    drawAngleText(angle, distance / 10, "o")
  end
  
  ShroudGUILabel(waypoints.window_box.left + 3, waypoints.window_box.bottom - 20, waypoints.window.width, 20, string.format("目的地まで %0.1f", distance))
  
  if distance < 3 then
    doNext()
  end
  
  hdiff = lib_waypoints.target.y- ShroudPlayerY
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
    showAlert(string.format("次の目的地: " .. lib_waypoints.target.comment), 2)    
  end
  
  local client_width 　= ShroudGetScreenX()
  local client_height = ShroudGetScreenY()
  
  local angle_diff = angle - ui_bearings.bearingFocused
  local scale = math.sqrt(math.pow(waypoints.arrow_box.right - waypoints.arrow_box.left, 2) + math.pow(waypoints.arrow_box.bottom - waypoints.arrow_box.top, 2)) / 2
  local ax, ay
  
  if distance < 20 then
    scale = scale * (distance / 20)
  end
  
  ax = (client_width  / 2) + math.sin(angle_diff / 180 * math.pi) * scale
  ay = (client_height / 2) - math.cos(angle_diff / 180 * math.pi) * scale
  
  if ax < waypoints.arrow_box.left   then ax = waypoints.arrow_box.left end
  if ay < waypoints.arrow_box.top    then ay = waypoints.arrow_box.top  end
  if ax > waypoints.arrow_box.right  then ax = waypoints.arrow_box.right end
  if ay > waypoints.arrow_box.bottom then ay = waypoints.arrow_box.bottom end
  
  --ConsoleLog(ax .. "," .. ay)
  
  local imgidx = math.floor((angle_diff + 22.5 / 2) / 22.5)
  while imgidx < 0 do
    imgidx = imgidx + 16
  end
  while imgidx >= 16 do
    imgidx = imgidx - 16
  end
  
  ShroudDrawTexture(ax -waypoints.arrow_size / 2, ay -waypoints.arrow_size / 2, waypoints.arrow_size, waypoints.arrow_size, waypoints.textures.arrows[imgidx + 1], StretchToFill)
  ShroudGUILabel(ax - waypoints.arrow_size / 2, ay + waypoints.arrow_size / 2, 40, 20, string.format("%0.1f", distance))
  
  
  
end

function showAlert(msg, timeout)
  waypoints.alerts.msg = msg
  waypoints.alerts.timeout = os.time() + timeout
end

function ShroudOnGUI()
  ui_bearings.doFocusBearings()
  
  local client_width 　= ShroudGetScreenX()
  local client_height = ShroudGetScreenY()
  
  if waypoints.alerts.timeout > os.time() then
    ShroudDrawTexture(client_width / 2 - 300, client_height / 2 - 120, 600, 40, waypoints.textures.alert, StretchToFill)
    ShroudGUILabel(client_width / 2 - 300 + 3, client_height / 2 - 120 - 2, 600, 20, "<color=#000000FF>WAYPOINTS.lua</color>")    
    ShroudGUILabel(client_width / 2 - 300 + 3, client_height / 2 - 120 + 16, 600, 24, "<size=16>" .. waypoints.alerts.msg .. "</size>")
  end
  
  if waypoints.visible == 0 then
    return
  end  
  
  
  
  waypoints.window_box.left = client_width - waypoints.window.right - waypoints.window.width
  waypoints.window_box.top  = waypoints.window.top
  waypoints.window_box.right = waypoints.window_box.left + waypoints.window.width
  waypoints.window_box.bottom = waypoints.window_box.top + waypoints.window.height
  
  waypoints.arrow_box.left = waypoints.window.right + waypoints.window.width
  waypoints.arrow_box.right = client_width - waypoints.arrow_box.left
  waypoints.arrow_box.top = waypoints.window.top + waypoints.window.height
  waypoints.arrow_box.bottom = client_height - waypoints.arrow_box.top
  

  if waypoints.textures.backdrop > 0 then
    ShroudDrawTexture(waypoints.window_box.left, waypoints.window_box.top, waypoints.window.width, waypoints.window.height, waypoints.textures.backdrop, StretchToFill)
  end
  
  if waypoints.textures.button > 0 then
    if ShroudButton(waypoints.window_box.left + 130, waypoints.window_box.top + 16 + 24 * 0, 64, 21, waypoints.textures.button, "次へ", "次のポイントへ移動") then
      doNext()
      return
    end
    if ShroudButton(waypoints.window_box.left + 130, waypoints.window_box.top + 16 + 24 * 1, 64, 21, waypoints.textures.button, "再開始", "最初から案内開始") then
      lib_waypoints.doRestart()
      doNext()
      return
    end
    if ShroudButton(waypoints.window_box.left + 130, waypoints.window_box.top + 16 + 24 * 2, 64, 21, waypoints.textures.button, "座標記録", "この地点を登録する") then
      local current_loc = lib_waypoints.getWaypointString("")
      ConsoleLog("+WAYPOINT: " .. current_loc)      
    end
    if ShroudButton(waypoints.window_box.left + 130, waypoints.window_box.top + 16 + 24 * 3, 64, 21, waypoints.textures.button, "案内終了", "案内を止める") then
      waypoints.enabled = 0
    end
    if ShroudButton(waypoints.window_box.left + 130, waypoints.window_box.top + 16 + 24 * 4, 64, 21, waypoints.textures.button, "閉じる", "UI を閉じる") then
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
  
  doNavigate()
  
end

function ShroudOnUpdate()
  ui_bearings.doDetectBearings()
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
      showAlert(string.format("次の目的地を設定しました。 " .. lib_waypoints.target.comment), 5)
      waypoints.enabled = 1
    else      
      ConsoleLog("WAYPOINTS: End of route.");
      showAlert(string.format("目的地に到着しました。"), 5)
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
  if channel == "party" then as_friend = 1 end  
  
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
  
  
  -- get next waypoint
  if (arg == "next") and (as_self == 1) then
    doNext()
    return
  end  
  
  if (arg == "stop") and (as_self == 1) then
    waypoints.enabled = 0
    showAlert("目的地のガイドを中断しました。", 5)
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
  ShroudConsoleLog("Syntax: \\" .. cmd .. " get [comment] - 現在位置を記録")
  ShroudConsoleLog("Syntax: \\" .. cmd .. " save          - 記録した移動ルートを表示")
  
  ShroudConsoleLog("Syntax: \\" .. cmd .. " set [route]   - 移動ルートを指定")  
  
  ShroudConsoleLog("Syntax: \\" .. cmd .. " next          - 次の目標地点へ")
  
end




