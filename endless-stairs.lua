-- endless-stairs
-- a shepard tone generator
-- v0.0.1 @midouest
--
-- E2 = change param id
-- E3 = change param value

engine.name = "Shepard"

local MusicUtil = require 'musicutil'

local Shepard = include('lib/shepard')
local Parameters = include('lib/parameters')
local UI = include('lib/ui')

local clock_id

local pattern = {6, 1, -6, 1, 6, 1, -6, 1, 6, 1, -6, 1, 6, 1, -6, 7, -6, 7, -6, 7, -6, 7, -6, 1}
local step = 1
local edit_step = 1
local current_pitch = 60

local current_voices = {}
local current_param = 4

local ui_metro

function init()
  crow.ii.pullup(true)
  crow.ii.jf.mode(1)

  Parameters.init()

  params:set_action('num_voices', function(val) voices_off(val, 40) end)
  params:set_action('drone', function(val) engine.set_drone(val - 1) end)
  params:set_action('decay', function(val) engine.set_decay(val / 1000) end)

  ui_metro = metro.init(function() redraw() end, 1/15, -1)
  ui_metro:start()

  restart()
end

function cleanup()
  all_notes_off()
  crow.ii.jf.mode(0)
end

function restart()
  all_notes_off()
  start_clock()
end

function start_clock()
  if clock_id ~= nil then
    clock.cancel(clock_id)
  end
  clock_id = clock.run(run)
end

function run()
  while true do
    tick()

    -- if params:get('gliss') == 1 then
    --   current_pitch = current_pitch + pattern[step]
    --   step = step + 1
    --   if step > #pattern then
    --     step = 1
    --   end
    -- else
    local pitch_interval = params:get('pitch_interval') / 100
    current_pitch = current_pitch + pitch_interval
    -- end

    current_pitch = wrap_pitch(current_pitch)
    local time_interval = params:get('time_interval')
    clock.sleep(time_interval / 1000)
  end
end

function tick()
  local pitch_min = params:get('pitch_min')
  local pitch_max = params:get('pitch_max')
  local num_voices = params:get('num_voices')
  local voice_spread = params:get('voice_spread')
  local voice_detune = params:get('voice_detune') / 100

  local spread = voice_spread + voice_detune

  current_voices = {}

  local voices = Shepard.gen_voices(pitch_min, pitch_max, num_voices, spread, current_pitch)
  for i, pitch in ipairs(voices) do
    local width = (pitch_max - pitch_min) / 2
    local peak = pitch_min + width

    local level
    local amp_curve = params:get('amp_curve')
    if amp_curve == 1 then
      level = Shepard.lin_amp(pitch_min, pitch_max, pitch)
    elseif amp_curve == 2 then
      level = Shepard.cos_amp(pitch_min, pitch_max, pitch)
    else
      level = Shepard.gauss_amp(pitch_min, pitch_max, params:get('gaussian_width'), pitch)
    end

    current_voices[pitch] = level

    if params:get('engine_enabled') == 2 then
      local freq = MusicUtil.note_num_to_freq(pitch)
      engine.play_voice(i, freq, level / num_voices)
    end

    if params:get('jf_enabled') == 2 and i <= 6 then
      local jf_n = pitch / 12 - 5
      local jf_l = level * 10
      crow.ii.jf.play_voice(i, jf_n, jf_l)
    end
  end
end

function wrap_pitch(pitch)
  local pitch_min = params:get('pitch_min')
  local pitch_max = params:get('pitch_max')
  local pitch_range = pitch_max - pitch_min
  return (pitch - pitch_min) % pitch_range + pitch_min
end

function voices_off(start_index, end_index)
  for i = start_index, end_index do
    engine.voice_off(i)
    crow.ii.jf.play_voice(i, 0, 0)
  end
end

function all_notes_off()
  engine.all_notes_off()
  crow.ii.jf.play_voice(0, 0, 0)
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
    current_param = (current_param + d - 1) % #Parameters.ids + 1
  elseif n == 3 then
    local param_id = Parameters.ids[current_param]
    params:delta(param_id, d)
  end
  -- end
end

function redraw()
  screen.clear()

  -- if params:get('gliss') == 1 then
  --   UI.redraw_sequencer(pattern, step, edit_step)
  -- else
  screen.level(15)
  local param_id = Parameters.ids[current_param]

  screen.move(0, 8)
  screen.text(param_id)
  screen.stroke()

  screen.move(0, 16)
  screen.text(params:string(param_id))
  screen.stroke()

  UI.redraw_visualizer(current_voices)
  -- end

  screen.update()
end
