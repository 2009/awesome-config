---------------------------------------------------------------------
-- Config
---------------------------------------------------------------------
-- All the variable stuff
--
-- To set config locally for a each machine create a local.lua file
-- that returns your custom config table.
--
---------------------------------------------------------------------

local config = {

  modkey = "Mod4",
  altkey = "Mod1",

  terminal     = "termite" or "xterm",
  term_argname = "--name %s",

  editor     = os.getenv("EDITOR") or "vi" or "nano",
  gui_editor = "gvim",

  browser    = "firefox",
  graphics   = "gimp",

  enable_battery = false,
  enable_mpris   = true,

}

-- Override config with local machine config if available
pcall(function() config = require("local") or config end)

return config
