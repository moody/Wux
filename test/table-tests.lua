--- @type Wux
local Wux = require("test/wux")

-- Test Wux:ShallowCopy().
do
  local original = {
    a = 1,
    b = false,
    c = {
      d = "e"
    }
  }

  local copy = Wux:ShallowCopy(original)
  assert(copy.a == original.a)
  assert(copy.b == original.b)
  assert(copy.c == original.c)
end

-- Test Wux:DeepCopy().
do
  local original = {
    a = {
      b = 123,
      c = {
        d = { 1, 2, 3 }
      }
    }
  }

  local copy = Wux:DeepCopy(original)
  assert(copy.a ~= original.a)
  assert(copy.a.b == original.a.b)
  assert(copy.a.c ~= original.a.c)
  assert(copy.a.c.d ~= original.a.c.d)
  assert(#copy.a.c.d == #original.a.c.d)
  for i = 1, #original.a.c.d do
    assert(copy.a.c.d[i] == original.a.c.d[i])
  end
end

-- Test Wux:Values().
do
  local original = {
    a = 1,
    b = 2,
    c = 3
  }

  local function contains(t, v)
    for k in pairs(t) do
      if t[k] == v then return true end
    end
    return false
  end

  local values = Wux:Values(original)
  assert(#values == 3)
  for index, value in pairs(values) do
    assert(contains(original, value))
  end
end

print("All tests passed!")
