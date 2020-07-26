-- endless-stairs
-- a shepard tone generator
-- v0.1.0 @midouest
--
-- E2 = change param id
-- E3 = change param value

engine.name = "Shepard"

local Parameters = include('lib/parameters')
local UI = include('lib/ui')
local Grid = include('lib/grid')
local Generator = include('lib/generator')

local g = nil
local gen = nil
local state = {
  edit_step = 1,
  is_editing_length = false,
  param_id = 4,
  ui_metro = nil
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
  if y == 8 then
    local offset = params:get('offset'..state.edit_step)
    if x == 1 and z == 1 then
      params:set('offset'..state.edit_step, -offset)
    elseif x == 15 and z == 1 then
      local is_rest = params:get('rest'..state.edit_step)
      params:set('rest'..state.edit_step, 3 - is_rest)
    elseif x == 16 then
      state.is_editing_length = z == 1
    elseif z == 1 then
      local sign = offset < 0 and -1 or 1
      params:set('offset'..state.edit_step, sign * (x - 2))
    end
  elseif state.is_editing_length and z == 1 and y <= 4 then
    local new_length = Grid.coord_to_index(x, y, 16)
    params:set('pattern_length', new_length)
  elseif z == 1 then
    local index = Grid.coord_to_index(x, y, 16)
    local length = params:get('pattern_length')
    if index <= length then
      state.edit_step = index
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
  Grid.redraw_pattern_page(g, gen.step, state.edit_step, state.is_editing_length)
  g:refresh()
end
