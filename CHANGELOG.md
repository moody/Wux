# Changelog

## [0.3.1] - 2026-08-26

### Changed

- `Wux:Coalesce(...)`'s declared return type is now `T` instead of `T|nil`.

## [0.3.0] - 2026-08-25

### Added

- Middleware support via a new `middlewares` parameter to `Wux:CreateStore(reducer, initialState, middlewares)`:

  ```lua
  local function loggingMiddleware(store, next, action)
    print("dispatching:", action.type)
    return next(action)
  end

  Wux:CreateStore(reducer, initialState, { loggingMiddleware })
  ```

- `Store:Dispatch(action)` now returns the dispatched `action`
- `Wux:CreateActionCreator(actionType)` returns a function that builds a `WuxPayloadAction` with `actionType`, from whatever value it's called with
- `Wux:CreatePayloadReducer(actionType, defaultState)` returns a reducer that replaces its state with `action.payload` when `action.type` matches `actionType`, or with `defaultState` when state is `nil`
- `Wux:CreatePatchReducer(actionType, defaultState)` returns a reducer that shallow-merges `action.payload`'s fields into its state when `action.type` matches `actionType`, leaving fields not present in `payload` as-is
- `Wux:ReadSavedVariables(mapping)` / `Wux:WriteSavedVariables(mapping, state)` read/write state to SavedVariables globals, based on a string (one global for the whole state) or table (one global per state key) mapping
- `Store:ConnectSavedVariables(mapping)` writes state to its mapped SavedVariables globals immediately, then again on every change

### Changed

- Generic (LuaCATS) type annotations throughout (`Wux:Map`, `Wux:Filter`, `Wux:Reduce`, `Wux:CombineReducers`, `Wux:CreateStore`, etc.), so editors can infer real types instead of falling back to `any`/`table`

## [0.2.0] - 2024-09-14

### Added

- Table: `Wux.ActionTypes` for Wux specific action types
- Batch action support for `Store:Dispatch(action)`:

  ```lua
  Store:Dispatch({
    type = Wux.ActionTypes.Batch,
    payload = {
      { type = "ACTION_1", payload = { ... } },
      { type = "ACTION_2", payload = { ... } }
    }
  })
  ```

## [0.1.1] - 2024-02-18

### Changed

- Improved usage of EmmyLua annotations

## [0.1.0] - 2024-02-09

- Initial commit
