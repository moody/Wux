local Wux = require("test/wux")
local TodoActions = require("test/store/actions/todo-actions")

-- ============================================================================
-- EmmyLua Annotations
-- ============================================================================

--- @class Todo
--- @field id integer
--- @field text string
--- @field completed boolean

-- ============================================================================
-- Local Functions
-- ============================================================================

local function nextTodoId(todos)
  local maxId = Wux:Reduce(todos, function(accumulator, todo)
    return math.max(accumulator, todo.id)
  end, 0)
  return maxId + 1
end

-- ============================================================================
-- TodoReducer
-- ============================================================================

--- @type WuxReducer<Todo[]>
local function TodoReducer(state, action)
  state = state or {}

  if action.type == TodoActions.Types.TODO_ADDED then
    state = Wux:DeepCopy(state)
    table.insert(state, {
      id = nextTodoId(state),
      text = action.payload,
      completed = false
    })
  end

  return state
end

return TodoReducer
