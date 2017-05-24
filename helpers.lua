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

---------------------------------------------------------------------
-- Factory Init wrapper
---------------------------------------------------------------------
-- Wraps a factory function and it's arguments in a table with an
-- init() method. Essentially giving you your own factory but with
-- the arguments and setup already provided.
-- This also stops widgets loading if they are not used.

helpers.finit = function(factory, fargs, oninit)
  local t = {}

  t.init = function()

    -- Call the factory with fargs to initialize a copy of it
    local instance = factory(fargs)

    -- Perform and setup that may be needed after the factory instance is created
    if oninit then
      oninit(instance)
    end

    -- Return the initialized instance
    return instance
  end

  return t
end

return helpers
