local TodoActions = require("test/store/actions/todo-actions")
local TodoReducer = require("test/store/reducers/todo-reducer")

--- @type Wux
local Wux = require("test/wux")

-- Create root reducer.
local rootReducer = Wux:CombineReducers({
  todos = TodoReducer
})

-- Create store.
local Store = Wux:CreateStore(rootReducer)

-- Validate state.
do
  local state = Store:GetState()
  assert(type(state) == "table")
  assert(type(state.todos) == "table")
  assert(#state.todos == 0)
end

-- Add listener.
local listenerCalls = 0
local unsubscribe = Store:Subscribe(function(state)
  listenerCalls = listenerCalls + 1
end)

-- Add todos.
for i = 1, 3 do
  Store:Dispatch(TodoActions:AddTodo("Todo " .. i))
end

-- Assert listener was called for each dispatched action.
assert(listenerCalls == 3)

-- Assert todos were added.
do
  local state = Store:GetState()
  for i = 1, 3 do
    local todo = state.todos[i]
    assert(todo.id == i)
    assert(todo.text == "Todo " .. i)
    assert(todo.completed == false)
  end
end

-- Add todos in a batch action.
Store:Dispatch({
  type = Wux.ActionTypes.Batch,
  payload = {
    TodoActions:AddTodo("Batch 1"),
    TodoActions:AddTodo("Batch 2"),
    TodoActions:AddTodo("Batch 3")
  }
})

-- Assert listener was called only once for the batch.
assert(listenerCalls == 4)

-- Assert batched todos were added.
do
  local state = Store:GetState()
  for i = 1, 3 do
    local todo = state.todos[i + 3]
    assert(todo.id == i + 3)
    assert(todo.text == "Batch " .. i)
    assert(todo.completed == false)
  end
end

-- Test unsubscribe.
unsubscribe()
Store:Dispatch({ type = "" })
assert(listenerCalls == 4)

-- Test Wux:CreateStore() - initialState is honored.
do
  local initial = { todos = { { id = 1, text = "Preset", completed = false } } }
  local PresetStore = Wux:CreateStore(rootReducer, initial)
  local state = PresetStore:GetState()
  assert(#state.todos == 1)
  assert(state.todos[1].text == "Preset")
end

-- Test Wux:CreateStore() - listeners are not notified when a dispatched action
-- does not change state.
do
  local NoopStore = Wux:CreateStore(rootReducer)
  local calls = 0
  NoopStore:Subscribe(function() calls = calls + 1 end)
  NoopStore:Dispatch({ type = "SOME_UNKNOWN_ACTION" })
  assert(calls == 0)
end

-- Test Wux:CreateStore() - multiple listeners are all notified, and unsubscribing
-- one does not affect the others.
do
  local MultiStore = Wux:CreateStore(rootReducer)

  local callsA, callsB = 0, 0
  local unsubscribeA = MultiStore:Subscribe(function() callsA = callsA + 1 end)
  MultiStore:Subscribe(function() callsB = callsB + 1 end)

  MultiStore:Dispatch(TodoActions:AddTodo("Multi 1"))
  assert(callsA == 1)
  assert(callsB == 1)

  unsubscribeA()
  MultiStore:Dispatch(TodoActions:AddTodo("Multi 2"))
  assert(callsA == 1)
  assert(callsB == 2)
end

print("All assertions passed.")
