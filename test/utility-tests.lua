--- @type Wux
local Wux = require("test/wux")

-- Test Wux:Coalesce().
do
  -- Positive.
  assert(Wux:Coalesce(1) == 1)
  assert(Wux:Coalesce(false) == false)
  assert(Wux:Coalesce(true) == true)
  assert(Wux:Coalesce("") == "")
  assert(Wux:Coalesce("One", "Two") == "One")
  assert(Wux:Coalesce(nil, false) == false)
  assert(Wux:Coalesce(false, true) == false)
  assert(Wux:Coalesce(nil, nil, true, nil, nil, 123) == true)

  -- Negative.
  assert(Wux:Coalesce() == nil)
  assert(Wux:Coalesce(nil) == nil)
  assert(Wux:Coalesce(nil, nil, nil) == nil)
end
