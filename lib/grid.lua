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
function Grid.redraw_pattern_page(g, play_step, edit_step, is_editing_length)
  Grid.redraw_pattern_view(g, 1, 1, 16, 7, play_step, edit_step)
  Grid.redraw_toolbar_view(g, 8, edit_step, is_editing_length)
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
  local length = params:get('pattern_length')
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

local TOGGLE_ON_INTENSITY = 5
local TOGGLE_OFF_INTENSITY = 2

-- draw a toggle button
-- @param g device to draw on
-- @param x grid column of the button
-- @param y grid row of the button
-- @param state true if the button is active, otherwise false
function Grid.redraw_toggle(g, x, y, state)
  g:led(x, y, state and TOGGLE_ON_INTENSITY or TOGGLE_OFF_INTENSITY)
end

return Grid
