# Wux

Wux is a state management library for World of Warcraft addons, inspired by [Redux](https://redux.js.org/).

## Features

- Predictable state updates through a single store and pure reducer functions
- Reducer composition via `CombineReducers`
- Batched dispatches to limit redundant listener notifications
- Middleware for intercepting, transforming, or short-circuiting dispatched actions
- A small set of table and array utility methods (`Map`, `Filter`, `Reduce`, etc.)
- Fully annotated with [LuaCATS](https://luals.github.io/wiki/annotations/) for autocomplete and type-checking in editors
- No dependencies

## Installation

1. **Integration**: Copy the `src/wux.lua` file into your World of Warcraft addon project directory.

2. **TOC File Update**: Update your addon's TOC file to ensure that the Wux library is loaded along with your addon.

3. **Initialization**: Once Wux is loaded, it will be initialized as a key-value pair within your addon's Lua environment. You can access it by retrieving it from the addon's table, which is available through the varargs `...` provided to every Lua file:

   ```lua
   -- Retrieve the addon's name and table from varargs.
   local ADDON_NAME, Addon = ...

   -- Access the Wux library from the addon table.
   local Wux = Addon.Wux
   ```

## Usage

```lua
-- Define action types.
local ActionTypes = {
  TODO_ADDED = "todos/todoAdded"
}

--- @class Todo
--- @field id integer
--- @field text string
--- @field completed boolean

--- @class TodoAppState
--- @field todos Todo[]

--- Adds a new todo.
--- @type WuxActionCreator<string>
local function addTodo(text)
  return { type = ActionTypes.TODO_ADDED, payload = text }
end

--- @type WuxReducer<Todo[]>
local function todosReducer(state, action)
  state = state or {}
  if action.type == ActionTypes.TODO_ADDED then
    state = Wux:DeepCopy(state)
    table.insert(state, { id = #state + 1, text = action.payload, completed = false })
  end
  return state
end

-- Combine reducers and create the store.
--- @type WuxReducer<TodoAppState>
local rootReducer = Wux:CombineReducers({ todos = todosReducer })
local Store = Wux:CreateStore(rootReducer)

-- React to state changes.
--- @type WuxListener<TodoAppState>
local function onStateChanged(state)
  print(#state.todos .. " todo(s)")
end
Store:Subscribe(onStateChanged)

-- Dispatch an action.
Store:Dispatch(addTodo("Buy milk"))
```

## Annotation Tips

A couple of patterns get the most out of Wux's [LuaCATS](https://luals.github.io/wiki/annotations/) annotations in your own code:

- **Define listeners separately, not inline.** A function passed directly to `Store:Subscribe(function(state) ... end)` won't get `state` inferred. Define it as its own local with a `@type WuxListener<T>` first, then pass that instead, as in the example above.
- **Cast the result of `CombineReducers` once, where you build it.** It can't infer the shape it composes from its arguments, so annotate the combined reducer with the real state type at that point, rather than leaving every downstream use typed as `WuxReducer<table>`.

## API

### Store

- **`Wux:CreateStore(reducer, initialState?, middlewares?)`** — Creates a new store. Immediately dispatches `Wux.ActionTypes.InitializeState` to seed the initial state; this initial dispatch also passes through any given middleware.
- **`Store:GetState()`** — Returns the current state.
- **`Store:Dispatch(action)`** — Runs `action` through any middleware, then the store's reducer, then notifies listeners if the state changed. Returns the dispatched `action`.
- **`Store:Subscribe(listener)`** — Registers `listener` to be called on state changes. Returns an `unsubscribe` function.
- **`Wux:CombineReducers(reducers)`** — Combines a table of reducers, keyed by state slice, into a single root reducer.

Multiple actions can be dispatched together via `Wux.ActionTypes.Batch`, notifying listeners only once for the whole batch:

```lua
Store:Dispatch({
  type = Wux.ActionTypes.Batch,
  payload = {
    { type = "ACTION_1", payload = { ... } },
    { type = "ACTION_2", payload = { ... } }
  }
})
```

### Middleware

Middleware sits between a dispatched action and the store's reducer, and may inspect, transform, delay, or short-circuit it. Pass an ordered list as `CreateStore`'s third argument — the first middleware in the list sees each action first:

```lua
local function loggingMiddleware(store, next, action)
  print("dispatching:", action.type)
  local result = next(action) -- pass the action along; omit this call to block it
  print("state is now:", store.getState())
  return result
end

local Store = Wux:CreateStore(rootReducer, initialState, { loggingMiddleware })
```

`store.dispatch(action)` is also available to middleware that need to dispatch a new action — it re-enters the full chain from the start, rather than skipping ahead to the reducer.

### Utility Methods

- **`Wux:Coalesce(...)`** — Returns the first non-nil value from the given arguments.
- **`Wux:ShallowCopy(t)`** — Returns a shallow copy of a table.
- **`Wux:DeepCopy(t)`** — Returns a deep copy of a table.
- **`Wux:Values(t)`** — Returns an array of a table's values.
- **`Wux:ForEach(arr, callback)`** — Executes `callback` for each element in an array.
- **`Wux:Filter(arr, callback)`** — Returns a new array of elements for which `callback` returns `true`.
- **`Wux:Map(arr, callback)`** — Returns a new array of elements returned by `callback`.
- **`Wux:Reduce(arr, callback, initialValue?)`** — Reduces an array to a single accumulated value.

## Testing

Wux includes a test suite under `test/`, run against Lua 5.1:

```bash
./run-tests.sh
```

Tests run automatically via GitHub Actions on every push and pull request to `master`.
