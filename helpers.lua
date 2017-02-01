---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------
-- A bag of helper functions
---------------------------------------------------------------------

local awful = require( "awful" )

local helpers = {}

---------------------------------------------------------------------
-- Run once (have only a single command running)
---------------------------------------------------------------------

helpers.run_once = function(cmd)
  local findme = cmd
  local firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace-1)
  end
  awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))
end

return helpers
