# Wux

Wux is a state management library for World of Warcraft addons, inspired by [Redux](https://redux.js.org/).

## How to Use

1. **Integration**: Copy the `src/wux.lua` file into your World of Warcraft addon project directory.

2. **TOC File Update**: Update your addon's TOC file to ensure that the Wux library is loaded along with your addon.

3. **Initialization**: Once Wux is loaded, it will be initialized as a key-value pair within your addon's Lua environment. You can access it by retrieving it from the addon's table, which is available through the varargs `...` provided to every Lua file:

   ```lua
   -- Retrieve the addon's name and table from varargs.
   local ADDON_NAME, Addon = ...

   -- Access the Wux library from the addon table.
   local Wux = Addon.Wux
   ```
