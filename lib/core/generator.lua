local MusicUtil = require 'musicutil'

local Shepard = include('lib/core/shepard')
local Object = include('lib/core/object')

local Generator = Object:new{
  step=1,
  pitch=60,
  voices={},
  clock_id=nil
}

function Generator:start()
  self.clock_id = clock.run(function() self:run() end)
end

function Generator:stop()
  clock.cancel(self.clock_id)
  Generator.all_notes_off()
end

function Generator.voices_off(start_index, end_index)
  for i = start_index, end_index do
    engine.voice_off(i)
    crow.ii.jf.play_voice(i, 0, 0)
  end
end

function Generator.all_notes_off()
  engine.all_notes_off()
  crow.ii.jf.play_voice(0, 0, 0)
end

function Generator:run()
  while true do
    if params:get('gliss') == 1 then
      local is_rest = params:get('rest'..self.step)
      if is_rest == 1 then
        self:tick()
        local offset = params:get('offset'..self.step)
        self.pitch = self.pitch + offset
      end
      self.step = self.step + 1
      if self.step > params:get('pattern_end') then
        self.step = params:get('pattern_start')
      end
    else
      self:tick()
      local pitch_interval = params:get('pitch_interval') / 100
      self.pitch = self.pitch + pitch_interval
    end

    self.pitch = wrap_pitch(self.pitch)
    local time_interval = params:get('time_interval')
    clock.sleep(time_interval / 1000)
  end
end

function Generator:tick()
  local pitch_min = params:get('pitch_min')
  local pitch_max = params:get('pitch_max')
  local num_voices = params:get('num_voices')
  local voice_spread = params:get('voice_spread')
  local voice_detune = params:get('voice_detune') / 100

  local spread = voice_spread + voice_detune

  self.voices = {}

  local voices = Shepard.gen_voices(pitch_min, pitch_max, num_voices, spread, self.pitch)
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

    self.voices[pitch] = level

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

return Generator
