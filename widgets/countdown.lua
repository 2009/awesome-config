local helpers      = require("lain.helpers")
local textbox      = require("wibox.widget.textbox")
local setmetatable = setmetatable

local function worker(args)
  local countdown = {}
  local args      = args or {}
  local timeout   = args.timeout or 1
  local nostart   = args.nostart or false
  local stoppable = args.stoppable or false
  local date      = args.date or { year = 2017, month = 2, day = 17, hour = 12, minute = 5 }
  local settings  = args.settings or function()
    widget:set_text(days .. "d " .. hours .. "h " .. minutes .. "m " .. seconds .. "s")
  end

  countdown.widget = args.widget or textbox()

  function countdown.update()
    remaining = os.time(date) - os.time()

    days      = math.floor(remaining   / (3600 * 24))
    hours     = math.floor((remaining  % (3600 * 24)) / 3600)
    minutes   = math.floor(((remaining % (3600 * 24)) % 3600) / 60)
    seconds   = math.floor(((remaining % (3600 * 24)) % 3600) % 60)

    widget = countdown.widget
    settings()
  end

  countdown.timer = helpers.newtimer("countdown_timer", timeout, countdown.update, nostart, stoppable)

  return countdown
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
