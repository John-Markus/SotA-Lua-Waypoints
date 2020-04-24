local WPT = { 
  self = {
    nodes = {},
    current_node = {},
    last_args = "",
    last_map,    
    saved_nodes = {},
  },
  target = {x, y, z, map, comment},
}

WPT.self.parseJson = function(arg)
  return json.parse(arg)
end

WPT.getCount = function()
  return #WPT.self.nodes
end

WPT.doGetOptimized = function()
  local result = ""
  local separator = ""
  local last_loc = {"","",""}
  local this_loc = {}
  local jstext
  
  while #WPT.self.saved_nodes > 0 do
    this_loc = table.remove(WPT.self.saved_nodes, 1)
    a = {}
    if this_loc[3] != "" then
      a[1+#a] = this_loc[1]
      a[1+#a] = this_loc[2]
      a[1+#a] = this_loc[3]
    elseif this_loc[2] != last_loc[2] then
      a[1+#a] = this_loc[1]
      a[1+#a] = this_loc[2]
    elseif this_loc[1] != last_loc[1] then
      a[1+#a] = this_loc[1]
    end
    
    if #a > 0 then
      jstext = json.serialize(a)
      result = result .. separator .. string.sub(jstext, 2, -2)
      separator = "|"
    end
    
    last_loc = this_loc
  end
  WPT.self.saved_nodes = {}
  
  return "[" .. result .. "]"
    
end

WPT.doSetJson = function (arg)
  WPT.self.current_node = {}
  WPT.self.nodes = {}
  WPT.self.last_map = ShroudGetCurrentSceneName()
  
  WPT.self.last_args = arg
  
  arg = string.gsub(arg, "|", "],[")
  
  -- LUA json parse does not allow first item to be table
  if (string.sub(arg, 1, 2) != "[[") then
    arg = "[1," .. arg .. "]"
  end
  
  -- parse JSON safely
  local status, result = pcall(WPT.self.parseJson, arg)
  if not status then
    -- JSON parse failed
    return false
  end
  
  if #result > 0 then
    
    table.remove(result, 1)
    WPT.self.nodes = result
    WPT.self.last_nodes = result
    return true
  else
    return false
  end
end



WPT.doNext = function()
  WPT.self.current_node = {}
  if #WPT.self.nodes == 0 then
    return false
  end
  
  WPT.self.current_node = table.remove(WPT.self.nodes, 1)
  
  -- parse it
  WPT.target.map = WPT.self.last_map
  WPT.target.comment = ""
  
  WPT.target.x, WPT.target.y, WPT.target.z = string.match(WPT.self.current_node[1], "^(-?[0-9.]+),(-?[0-9.]+),(-?[0-9.]+)$")
  if #WPT.self.current_node >= 2 then WPT.target.map = WPT.self.current_node[2] end
  if #WPT.self.current_node >= 3 then WPT.target.comment = WPT.self.current_node[3] end
  
  if WPT.target.map != "" then
    WPT.self.last_map = WPT.target.map
  end
  
  return true
end

WPT.doRestart = function()
  return WPT.doSetJson(WPT.self.last_args)
end

WPT.doSetLast = function(route)
  WPT.self.last_args = route
end

WPT.getWaypointString = function(comment)
  a = {}
  a[1+#a] = string.format("%d,%d,%d", ShroudPlayerX, ShroudPlayerY, ShroudPlayerZ)
  a[1+#a] = ShroudGetCurrentSceneName()  
  a[1+#a] = comment
  table.insert(WPT.self.saved_nodes, a)
  return json.serialize(a)
end

return WPT