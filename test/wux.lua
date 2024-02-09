local Addon = {}
local wux = assert(loadfile("src/wux.lua"))

wux("Wux", Addon)

return assert(Addon.Wux)
