-- Calculate bearing (direction) the UI is facing based on movement data

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

-- Perform sanity check to see if data is usable
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
  
  if UIB.self.hints.d == nil then
    UIB.self.hints.d = 0
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
  
  UIB.bearing = UIB.fit360(ShroudGetPlayerOrientation())
    return UIB.bearing
  end
  
-- This should be run on ShroudOnUpdate()
UIB.doDetectBearings = function()
  UIB.self.doDetectMovementHints()
  UIB.self.doCalculateAngles()  
end

-- Contain angle values to between 0 and 359.99999 degrees
UIB.fit360 = function(angle)
  while angle < 0 do
    angle = angle + 360
  end
  while angle >= 360 do
    angle = angle - 360
  end
  return angle

end

-- Smoothen detected bearing using Constand Angular Velocity
UIB.CAVRotate = function(angle_from, angle_to, focus_speed)
  angle_from = UIB.fit360(angle_from)
  angle_to = UIB.fit360(angle_to)
  
    -- check if we can complete in one cycle
  if math.abs(angle_to - angle_from) <= focus_speed then
    return angle_to
  end  
  
  angle_diff = angle_to - angle_from
  while angle_diff < 0 do
    angle_diff = angle_diff + 360
  end
  
  if angle_diff < 180 then
    angle_from = angle_from + focus_speed
  else
    angle_from = angle_from - focus_speed
  end
  
  angle_from = UIB.fit360(angle_from)
  return angle_from
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
  
  -- do a constant angular velocity rotation
  UIB.bearingFocused = UIB.CAVRotate(UIB.bearingFocused, UIB.bearing, focus_speed)
  return UIB.bearingFocused
  
end


return UIB
