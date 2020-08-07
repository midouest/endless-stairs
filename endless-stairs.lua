-- endless-stairs
-- a shepard tone generator
-- v0.1.0 @midouest
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
local state = {
  edit_step = 1,
  param_id = 4,
  ui_metro = nil,
  begin_step=nil,
}

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
  -- crow.ii.pullup(false)
end

function enc(n, d)
  -- if params:get('gliss') == 1 then
  --   -- todo
  --   if n == 1 then
  --     local new_length = util.clamp(#pattern + d, 1, 64)
  --     if new_length > #pattern then
  --       for i = #pattern + 1, new_length do
  --         table.insert(pattern, 0)
  --       end
  --     elseif new_length < #pattern then
  --       for i = new_length + 1, #pattern do
  --         table.remove(pattern)
  --       end
  --     end
  --   elseif n == 2 then
  --     edit_step = (edit_step + d - 1) % #pattern + 1
  --   elseif n == 3 then
  --     local offset = pattern[edit_step]
  --     pattern[edit_step] = offset + d
  --   end
  -- else
  if n == 2 then
    state.param_id = (state.param_id + d - 1) % #Parameters.ids + 1
  elseif n == 3 then
    local param_id = Parameters.ids[state.param_id]
    params:delta(param_id, d)
  end
  -- end
end

function handle_grid_key(x, y, z)
  if (y == 7 or y == 8) and z == 1 then
    local offset = Grid.KEYBOARD_PATTERN[y - 6][x]
    if offset == nil then
      return
    end

    local prev_offset = params:get('offset'..state.edit_step)
    local prev_rest = params:get('rest'..state.edit_step)
    if offset == prev_offset then
      params:set('rest'..state.edit_step, 3 - prev_rest)
    else
      params:set('offset'..state.edit_step, offset)
      params:set('rest'..state.edit_step, 1)
    end
  elseif y >= 1 and y <= 4 then
    if z == 1 then
      local index = Grid.coord_to_index(x, y, 16)
      if begin_step ~= nil then
        local pattern_start = math.min(begin_step, index)
        local pattern_end = math.max(begin_step, index)

        params:set('pattern_start', pattern_start)
        params:set('pattern_end', pattern_end)
        begin_step = nil
      else
        begin_step = index
        if index <= 64 then
          state.edit_step = index
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
  local param_id = Parameters.ids[state.param_id]

  screen.move(0, 8)
  screen.text(param_id)
  screen.stroke()

  screen.move(0, 16)
  screen.text(params:string(param_id))
  screen.stroke()

  UI.redraw_visualizer(gen.voices)

  screen.update()

  g:all(0)
  Grid.redraw_pattern_page(g, gen.step, state.edit_step)
  g:refresh()
end
