local Parameters = {}

Parameters.ids = {
  'pitch_min',
  'pitch_max',
  'num_voices',
  'voice_spread',
  'voice_detune',
  'time_interval',
  'gliss',
  'pitch_interval',
  'amp_curve',
  'gaussian_width',
  'drone',
  'decay',
}

function Parameters.init()
  params:add_separator('general')

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
    max=40,
    step=1,
    default=6,
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
    id='voice_detune',
    name='voice detune',
    controlspec=controlspec.new(0, 100, 'lin', 1, 0, 'c')
  }

  params:add{
    type='control',
    id='time_interval',
    name='time interval',
    controlspec=controlspec.new(13, 1000, 'exp', 0, 133, 'ms')
  }

  params:add{
    type='option',
    id='gliss',
    name='glissando',
    options={'no', 'yes'},
    default=1,
  }

  params:add{
    type='control',
    id='pitch_interval',
    name='pitch interval',
    controlspec=controlspec.new(-100, 100, 'lin', 0, 100, 'c')
  }

  params:add{
    type='option',
    id='amp_curve',
    name='amplitude curve',
    options={'lin', 'cos', 'gauss'},
    default=3
  }

  params:add{
    type='number',
    id='gaussian_width',
    name='gaussian width',
    min=1,
    max=127,
    default=24,
  }

  -- params:add{
  --   type='option',
  --   id='split',
  --   name='split',
  --   options={'yes', 'no'},
  --   default=2
  -- }

  params:add_separator('engine')

  params:add{
    type='option',
    id='engine_enabled',
    name='enabled',
    options={'off', 'on'},
    default=2
  }

  params:add{
    type='option',
    id='drone',
    name='drone',
    options={'off', 'on'},
    default=1,
  }

  params:add{
    type='control',
    id='decay',
    name='decay',
    controlspec=controlspec.new(10, 1000, 'exp', 0, 500, 'ms'),
  }

  params:add_separator('just friends')

  params:add{
    type='option',
    id='jf_enabled',
    name='enabled',
    options={'off', 'on'},
    default=2
  }

  params:add_separator('pattern')

  params:add_group('data', 64 * 3 + 1)

  params:add{
    type='number',
    id='pattern_length',
    name='length',
    min=1,
    max=64,
    step=1,
    default=4,
  }

  for i = 1, 64 do
    params:add_separator(i)
    params:add{
      type='number',
      id='offset'..i,
      name='offset',
      min=-127,
      max=127,
      step=1,
      default=1,
    }
    params:add{
      type='option',
      id='rest'..i,
      name='rest',
      options={'off', 'on'},
      default=1,
    }
  end
end

return Parameters
