--- @type Wux
local Wux = require("test/wux")

-- Test Wux:ReadSavedVariables() - string mapping.
do
  _G.TestReadStringSV = { value = 1 }
  assert(Wux:ReadSavedVariables("TestReadStringSV").value == 1)

  local state = Wux:ReadSavedVariables("TestReadStringSVMissing")
  assert(type(state) == "table")
  assert(next(state) == nil)
end

-- Test Wux:ReadSavedVariables() - table mapping.
do
  _G.TestReadTableGlobalDB = { optionA = true }

  local state = Wux:ReadSavedVariables({ global = "TestReadTableGlobalDB", perchar = "TestReadTableCharDB" })
  assert(state.global.optionA == true)
  assert(type(state.perchar) == "table")
  assert(next(state.perchar) == nil)
end

-- Test Wux:WriteSavedVariables() - string mapping.
do
  _G.TestWriteStringSV = nil
  Wux:WriteSavedVariables("TestWriteStringSV", { value = 2 })
  assert(_G.TestWriteStringSV.value == 2)
end

-- Test Wux:WriteSavedVariables() - table mapping.
do
  _G.TestWriteTableGlobalDB = nil
  _G.TestWriteTableCharDB = nil
  Wux:WriteSavedVariables({ global = "TestWriteTableGlobalDB", perchar = "TestWriteTableCharDB" }, {
    global = { optionA = false },
    perchar = { optionB = true }
  })
  assert(_G.TestWriteTableGlobalDB.optionA == false)
  assert(_G.TestWriteTableCharDB.optionB == true)
end

-- Test Store:ConnectSavedVariables() - writes state immediately on connect,
-- then again on every subsequent change, and stops after unsubscribing.
do
  _G.TestConnectDB = nil

  local rootReducer = Wux:CombineReducers({
    count = function(state, action)
      state = Wux:Coalesce(state, 0)
      if action.type == "INCREMENT" then
        state = state + 1
      end
      return state
    end
  })

  local Store = Wux:CreateStore(rootReducer)
  local unsubscribe = Store:ConnectSavedVariables("TestConnectDB")
  assert(_G.TestConnectDB.count == 0)

  Store:Dispatch({ type = "INCREMENT" })
  assert(_G.TestConnectDB.count == 1)

  unsubscribe()
  Store:Dispatch({ type = "INCREMENT" })
  assert(_G.TestConnectDB.count == 1)
end

print("All assertions passed.")
