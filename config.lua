---------------------------------------------------------------------
-- Widgets
---------------------------------------------------------------------
-- All the variable stuff

local config = {

  modkey = "Mod4",
  altkey = "Mod1",

  terminal     = "termite" or "xterm",
  term_argname = "--name %s",

  editor     = os.getenv("EDITOR") or "vi" or "nano",
  gui_editor = "gvim",

  browser    = "firefox",
  graphics   = "gimp",

}

return config
