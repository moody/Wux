# Wux

Wux is a state management library for World of Warcraft addons, inspired by [Redux](https://redux.js.org/).

## Features

- Predictable state updates through a single store and pure reducer functions
- Reducer composition via `CombineReducers`
- Batched dispatches to limit redundant listener notifications
- Middleware for intercepting, transforming, or short-circuiting dispatched actions
- A small set of table and array utility methods (`Map`, `Filter`, `Reduce`, etc.)
- Fully annotated with [LuaCATS](https://luals.github.io/wiki/annotations/) for autocomplete and inline documentation in editors
- No dependencies

## Installation

1. **Add the library**: Copy `src/wux.lua` into your addon, and add it to your TOC file so it loads with the rest of your addon.

2. **Access it**: Wux attaches itself to your addon's table, available through the varargs `...` in any file:

   ```lua
   local ADDON_NAME, Addon = ...
   local Wux = Addon.Wux
   ```

3. **Declare SavedVariables** (optional): List them in your TOC file, `## SavedVariables: MyAddonDB` and/or `## SavedVariablesPerCharacter: MyAddonCharDB`. See the end of Usage below for reading and persisting them with Wux.

## Usage

Wux's state lives in one table, built up by reducers rather than written to directly. That table's final shape is what you'd persist as SavedVariables, covered at the end of this section.

This is the root state we want to end up with:

```lua
{
  todos = {},
  ui = {
    filters = { onlyIncomplete = false },
  },
}
```

**Actions.** An action is a table with a `type`. `addTodo` is an action creator, a function that builds one instead of repeating the shape at every call site.

```lua
--- @param text string
--- @return WuxPayloadAction<string>
local function addTodo(text)
  return { type = "ADD_TODO", payload = text }
end
```

**Reducers.** A reducer is a plain function. Given its own slice of state and an action, it returns the next state for that slice, and it's the only place that slice is allowed to change. A reducer also owns its own default: `todosReducer` runs on the store's first dispatch, before `Dispatch` is ever called by hand, so `todos` always exists.

When a reducer's state is a table, mutating it in place is a problem: Wux compares state by table reference, not contents, so nothing looks like it changed and `Subscribe` never fires. A boolean, number, or string doesn't have this problem, since a new value is already a different value. `todosReducer` below only inserts a new item, never changes an existing one, so `Wux:ShallowCopy` is enough to get a new top-level table. `Wux:DeepCopy` is for when something nested needs to change too.

```lua
--- @class Todo
--- @field id integer
--- @field text string
--- @field completed boolean

--- @type WuxReducer<Todo[], WuxPayloadAction<string>>
local function todosReducer(state, action)
  state = Wux:Coalesce(state, {})
  if action.type == "ADD_TODO" then
    state = Wux:ShallowCopy(state)
    table.insert(state, { id = #state + 1, text = action.payload, completed = false })
  end
  return state
end
```

The same pattern covers a second slice, `ui.filters`. This action carries no payload, so its type stays a bare `WuxAction`.

```lua
--- @return WuxAction
local function toggleFilter()
  return { type = "TOGGLE_FILTER" }
end

--- @class TodoFilters
--- @field onlyIncomplete boolean

--- @type WuxReducer<TodoFilters, WuxAction>
local function filtersReducer(state, action)
  state = Wux:Coalesce(state, { onlyIncomplete = false })
  if action.type == "TOGGLE_FILTER" then
    state = { onlyIncomplete = not state.onlyIncomplete }
  end
  return state
end
```

**Composing reducers.** `CombineReducers` takes a table of reducers, keyed by where they live in the final state, and returns one reducer that runs all of them and assembles the results. That result is itself a reducer, so it can be combined again. This is how `filters` ends up nested under `ui`, and `ui` under the root.

```lua
--- @class TodoAppState
--- @field todos Todo[]
--- @field ui { filters: TodoFilters }

--- @type WuxReducer<TodoAppState, any>
local rootReducer = Wux:CombineReducers({
  todos = todosReducer,
  ui = Wux:CombineReducers({
    filters = filtersReducer
  })
})
```

**Creating the store.** `CreateStore` wires up the root reducer and immediately dispatches once to seed state. That's the dispatch `todosReducer` and `filtersReducer` handle above, with no `initialState` given here.

```lua
local Store = Wux:CreateStore(rootReducer)
```

**Reacting to changes.** `Subscribe` registers a callback that runs whenever state changes, so the rest of your addon can react without polling `GetState()` itself.

```lua
--- @type WuxListener<TodoAppState>
local function onStateChanged(state)
  print(#state.todos .. " todo(s)")
end
Store:Subscribe(onStateChanged)
```

**Dispatching.** Dispatching an action is the only way state changes. The store runs it through every reducer and replaces state with whatever they return.

```lua
Store:Dispatch(addTodo("Buy milk"))
Store:Dispatch(toggleFilter())
```

**Reading state.** `GetState()` returns the current state directly, any time you need it.

```lua
local state = Store:GetState()
```

`state` now holds:

```lua
{
  todos = {
    { id = 1, text = "Buy milk", completed = false },
  },
  ui = {
    filters = { onlyIncomplete = true },
  },
}
```

**Persisting to SavedVariables.** SavedVariables globals aren't populated until `ADDON_LOADED` fires for your addon, so in a real addon you'd create the store this way instead of the plain call above, wrapped in that event:

```lua
local mapping = "MyAddonDB"

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, loadedAddonName)
  if loadedAddonName ~= ADDON_NAME then return end
  self:UnregisterEvent("ADDON_LOADED")

  local Store = Wux:CreateStore(rootReducer, Wux:ReadSavedVariables(mapping))
  Store:ConnectSavedVariables(mapping)
end)
```

`mapping` can also be a table, `{ todos = "MyAddonDB", ui = "MyAddonCharDB" }`, mapping each root state key to its own global, matching however many `## SavedVariables` / `## SavedVariablesPerCharacter` entries your TOC declares. Everything else, `Subscribe`, `Dispatch`, `GetState`, works the same regardless of where `Store` came from.

Adding a new option later works the same way: give it a reducer (or a field inside an existing one) with its own default via `Wux:Coalesce`. That reducer still runs on `CreateStore`'s first dispatch even against an old SavedVariables file that's never seen the field before, so the default fills the gap instead of leaving it `nil`.

Every piece above does one job: an action describes what happened, a reducer says how that changes its own corner of state, and Dispatch is the single, traceable door all of it goes through.

## API

### Store

- **`Wux:CreateStore(reducer, initialState?, middlewares?)`** — Creates a new store. Immediately dispatches `Wux.ActionTypes.InitializeState` to seed the initial state; this initial dispatch also passes through any given middleware.
- **`Store:GetState()`** — Returns the current state.
- **`Store:Dispatch(action)`** — Runs `action` through any middleware, then the store's reducer, then notifies listeners if the state changed. Returns the dispatched `action`.
- **`Store:Subscribe(listener)`** — Registers `listener` to be called on state changes. Returns an `unsubscribe` function.
- **`Wux:CombineReducers(reducers)`** — Combines a table of reducers, keyed by state slice, into a single root reducer.
- **`Wux:CreatePayloadReducer(actionType, defaultState)`** — Returns a reducer that replaces its state with a shallow copy of `action.payload` when `action.type` matches `actionType`, or with `defaultState` when state is `nil`.
- **`Wux:ReadSavedVariables(mapping)`** — Reads SavedVariables globals into a table, based on `mapping` (a string for one global, or a table mapping state keys to globals). Use as `CreateStore`'s `initialState`.
- **`Wux:WriteSavedVariables(mapping, state)`** — Writes `state` to its mapped SavedVariables globals.
- **`Store:ConnectSavedVariables(mapping)`** — Writes state to its mapped SavedVariables globals immediately, then again on every change. Returns an `unsubscribe` function.

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

Pass an ordered list as `CreateStore`'s third argument. The first middleware in the list sees each action first, and may inspect, transform, delay, or short-circuit it by choosing whether to call `next`:

```lua
local function loggingMiddleware(store, next, action)
  print("Dispatching: " .. action.type)
  local result = next(action)
  if action.type == "ADD_TODO" then
    local state = store.getState()
    local numTodos = #state.todos
    print("Added new todo: " .. state.todos[numTodos].text)
    print("Total todos: " .. numTodos)
  end
  return result
end

local Store = Wux:CreateStore(rootReducer, nil, { loggingMiddleware })
```

`store.dispatch(action)` is also available to middleware that need to dispatch a new action. It re-enters the full chain from the start, rather than skipping ahead to the reducer.

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
