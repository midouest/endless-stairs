local Grid = {}

-- draw a rectangle of leds
-- @param g device to draw with
-- @param x1 initial x position of the rectangle
-- @param y1 initial y position of the rectangle
-- @param w width of the rectangle
-- @param h height of the rectangle
-- @param fn callback function to calculate intensity for a given led coord
function redraw_rect(g, x1, y1, w, h, fn)
  for y = y1, y1 + h - 1 do
    for x = x1, x1 + w - 1 do
      local intensity = fn(x, y)
      g:led(x, y, intensity)
    end
  end
end

-- convert a rectangle coordinate to an index into an array
-- @param x column of the coordinate
-- @param y row of the coordinate
-- @param width of the rectangle
function Grid.coord_to_index(x, y, w)
  return ((y - 1) * w) + x
end

-- render the pattern page
function Grid.redraw_pattern_page(g, play_step, edit_step)
  Grid.redraw_pattern_view(g, 1, 1, 16, 7, play_step, edit_step)

  local offset = params:get('offset'..edit_step)
  local is_rest = params:get('rest'..edit_step) == 2
  Grid.redraw_keyboard(g, 1, 7, offset, is_rest)
end

-- render the pattern view
-- @param g
-- @param x
-- @param y
-- @param w
-- @param h
-- @param play_step
-- @param edit_step
function Grid.redraw_pattern_view(g, x1, y1, w, h, play_step, edit_step)
  local length = params:get('pattern_end')
  redraw_rect(g, x1, y1, w, h, function(x, y)
    local step = Grid.coord_to_index(x, y, w)
    return step > length and 0 or step == edit_step and 15 or step == play_step and 5 or 2
  end)
end

-- render the pattern editor toolbar
-- @param g device to draw the toolbar on
-- @param y grid row of the toolbar (occupies full width)
-- @param step selected step to edit
-- @param is_editing_length true if the pattern length is being edited
function Grid.redraw_toolbar_view(g, y, edit_step, is_editing_length)
  local offset = params:get('offset'..edit_step)
  local is_negative = offset < 0
  local is_rest = params:get('rest'..edit_step) == 2

  -- sign button
  Grid.redraw_toggle(g, 1, y, is_negative)

  -- step offset slider
  local offset_column = math.abs(offset) + 2
  for x = 2, 14 do
    local is_offset = x == offset_column
    Grid.redraw_toggle(g, x, y, is_offset)
  end

  -- rest button
  Grid.redraw_toggle(g, 15, y, is_rest)

  -- length button
  Grid.redraw_toggle(g, 16, y, is_editing_length)
end

local TOGGLE_ON_INTENSITY = 6
local TOGGLE_OFF_INTENSITY = 3

-- draw a toggle button
-- @param g device to draw on
-- @param x grid column of the button
-- @param y grid row of the button
-- @param state true if the button is active, otherwise false
function Grid.redraw_toggle(g, x, y, state)
  g:led(x, y, state and TOGGLE_ON_INTENSITY or TOGGLE_OFF_INTENSITY)
end

Grid.KEYBOARD_PATTERN = {
  {nil, -11, -9, nil, -6, -4, -2, nil, 1, 3, nil, 6, 8, 10},
  {-12, -10, -8,  -7, -5, -3, -1,   0, 2, 4,   5, 7, 9, 11,  12},
}

-- draw a keyboard with a single active note
-- @param g grid device to draw to
-- @param left left position of the keyboard
-- @param top top position of the keyboard
-- @param active_offset offset of the selected step
-- @param is_rest true if the selected step has a rest
function Grid.redraw_keyboard(g, left, top, active_offset, is_rest)
  for y=1,#Grid.KEYBOARD_PATTERN do
    for x=1,#Grid.KEYBOARD_PATTERN[y] do
      local offset = Grid.KEYBOARD_PATTERN[y][x]
      if offset ~= nil then
        local brightness = 3
        if offset == active_offset then
          brightness = is_rest and 4 or 6
        end
        g:led(left + x - 1, top + y - 1, brightness)
      end
    end
  end
end

return Grid
