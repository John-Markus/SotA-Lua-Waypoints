local UIB = { }

UIB.focus_speed = 360.0
UIB.bearing = 0
UIB.bearingFocused = 0
UIB.self = { 
  this_loc = {x = ShroudPlayerX, y = ShroudPlayerY, z = ShroudPlayerZ, t = os.time()},
  last_loc = {x = ShroudPlayerX, y = ShroudPlayerY, z = ShroudPlayerZ, t = os.time()},
  hints = {d, t},
  last_frame = 0,  
}

UIB.self.doSanity = function()
  local is_sane = true
  
  if UIB.self.last_loc.x == nil then 
    UIB.self.last_loc.x = ShroudPlayerX 
    is_sane = false
  end
  if UIB.self.last_loc.y == nil then 
    UIB.self.last_loc.y = ShroudPlayerY 
    is_sane = false
  end
  if UIB.self.last_loc.z == nil then 
    UIB.self.last_loc.z = ShroudPlayerZ 
    is_sane = false
  end
  
  return is_sane
end


-- Try to generate hints for changes caused by the user movement
UIB.self.doDetectMovementHints = function()
  local dd_hint_count = 0
  local dd_new_direction = 0
  local angle = 0
  if ShroudGetKeyDown("W") then
    dd_new_direction = dd_new_direction + 0
    dd_hint_count = dd_hint_count + 1
  end
  
  if ShroudGetKeyDown("D") then
    dd_new_direction = dd_new_direction + 90
    dd_hint_count = dd_hint_count + 1
  end  
  
  if ShroudGetKeyDown("S") then
    dd_new_direction = dd_new_direction + 180
    dd_hint_count = dd_hint_count + 1
  end  
  
  if ShroudGetKeyDown("A") then
    if (dd_new_direction == 0) then
      dd_new_direction = 360
    end
    
    dd_new_direction = dd_new_direction + 270
    dd_hint_count = dd_hint_count + 1    
  end  
  
  if (dd_hint_count > 0) then    
    angle = dd_new_direction / dd_hint_count
    while angle >= 360 do
      angle = angle - 360
    end
    
    UIB.self.hints.d = angle
    UIB.self.hints.t = os.time()
  end

end

UIB.self.doCalculateAngles = function()
  local angle
  
  if not UIB.self.doSanity() then return end
  
  UIB.self.this_loc.x = ShroudPlayerX
  UIB.self.this_loc.y = ShroudPlayerY
  UIB.self.this_loc.z = ShroudPlayerZ
  UIB.self.this_loc.t = os.time()
  
  -- check if we have moved
  if (UIB.self.this_loc.x == UIB.self.last_loc.x) and (UIB.self.this_loc.z == UIB.self.last_loc.z) then
    return UIB.bearing
  end
  
  angle = math.atan2(UIB.self.this_loc.x - UIB.self.last_loc.x, UIB.self.this_loc.z - UIB.self.last_loc.z)
  angle = (angle / math.pi * 180) - UIB.self.hints.d
  while angle < 0 do
    angle = angle + 360
  end
  
  UIB.bearing = angle
  
  UIB.self.last_loc.x = UIB.self.this_loc.x
  UIB.self.last_loc.y = UIB.self.this_loc.y
  UIB.self.last_loc.z = UIB.self.this_loc.z
  UIB.self.last_loc.t = UIB.self.this_loc.t
  
  return angle  
end

-- This should be run on ShroudOnUpdate()
UIB.doDetectBearings = function()
  UIB.self.doDetectMovementHints()
  UIB.self.doCalculateAngles()  
end

-- This should be run on ShroudOnGUI()
UIB.doFocusBearings = function()
  local current_frame, focus_speed, time_passed, angle_diff
  
  if UIB.self.last_frame == 0 then 
    UIB.self.last_frame = os.time()
    UIB.bearingFocused = UIB.bearing
    return UIB.bearingFocused
  end
  
  current_frame = os.time()
  time_passed = current_frame - UIB.self.last_frame
  if time_passed == 0 then 
    return UIB.bearingFocused
  end
  UIB.self.last_frame = current_frame
  focus_speed = UIB.focus_speed * time_passed
  
  -- check if we can complete in one cycle
  if math.abs(UIB.bearing - UIB.bearingFocused) <= focus_speed then
    UIB.bearingFocused = UIB.bearing
    return UIB.bearingFocused
  end  
  
  angle_diff = UIB.bearing - UIB.bearingFocused
  while angle_diff < 0 do
    angle_diff = angle_diff + 360
  end
  
  if angle_diff < 180 then
    UIB.bearingFocused = UIB.bearingFocused + focus_speed
  else
    UIB.bearingFocused = UIB.bearingFocused - focus_speed
  end
  
  while UIB.bearingFocused < 0 do
    UIB.bearingFocused = UIB.bearingFocused + 360
  end
  while UIB.bearingFocused >= 360 do
    UIB.bearingFocused = UIB.bearingFocused - 360
  end
  
  return UIB.bearingFocused
  
end


return UIB
