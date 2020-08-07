local Object = {}

-- Base class for prototype inheritance
function Object:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

return Object
