--- @type Wux
local Wux = require("test/wux")

-- Test Wux:CreatePatchReducer() - defaultState is used when state is nil.
do
  local reducer = Wux:CreatePatchReducer("PATCH_VALUE", { a = 1, b = 2 })
  local state = reducer(nil, { type = "SOME_OTHER_ACTION" })
  assert(state.a == 1)
  assert(state.b == 2)
end

-- Test Wux:CreatePatchReducer() - existing state is preserved when the
-- action type doesn't match.
do
  local reducer = Wux:CreatePatchReducer("PATCH_VALUE", { a = 1, b = 2 })
  local existing = { a = 5, b = 6 }
  local state = reducer(existing, { type = "SOME_OTHER_ACTION" })
  assert(state.a == 5)
  assert(state.b == 6)
end

-- Test Wux:CreatePatchReducer() - fields in the payload overwrite matching
-- fields in state, but fields absent from the payload are left as-is.
do
  local reducer = Wux:CreatePatchReducer("PATCH_VALUE", { a = 1, b = 2 })
  local existing = { a = 1, b = 2 }
  local state = reducer(existing, { type = "PATCH_VALUE", payload = { a = 100 } })
  assert(state.a == 100)
  assert(state.b == 2)
end

-- Test Wux:CreatePatchReducer() - state is a new table, and mutating the
-- payload afterward doesn't affect the stored state.
do
  local reducer = Wux:CreatePatchReducer("PATCH_VALUE", { a = 1 })
  local existing = { a = 1 }
  local payload = { a = 2 }
  local state = reducer(existing, { type = "PATCH_VALUE", payload = payload })
  assert(state ~= existing)

  payload.a = 999
  assert(state.a == 2)
end

-- Test Wux:CreatePatchReducer() - the produced reducer patches correctly
-- through a real store.
do
  local reducer = Wux:CreatePatchReducer("PATCH_VALUE", { a = 1, b = 2 })
  local rootReducer = Wux:CombineReducers({ value = reducer })
  local Store = Wux:CreateStore(rootReducer)

  Store:Dispatch({ type = "PATCH_VALUE", payload = { a = 100 } })
  local state = Store:GetState()
  assert(state.value.a == 100)
  assert(state.value.b == 2)
end

print("All assertions passed.")
