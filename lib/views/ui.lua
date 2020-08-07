local UI = {}

local SCREEN_WIDTH = 128
local SCREEN_HEIGHT = 64

-- draw a visualization of the shepard tone
-- @param voices map from pitch to amplitude
function UI.redraw_visualizer(voices)
  local pitch_min = params:get('pitch_min')
  local pitch_max = params:get('pitch_max')
  local num_voices = params:get('num_voices')
  local voice_spread = params:get('voice_spread')
  local voice_detune = params:get('voice_detune')
  local amp_curve = params:get('amp_curve')
  local gaussian_width = params:get('gaussian_width')

  screen.level(1)
  screen.line_width(1)
  for pitch, amp in pairs(voices) do
    local x = util.linlin(pitch_min, pitch_max, 0, SCREEN_WIDTH, pitch)
    local y = SCREEN_HEIGHT - (amp * SCREEN_HEIGHT)

    screen.move(x, y)
    screen.line(x, SCREEN_HEIGHT)
    screen.stroke()
  end
end

-- local STEP_WIDTH = 8
-- local ROW_HEIGHT = 8
-- local STEPS_PER_ROW = 8

-- draw the sequencer pattern
-- @param pattern a list of numbers
-- @param current_step the index of the current step into the pattern
-- function UI.redraw_sequencer(pattern, current_step, edit_step)
--   screen.line_width(2)
--   local total_offset = 0
--   for i, offset in ipairs(pattern) do
--     total_offset = total_offset + offset
--     local row = math.floor(i / (STEPS_PER_ROW + 1))
--     local column = (i - (row * STEPS_PER_ROW) - 1)
--     screen.move(column * STEP_WIDTH + 2, row * ROW_HEIGHT + ROW_HEIGHT)
--     if i == edit_step then
--       screen.level(15)
--     elseif i == current_step then
--       screen.level(2)
--     else
--       screen.level(1)
--     end
--     screen.text_center(offset)
--   end

--   screen.level(15)
--   screen.move(0, 56)
--   screen.text('edit: '..edit_step)
--   screen.move(0, 64)
--   screen.text('offset: '..total_offset)
-- end

return UI
