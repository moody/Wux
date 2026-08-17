--- @type Wux
local Wux = require("test/wux")

--- A minimal reducer for exercising the middleware chain in isolation.
local function counterReducer(state, action)
  state = state or 0
  if action.type == "INCREMENT" then
    return state + 1
  end
  return state
end

-- Test: with no middleware, Dispatch behaves exactly as before, and
-- returns the dispatched action.
do
  local Store = Wux:CreateStore(counterReducer)
  local result = Store:Dispatch({ type = "INCREMENT" })
  assert(result.type == "INCREMENT")
  assert(Store:GetState() == 1)
end

-- Test: a pass-through middleware doesn't change behavior.
do
  local function passThrough(store, next, action)
    return next(action)
  end

  local Store = Wux:CreateStore(counterReducer, nil, { passThrough })
  Store:Dispatch({ type = "INCREMENT" })
  assert(Store:GetState() == 1)
end

-- Test: middlewares run in declaration order.
do
  local order = {}

  local function makeRecorder(name)
    return function(store, next, action)
      table.insert(order, name)
      return next(action)
    end
  end

  local Store = Wux:CreateStore(counterReducer, nil, {
    makeRecorder("a"),
    makeRecorder("b"),
    makeRecorder("c")
  })

  -- CreateStore's own bootstrap dispatch already ran the middlewares once;
  -- reset so we're only measuring the dispatch below.
  order = {}

  Store:Dispatch({ type = "INCREMENT" })
  assert(#order == 3)
  assert(order[1] == "a")
  assert(order[2] == "b")
  assert(order[3] == "c")
end

-- Test: a middleware that never calls `next` stops the action from
-- reaching the reducer, and listeners are not notified. This also blocks
-- CreateStore's own bootstrap dispatch, so state is never initialized.
do
  local function blockAll(store, next, action)
    -- Deliberately never calls `next`.
  end

  local Store = Wux:CreateStore(counterReducer, nil, { blockAll })
  assert(Store:GetState() == nil)

  local calls = 0
  Store:Subscribe(function() calls = calls + 1 end)

  Store:Dispatch({ type = "INCREMENT" })
  assert(Store:GetState() == nil)
  assert(calls == 0)
end

-- Test: `store.getState()` reflects state before and after calling `next`.
do
  local seenBefore, seenAfter

  local function stateSpy(store, next, action)
    seenBefore = store.getState()
    local result = next(action)
    seenAfter = store.getState()
    return result
  end

  local Store = Wux:CreateStore(counterReducer, nil, { stateSpy })
  Store:Dispatch({ type = "INCREMENT" })

  assert(seenBefore == 0)
  assert(seenAfter == 1)
end

-- Test: `store.dispatch` re-enters the full chain -- including middleware
-- that ran before it -- rather than just the remaining `next` links.
do
  local order = {}

  local function recordingMiddleware(store, next, action)
    table.insert(order, action.type)
    return next(action)
  end

  local function redirectMiddleware(store, next, action)
    if action.type == "REDIRECT" then
      -- Dispatches a *new* action through the whole chain, rather than
      -- passing the original action along to `next`.
      return store.dispatch({ type = "INCREMENT" })
    end
    return next(action)
  end

  local Store = Wux:CreateStore(counterReducer, nil, {
    recordingMiddleware,
    redirectMiddleware
  })

  -- CreateStore's own bootstrap dispatch already ran the middlewares once;
  -- reset so we're only measuring the dispatch below.
  order = {}

  Store:Dispatch({ type = "REDIRECT" })

  -- recordingMiddleware runs before redirectMiddleware, so it should see
  -- both the original "REDIRECT" action and the re-dispatched "INCREMENT"
  -- action, in that order.
  assert(#order == 2)
  assert(order[1] == "REDIRECT")
  assert(order[2] == "INCREMENT")
  assert(Store:GetState() == 1)
end

-- Test: batched actions are still seen by middleware as a single action.
do
  local seenTypes = {}

  local function recordingMiddleware(store, next, action)
    table.insert(seenTypes, action.type)
    return next(action)
  end

  local Store = Wux:CreateStore(counterReducer, nil, { recordingMiddleware })

  -- CreateStore's own bootstrap dispatch already ran the middleware once;
  -- reset so we're only measuring the dispatch below.
  seenTypes = {}

  Store:Dispatch({
    type = Wux.ActionTypes.Batch,
    payload = {
      { type = "INCREMENT" },
      { type = "INCREMENT" },
      { type = "INCREMENT" }
    }
  })

  assert(#seenTypes == 1)
  assert(seenTypes[1] == Wux.ActionTypes.Batch)
  assert(Store:GetState() == 3)
end

print("All assertions passed.")
