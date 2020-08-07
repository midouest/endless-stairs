local Parameters = include('lib/core/parameters')

local Pattern = {}

function Pattern.get_length()
  return params:get('pattern_length')
end

function Pattern.set_length(n)
  params:set('pattern_length', n)
end

function Pattern.get_step(i)
  local offset = params:get(self:get_offset_id(i))
  local rest = params:get(self:get_rest_id(i))
  return {
    offset=offset,
    is_rest=Parameters.option_to_bool(rest),
  }
end

function Pattern.set_offset(i, offset)
  params:set(self:get_offset_id(i), offset)
end

function Pattern.set_rest(i, is_rest)
  params:set(self:get_rest_id(i), Parameters.bool_to_option(is_rest))
end

function Pattern.get_offset_id(i)
  return 'offset'..i
end

function Pattern.get_rest_id(i)
  return 'rest'..i
end

return Pattern
