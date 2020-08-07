local Grid = {}

Grid.BRIGHTNESS_PRIMARY = 15
Grid.BRIGHTNESS_SECONDARY = 10
Grid.BRIGHTNESS_TERTIARY = 6
Grid.BRIGHTNESS_INACTIVE = 3

-- convert a rectangle coordinate to an index into an array
-- @param x column of the coordinate
-- @param y row of the coordinate
-- @param width of the rectangle
function Grid.coord_to_index(x, y, w)
  return ((y - 1) * w) + x
end

-- render the pattern page
function Grid.redraw_pattern_page(g, play_step, edit_step)
  Grid.redraw_pattern_view(g, 1, 1, 16, 4, play_step, edit_step)

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
  local pattern_start = params:get('pattern_start')
  local pattern_end = params:get('pattern_end')

  for y = y1, y1 + h - 1 do
    for x = x1, x1 + w - 1 do
      local step = Grid.coord_to_index(x, y, w)
      local is_rest = params:get('rest'..step) == 2
      local brightness = 0
      if step == edit_step then
        brightness = Grid.BRIGHTNESS_PRIMARY
      elseif step == play_step then
        brightness = Grid.BRIGHTNESS_SECONDARY
      elseif step >= pattern_start and step <= pattern_end then
        brightness = is_rest and Grid.BRIGHTNESS_INACTIVE or Grid.BRIGHTNESS_TERTIARY
      end
      g:led(x, y, brightness)
    end
  end
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
        local brightness = Grid.BRIGHTNESS_INACTIVE
        if offset == active_offset then
          brightness = is_rest and Grid.BRIGHTNESS_TERTIARY or Grid.BRIGHTNESS_PRIMARY
        end
        g:led(left + x - 1, top + y - 1, brightness)
      end
    end
  end
end

return Grid
