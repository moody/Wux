# Wux

Wux is a state management library for World of Warcraft addons, heavily inspired by [Redux](https://redux.js.org/).

## How to Use

1. **Integration**: Copy the `src/wux.lua` file into your World of Warcraft addon project directory.

2. **TOC File Update**: Update your addon's TOC file to ensure that the Wux library is loaded along with your addon. Add the following line to your TOC file:

   ```txt
   src/wux.lua
   ```

   Ensure it is placed appropriately within the file, following the existing structure.

3. **Initialization**: Once Wux is loaded, it will be initialized as a key-value pair within your addon's Lua environment. You can access it by retrieving it from the addon's table, which is available through the varargs `...` provided to every Lua file:

   ```lua
   -- Retrieve the addon's name and table from varargs.
   local ADDON_NAME, Addon = ...

   -- Access the Wux library from the addon table.
   local Wux = Addon.Wux
   ```

   Make sure to replace `Addon` with the appropriate variable name representing your addon's table if it differs.
