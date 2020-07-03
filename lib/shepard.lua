local Shepard = {}

-- generate the pitches for a step of a shepard tone
--
-- @param pitch_min minimum pitch of the tone (0 to 127)
-- @param pitch_max maximum pitch of the tone (0 to 127)
-- @param num_voices number of voices in the tone (1 to 6)
-- @param voice_spread voice spread in semitones (0 to 127)
-- @param center_pitch center pitch for the entire tone (0 to 127)
--
-- @return an array of voice pitches as MIDI notes
function Shepard.gen_voices(pitch_min, pitch_max, num_voices, voice_spread, center_pitch)
  local voices = {}

  local center_index = math.floor(num_voices / 2)
  local pitch_range = pitch_max - pitch_min

  for i = 1, num_voices do
    local voice_index = i - 1 - center_index
    voices[i] = (voice_index * voice_spread + center_pitch) % pitch_range + pitch_min
  end

  return voices
end

-- an amplitude function that rises linearly towards the peak pitch and descends
-- linearly away from the peak pitch
--
-- @param pitch_min minimum pitch in semitones
-- @param pitch_max maximum pitch in semitones
-- @param pitch pitch to transform in semitones
--
-- @return an amplitude for the given pitch
function Shepard.lin_amp(pitch_min, pitch_max, pitch)
  local peak = (pitch_max - pitch_min) / 2
  return 1 - math.abs(pitch - peak) / peak
end

-- a raised cosine amplitude function
--
-- @param pitch_min minimum pitch in semitones
-- @param pitch_max maximum pitch in semitones
-- @param pitch pitch to transform in semitones
--
-- @return an amplitude for the given pitch
function Shepard.cos_amp(pitch_min, pitch_max, pitch)
  local peak = (pitch_max - pitch_min) / 2
  return (1 + math.cos(math.pi * math.abs(pitch - peak) / peak)) / 2
end

return Shepard
