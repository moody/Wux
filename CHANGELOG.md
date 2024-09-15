# Changelog

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
