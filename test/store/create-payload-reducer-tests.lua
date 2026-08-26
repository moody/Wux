--- @diagnostic disable: param-type-mismatch

--- @type Wux
local Wux = require("test/wux")

-- Test Wux:CreatePayloadReducer() - defaultState is used when state is nil.
do
  local reducer = Wux:CreatePayloadReducer("SET_VALUE", 0)
  assert(reducer(nil, { type = "SOME_OTHER_ACTION" }) == 0)
end

-- Test Wux:CreatePayloadReducer() - existing state is preserved when the
-- action type doesn't match, even if it differs from defaultState.
do
  local reducer = Wux:CreatePayloadReducer("SET_VALUE", 0)
  assert(reducer(1, { type = "SOME_OTHER_ACTION" }) == 1)
end

-- Test Wux:CreatePayloadReducer() - state becomes action.payload when the
-- action type matches.
do
  local reducer = Wux:CreatePayloadReducer("SET_VALUE", 0)
  assert(reducer(0, { type = "SET_VALUE", payload = 1 }) == 1)
end

-- Test Wux:CreatePayloadReducer() - a table payload is used as-is, not
-- copied, so it becomes the stored state by reference.
do
  local reducer = Wux:CreatePayloadReducer("SET_VALUE", {})
  local payload = { count = 1 }
  local newState = reducer(nil, { type = "SET_VALUE", payload = payload })
  assert(newState == payload)

  payload.count = 999
  assert(newState.count == 999)
end

-- Test Wux:CreatePayloadReducer() - defaultState is not used when an
-- initialState already provides a value for this slice.
do
  local reducer = Wux:CreatePayloadReducer("SET_VALUE", 0)
  local rootReducer = Wux:CombineReducers({ value = reducer })
  local Store = Wux:CreateStore(rootReducer, { value = 5 })
  assert(Store:GetState().value == 5)
end

-- Test Wux:CreatePayloadReducer() - the produced reducer responds to a
-- matching dispatch through a real store.
do
  local reducer = Wux:CreatePayloadReducer("SET_VALUE", 0)
  local rootReducer = Wux:CombineReducers({ value = reducer })
  local Store = Wux:CreateStore(rootReducer, { value = 5 })
  Store:Dispatch({ type = "SET_VALUE", payload = 10 })
  assert(Store:GetState().value == 10)
end

print("All assertions passed.")
