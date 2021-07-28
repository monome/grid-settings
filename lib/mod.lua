local mod = require 'core/mods'

local state = {
  intensity = {15,15,15,15},
  rotation = {0,0,0,0},
}

mod.hook.register("system_post_startup", "read grid-settings", function()
  local f = io.open(_path.data..'grid-settings.state')
  if f ~= nil then
    io.close(f)
    state = dofile(_path.data..'grid-settings.state')
  end
end)

mod.hook.register("system_pre_shutdown", "write grid-settings", function()
  local f = io.open(_path.data..'grid-settings.state',"w+")
  io.output(f)
  io.write("return { intensity={")
  for n=1,4 do io.write(state.intensity[n]..",") end
  io.write("}, rotation={")
  for n=1,4 do io.write(state.rotation[n]..",") end
  io.write("} }\n")
  io.close(f)
end)

mod.hook.register("script_pre_init", "my init hacks", function()
  for n=1,4 do
    grid.vports[n]:intensity(state.intensity[n])
    grid.vports[n]:rotatoin(state.rotation[n])
  end
end)


local i = 1

local m = {}

m.key = function(n, z)
  if n == 2 and z == 1 then
    -- return to the mod selection menu
    mod.menu.exit()
  elseif n==3 and z==1 then
    state.rotation[i] = (state.rotation[i]+1)%4
    grid.vports[i]:rotation(state.rotation[i])
    mod.menu.redraw()
  end
end

m.enc = function(n, d)
  if n == 2 then i = util.clamp(i+d,1,4)
  elseif n == 3 then
    state.intensity[i] = util.clamp(state.intensity[i]+d,0,15)
    grid.vports[i]:intensity(state.intensity[i]) 
  end
  mod.menu.redraw()
end

m.redraw = function()
  screen.clear()
  screen.move(0,35)
  screen.text("GRID")
  screen.move(0,50)
  screen.text("intensity")
  screen.move(0,60)
  screen.text("rotation")
  screen.move(50,35)
  screen.text(i)
  screen.move(50,50)
  screen.text(state.intensity[i])
  screen.move(50,60)
  screen.text(state.rotation[i])
  screen.update()
end

m.init = function() end -- on menu entry, ie, if you wanted to start timers
m.deinit = function() end -- on menu exit

-- register the mod menu

mod.menu.register(mod.this_name, m)

local api = {}

api.get_state = function()
  return state
end

return api
