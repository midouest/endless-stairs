-- endless-stairs
-- a shepard tone generator
-- v1.0.1 @midouest
--
-- E2 = change param id
-- E3 = change param value

engine.name = "Shepard"

local Parameters = include('lib/core/parameters')
local Generator = include('lib/core/generator')
local UI = include('lib/views/ui')
local Grid = include('lib/views/grid')

local g = nil
local gen = nil

-- state
local edit_step = 1
local param_id = 4
local ui_metro = nil
local begin_step=nil
local double_tap_step=nil
local double_tap_time=nil

function init()
  crow.ii.pullup(true)
  crow.ii.jf.mode(1)

  Parameters.init()

  params:set_action('num_voices', function(val) Generator.voices_off(val, 40) end)
  params:set_action('drone', function(val) engine.set_drone(val - 1) end)
  params:set_action('decay', function(val) engine.set_decay(val / 1000) end)

  ui_metro = metro.init(function() redraw() end, 1/15, -1)
  ui_metro:start()

  g = grid.connect()
  g.key = handle_grid_key

  gen = Generator:new()
  gen:start()
end

function cleanup()
  gen:stop()
  crow.ii.jf.mode(0)
end

function enc(n, d)
  if n == 2 then
    param_id = (param_id + d - 1) % #Parameters.ids + 1
  elseif n == 3 then
    local id = Parameters.ids[param_id]
    params:delta(id, d)
  end
end

function handle_grid_key(x, y, z)
  if (y == 7 or y == 8) and z == 1 then
    local offset = Grid.KEYBOARD_PATTERN[y - 6][x]
    if offset == nil then
      return
    end

    local prev_offset = params:get('offset'..edit_step)
    local prev_rest = params:get('rest'..edit_step)
    if offset == prev_offset then
      params:set('rest'..edit_step, 3 - prev_rest)
    else
      params:set('offset'..edit_step, offset)
      params:set('rest'..edit_step, 1)
    end
  elseif y >= 1 and y <= 4 then
    if z == 1 then
      local index = Grid.coord_to_index(x, y, 16)
      local time = os.time()
      if double_tap_step ~= nil and double_tap_time ~= nil then
        local dt = os.difftime(time, double_tap_time)
        if dt < 1 and index == double_tap_step then
          params:set('pattern_start', index)
          params:set('pattern_end', index)
        end
        double_tap_time = nil
        double_tap_step = nil
      end

      if begin_step ~= nil then
        local pattern_start = math.min(begin_step, index)
        local pattern_end = math.max(begin_step, index)

        params:set('pattern_start', pattern_start)
        params:set('pattern_end', pattern_end)
        begin_step = nil
      else
        double_tap_step = index
        double_tap_time = time
        begin_step = index
        if index <= 64 then
          edit_step = index
        end
      end
    elseif z == 0 then
      begin_step = nil
    end
  end
end

function redraw()
  screen.clear()

  screen.level(15)
  local id = Parameters.ids[param_id]

  screen.move(0, 8)
  screen.text(id)
  screen.stroke()

  screen.move(0, 16)
  screen.text(params:string(id))
  screen.stroke()

  UI.redraw_visualizer(gen.voices)

  screen.update()

  g:all(0)
  Grid.redraw_pattern_page(g, gen.step, edit_step)
  g:refresh()
end
