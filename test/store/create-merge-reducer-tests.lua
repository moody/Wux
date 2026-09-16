--- @type Wux
local Wux = require("test/wux")

-- Test Wux:CreateMergeReducer() - defaultState is used when state is nil.
do
  local reducer = Wux:CreateMergeReducer("MERGE_VALUE", { a = 1, b = 2 })
  local state = reducer(nil, { type = "SOME_OTHER_ACTION" })
  assert(state.a == 1)
  assert(state.b == 2)
end

-- Test Wux:CreateMergeReducer() - existing state is preserved when the
-- action type doesn't match.
do
  local reducer = Wux:CreateMergeReducer("MERGE_VALUE", { a = 1, b = 2 })
  local existing = { a = 5, b = 6 }
  local state = reducer(existing, { type = "SOME_OTHER_ACTION" })
  assert(state.a == 5)
  assert(state.b == 6)
end

-- Test Wux:CreateMergeReducer() - fields in the payload overwrite matching
-- fields in state, but fields absent from the payload are left as-is.
do
  local reducer = Wux:CreateMergeReducer("MERGE_VALUE", { a = 1, b = 2 })
  local existing = { a = 1, b = 2 }
  local state = reducer(existing, { type = "MERGE_VALUE", payload = { a = 100 } })
  assert(state.a == 100)
  assert(state.b == 2)
end

-- Test Wux:CreateMergeReducer() - a nested table field is merged, leaving
-- sibling keys within it untouched, unlike CreatePatchReducer replacing it wholesale.
do
  local reducer = Wux:CreateMergeReducer("MERGE_VALUE", { a = { x = 1, y = 2 } })
  local existing = { a = { x = 1, y = 2 } }
  local state = reducer(existing, { type = "MERGE_VALUE", payload = { a = { x = 100 } } })
  assert(state.a.x == 100)
  assert(state.a.y == 2)
end

-- Test Wux:CreateMergeReducer() - merging is recursive through multiple levels of nesting.
do
  local reducer = Wux:CreateMergeReducer("MERGE_VALUE", { a = { b = { c = 1, d = 2 } } })
  local existing = { a = { b = { c = 1, d = 2 } } }
  local state = reducer(existing, { type = "MERGE_VALUE", payload = { a = { b = { c = 100 } } } })
  assert(state.a.b.c == 100)
  assert(state.a.b.d == 2)
end

-- Test Wux:CreateMergeReducer() - a non-table payload field replaces a
-- table field in state outright, rather than attempting to merge into it.
do
  local reducer = Wux:CreateMergeReducer("MERGE_VALUE", { a = { x = 1 } })
  local existing = { a = { x = 1 } }
  local state = reducer(existing, { type = "MERGE_VALUE", payload = { a = 5 } })
  assert(state.a == 5)
end

-- Test Wux:CreateMergeReducer() - state is a new table, and mutating the
-- payload afterward doesn't affect the stored state.
do
  local reducer = Wux:CreateMergeReducer("MERGE_VALUE", { a = { x = 1 } })
  local existing = { a = { x = 1 } }
  local payload = { a = { x = 2 } }
  local state = reducer(existing, { type = "MERGE_VALUE", payload = payload })
  assert(state ~= existing)
  assert(state.a ~= existing.a)

  payload.a.x = 999
  assert(state.a.x == 2)
end

-- Test Wux:CreateMergeReducer() - the produced reducer merges correctly
-- through a real store.
do
  local reducer = Wux:CreateMergeReducer("MERGE_VALUE", { a = { x = 1, y = 2 } })
  local rootReducer = Wux:CombineReducers({ value = reducer })
  local Store = Wux:CreateStore(rootReducer)

  Store:Dispatch({ type = "MERGE_VALUE", payload = { a = { x = 100 } } })
  local state = Store:GetState()
  assert(state.value.a.x == 100)
  assert(state.value.a.y == 2)
end

print("All assertions passed.")
