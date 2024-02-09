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
  if i == 3 then unsubscribe() end
  Store:Dispatch(TodoActions:AddTodo("Todo " .. i))
end

-- Assert listener was called.
assert(listenerCalls == 2)

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

print("All tests passed!")
