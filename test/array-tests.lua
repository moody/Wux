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

-- Test Wux:Map() - multiply by 2.
do
  local arr = { 1, 2, 3, 4, 5 }
  local doubled = Wux:Map(arr, function(v) return v * 2 end)
  assert(doubled ~= arr)
  assert(doubled[1], 2)
  assert(doubled[2], 4)
  assert(doubled[3], 6)
  assert(doubled[4], 8)
  assert(doubled[5], 10)
end

-- Test Wux:Filter() - divisible by 2.
do
  local arr = { 0, 5, 22, 61, 77, 78 }
  local filtered = Wux:Filter(arr, function(v) return v % 2 == 0 end)
  assert(#filtered == 3)
end

-- Test Wux:Reduce() - sum.
do
  local arr = { 1, 2, 3, 4, 5 }
  local sum = Wux:Reduce(arr, function(acc, v) return acc + v end)
  assert(sum == 15)
end

-- Test Wux:Reduce() - maximum value.
do
  local arr = { 5, 23, 66, -256, 17 }
  local max = Wux:Reduce(arr, function(acc, v) return math.max(acc, v) end, 0)
  assert(max == 66)
end

print("All tests passed!")
