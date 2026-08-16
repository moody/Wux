--- @type Wux
local Wux = require("test/wux")

-- A minimal reducer that increments its own state by 1, but only in
-- response to the given actionType.
local function makeCounterReducer(actionType)
  return function(state, action)
    state = state or 0
    if action.type == actionType then
      return state + 1
    end
    return state
  end
end

-- Test Wux:CombineReducers() - returns the same state reference when no
-- key's reducer changes its slice of state.
do
  local reducer = Wux:CombineReducers({
    a = makeCounterReducer("INCREMENT_A"),
    b = makeCounterReducer("INCREMENT_B")
  })

  local state = reducer(nil, { type = Wux.ActionTypes.InitializeState })
  local nextState = reducer(state, { type = "SOME_UNKNOWN_ACTION" })
  assert(nextState == state)
end

-- Test Wux:CombineReducers() - returns a new state table when a key
-- changes, while leaving sibling keys' values untouched.
do
  local reducer = Wux:CombineReducers({
    a = makeCounterReducer("INCREMENT_A"),
    b = makeCounterReducer("INCREMENT_B")
  })

  local state = reducer(nil, { type = Wux.ActionTypes.InitializeState })
  local nextState = reducer(state, { type = "INCREMENT_A" })
  assert(nextState ~= state)
  assert(nextState.a == state.a + 1)
  assert(nextState.b == state.b)
end

print("All assertions passed.")
