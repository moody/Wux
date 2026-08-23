--- @type Wux
local Wux = require("test/wux")

-- Test Wux:CreateActionCreator() - the returned creator builds a
-- WuxPayloadAction with the given actionType and value.
do
  local creator = Wux:CreateActionCreator("SET_VALUE")
  local action = creator(true)
  assert(action.type == "SET_VALUE")
  assert(action.payload == true)
end

-- Test Wux:CreateActionCreator() - calling the creator with no value
-- produces a bare WuxAction, with no payload key at all.
do
  local creator = Wux:CreateActionCreator("RESET")
  local action = creator()
  assert(action.type == "RESET")

  local keyCount = 0
  for _ in pairs(action) do keyCount = keyCount + 1 end
  assert(keyCount == 1)
end

-- Test Wux:CreateActionCreator() - two creators for different action types
-- don't interfere with each other.
do
  local setA = Wux:CreateActionCreator("SET_A")
  local setB = Wux:CreateActionCreator("SET_B")
  assert(setA(1).type == "SET_A")
  assert(setB(2).type == "SET_B")
end

-- Test Wux:CreateActionCreator() - dispatching a created action through a
-- real store reaches the matching reducer.
do
  local reducer = Wux:CreatePayloadReducer("SET_VALUE", 0)
  local rootReducer = Wux:CombineReducers({ value = reducer })
  local Store = Wux:CreateStore(rootReducer)

  local setValue = Wux:CreateActionCreator("SET_VALUE")
  Store:Dispatch(setValue(42))
  assert(Store:GetState().value == 42)
end

print("All assertions passed.")
