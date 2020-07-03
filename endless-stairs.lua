-- a shepard tone generator

-- notes
-- 6 voices
-- each voice goes from -3v to +3v chromatically
-- velocity peaks at 0v

local Shepard = include('lib/shepard')

local current_pitch=64
local clock_id

function init()
  crow.ii.pullup(true)
  crow.ii.jf.mode(1)

  params:add_separator('endless-stairs')

  params:add{
    type='number',
    id='pitch_min',
    name='minimum pitch',
    min=0,
    max=126,
    default=0,
    action=function(val)
      if val >= params:get('pitch_max') then
        params:set('pitch_max', val + 1, true)
      end
    end
  }

  params:add{
    type='number',
    id='pitch_max',
    name='maximum pitch',
    min=1,
    max=127,
    default=127,
    action=function(val)
      if val <= params:get('pitch_min') then
        params:set('pitch_min', val - 1, true)
      end
    end
  }

  params:add{
    type='number',
    id='num_voices',
    name='voices',
    min=1,
    max=6,
    default=6,
    action=function(val) restart() end
  }

  params:add{
    type='number',
    id='voice_spread',
    name='voice spread',
    min=0,
    max=127,
    default=24
  }

  params:add{
    type='control',
    id='time_interval',
    name='time interval',
    controlspec=controlspec.new(13, 1000, 'exp', 1, 500, 'ms'),
    action=function(val) start_clock() end
  }

  params:add{
    type='control',
    id='pitch_interval',
    name='pitch interval',
    controlspec=controlspec.new(-100, 100, 'lin', 1, 100, 'c')
  }


  local pitch_min = params:get('pitch_min')
  local pitch_max = params:get('pitch_max')

  restart()
end

function restart()
  all_notes_off()
  start_clock()
end

function start_clock()
  if clock_id ~= nil then
    clock.cancel(clock_id)
  end
  clock_id = clock.run(tick)
end

function tick()
  while true do
    local pitch_min = params:get('pitch_min')
    local pitch_max = params:get('pitch_max')
    local num_voices = params:get('num_voices')
    local voice_spread = params:get('voice_spread')
    local amp_fn = params:get('amp_fn')

    local voices = Shepard.gen_voices(pitch_min, pitch_max, num_voices, voice_spread, current_pitch)
    for i, pitch in ipairs(voices) do
      local level = Shepard.cos_amp(pitch_min, pitch_max, pitch)
      local jf_n = pitch / 12 - 5
      local jf_l = level * 10
      crow.ii.jf.play_voice(i, jf_n, jf_l)
    end

    current_pitch = wrap_pitch(current_pitch)
    local time_interval = params:get('time_interval')
    clock.sleep(time_interval / 1000)
  end
end

function wrap_pitch(pitch)
  local pitch_min = params:get('pitch_min')
  local pitch_max = params:get('pitch_max')
  local pitch_range = pitch_max - pitch_min
  local pitch_interval = params:get('pitch_interval') / 100
  return (pitch + pitch_interval - pitch_min) % pitch_range + pitch_min
end

function cleanup()
  all_notes_off()
  crow.ii.jf.mode(0)
end

function all_notes_off()
  crow.ii.jf.play_voice(0, 0, 0)
end

function redraw()

end
