# Changelog

## [0.3.0] - 2026-08-16

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
