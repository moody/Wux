--- @type Wux
local Wux = require("test/wux")

-- Test Wux:ForEach().
do
  local arr = { 4, 22, 10, 99, 2, 60, 41, 23 }
  local count = 0

  Wux:ForEach(arr, function(value, i)
    assert(value == arr[i])
    count = count + 1
  end)

  assert(count == #arr)
end

-- Test Wux:ForEach() - empty array never invokes the callback.
do
  local called = false
  Wux:ForEach({}, function() called = true end)
  assert(called == false)
end

-- Test Wux:Map() - multiply by 2.
do
  local arr = { 1, 2, 3, 4, 5 }
  local doubled = Wux:Map(arr, function(v) return v * 2 end)
  assert(doubled ~= arr)
  assert(#doubled == #arr)
  assert(doubled[1] == 2)
  assert(doubled[2] == 4)
  assert(doubled[3] == 6)
  assert(doubled[4] == 8)
  assert(doubled[5] == 10)
end

-- Test Wux:Map() - empty array returns a new, empty array.
do
  local arr = {}
  local mapped = Wux:Map(arr, function(v) return v end)
  assert(mapped ~= arr)
  assert(#mapped == 0)
end

-- Test Wux:Filter() - divisible by 2.
do
  local arr = { 0, 5, 22, 61, 77, 78 }
  local filtered = Wux:Filter(arr, function(v) return v % 2 == 0 end)
  assert(filtered ~= arr)
  assert(#filtered == 3)
  assert(filtered[1] == 0)
  assert(filtered[2] == 22)
  assert(filtered[3] == 78)
end

-- Test Wux:Filter() - no matches returns a new, empty array.
do
  local arr = { 1, 3, 5 }
  local filtered = Wux:Filter(arr, function(v) return v % 2 == 0 end)
  assert(filtered ~= arr)
  assert(#filtered == 0)
end

-- Test Wux:Reduce() - sum, no initial value (defaults to first element).
do
  local arr = { 1, 2, 3, 4, 5 }
  local sum = Wux:Reduce(arr, function(acc, v) return acc + v end)
  assert(sum == 15)
end

-- Test Wux:Reduce() - maximum value, with initial value.
do
  local arr = { 5, 23, 66, -256, 17 }
  local max = Wux:Reduce(arr, function(acc, v) return math.max(acc, v) end, 0)
  assert(max == 66)
end

-- Test Wux:Reduce() - single-element array, no initial value, callback never invoked.
do
  local arr = { 42 }
  local called = false
  local result = Wux:Reduce(arr, function(acc, v)
    called = true
    return acc + v
  end)
  assert(result == 42)
  assert(called == false)
end

-- Test Wux:Reduce() - empty array with an initial value returns the initial value.
do
  local result = Wux:Reduce({}, function(acc, v) return acc + v end, 99)
  assert(result == 99)
end

-- Test Wux:Reduce() - callback receives the correct index.
do
  local arr = { "a", "b", "c" }
  Wux:Reduce(arr, function(acc, v, i)
    assert(arr[i] == v)
    return acc
  end, true)
end
