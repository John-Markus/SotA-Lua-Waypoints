-- Decode and process waypoints listed in space-saving formats

local WPT = { 
  self = {
    nodes = {},
    current_node = {},
    last_args = "",
    last2_args = "",
    last_map,    
    saved_nodes = {},
  },
  last_comment = "",
  target = {x, y, z, map, comment},
  last_target = {x, y, z, map, comment},
  next_distance = 100,
  module_paths = "\\waypoints\\routes\\",  
}

WPT.self.parseJson = function(arg)
  return json.parse(arg)
end


WPT.sanitizeMapName = function(mapname)
  if mapname == nil then return "" end
  mapname = mapname .. "["
  mapname = string.match(mapname, "^([^\\[]*)([\\[].*)")
  mapname = mapname:gsub("^%s+", ""):gsub("%s+$", "")
  return mapname  
end

WPT.getSafeMapName = function()
  return WPT.sanitizeMapName(ShroudGetCurrentSceneName())
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
  WPT.self.last_map = WPT.getSafeMapName()
  WPT.next_distance = 0
  WPT.last_comment = ""
  
  if WPT.self.last_args != arg then
    WPT.self.last2_args = WPT.self.last_args
    WPT.self.last_args = arg
  end
  
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




WPT.doLoad = function(filename)
  ConsoleLog(string.format("WAYPOINTS: To REUSE: \\waypoints load %s", filename))
  
  filename = filename:gsub(" ", "_")
  local path = ShroudLuaPath .. WPT.module_paths .. filename .. ".txt"
  path = path:gsub("\\", "/")
  ConsoleLog("WAYPOINTS: Attempting to load from " .. path)
  
  -- test if file exists
  local f = io.open(path, "rb")
  if f then f:close() end
  if f == nil then
    ConsoleLog("WAYPOINTS: File not found.")
    return false
  end
  
  local result = ""
  local separator = ""
  for line in io.lines(path) do
    line = line:gsub("^%s+", ""):gsub("%s+$", "")
    if string.sub(line, 1,2) == "--" then line = "" end
    if line != "" then
      result = result .. separator .. line
      separator = ","
    end
  end
  
  if result != "" then
    ConsoleLog("WAYPOINTS: File loaded. " .. result)
    return WPT.doSetJson(result)
  end
  return false
 
end


WPT.doNext = function()
  WPT.self.current_node = {}
  if #WPT.self.nodes == 0 then
    return false
  end
  
  WPT.self.current_node = table.remove(WPT.self.nodes, 1)
  
  -- parse it
  WPT.last_comment = WPT.target.comment
  WPT.target.map = WPT.self.last_map
  WPT.target.comment = ""
  
  if string.sub(WPT.self.current_node[1],1,1) == "!" then
    if WPT.doLoad(string.sub(WPT.self.current_node[1],2)) then
      WPT.self.current_node = table.remove(WPT.self.nodes, 1)
    else
      return false
    end
  end
  
  WPT.last_target.x = WPT.target.x
  WPT.last_target.y = WPT.target.y
  WPT.last_target.z = WPT.target.z
  WPT.last_target.map = WPT.target.map
  WPT.last_target.comment = WPT.target.comment
  
  WPT.target.x, WPT.target.y, WPT.target.z = string.match(WPT.self.current_node[1], "^(-?[0-9.]+),(-?[0-9.]+),(-?[0-9.]+)$")
  if #WPT.self.current_node >= 2 then WPT.target.map = WPT.self.current_node[2] end
  if #WPT.self.current_node >= 3 then WPT.target.comment = WPT.self.current_node[3] end
  
  if WPT.target.map != "" then
    WPT.target.map = WPT.sanitizeMapName(WPT.target.map)
    WPT.self.last_map = WPT.target.map
  end
  
  WPT.next_distance = 100
  -- Try to find distance to next node so that we can autoscale arrival radius
  if WPT.last_target.z != nil then
      WPT.next_distance = math.sqrt(math.pow(WPT.target.x - WPT.last_target.x, 2) +
                                    math.pow(WPT.target.y - WPT.last_target.y, 2) +
                                    math.pow(WPT.target.z - WPT.last_target.z, 2))
      ConsoleLog('next distance: ' .. WPT.next_distance)
    
  end
  
  return true
end

WPT.doRestart = function()
  return WPT.doSetJson(WPT.self.last_args)
end

WPT.doRevert = function()
  return WPT.doSetJson(WPT.self.last2_args)
end


WPT.doSetLast = function(route)
  WPT.self.last_args = route
end

WPT.getWaypointString = function(comment)
  a = {}
  a[1+#a] = string.format("%d,%d,%d", ShroudPlayerX, ShroudPlayerY, ShroudPlayerZ)
  a[1+#a] = WPT.getSafeMapName()
  a[1+#a] = comment
  table.insert(WPT.self.saved_nodes, a)
  return json.serialize(a)
end

return WPT