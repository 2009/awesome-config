---------------------------------------------------------------------
-- Widgets
---------------------------------------------------------------------
-- All the simple widgets + initialization is here
---------------------------------------------------------------------
-- TODO World time widget to show times in other countries

local lain      = require( "lain"      )
local markup    = require( "lain.util" ).markup
local wibox     = require( "wibox"     )
local awful     = require( "awful"     )
local naughty   = require( "naughty"   )
local beautiful = require( "beautiful" )
local countdown = require( "widgets.countdown" )
local finit     = require( "helpers" ).finit

local widgets = {}

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/default/theme.lua")

---------------------------------------------------------------------
-- Time
---------------------------------------------------------------------

widgets.time = finit(wibox.widget.textclock, "%H:%M")

---------------------------------------------------------------------
-- Date
---------------------------------------------------------------------

widgets.date = finit(wibox.widget.textclock, "%d %b")

---------------------------------------------------------------------
-- Countdown
---------------------------------------------------------------------

widgets.countdown = finit(countdown, {
    date = { year = 2017, month = 2, day = 17, hour = 17, minute = 0 }
  }
)

---------------------------------------------------------------------
-- Calendar
---------------------------------------------------------------------

widgets.calendar = {}

-- Init the calendar, attaching it to nothing as we want to bind the
-- signals ourselves
lain.widget.calendar {
  cal = "/usr/bin/cal --color=always",
  followtag = true,
  notification_preset = {
    fg = "#FFFFFF",
    -- TODO cleanup variables
    -- TODO attach show and hide to DATE label, write function
    bg = beautiful.bg_normal,
    position = "top_right",
    font = "Misc Tamsyn 12"
  }
}

-- Fix for lain calendar widget not working with attach if
-- attach_to does not contain the widget
widgets.calendar.attach = function (widget)
  table.insert(lain.widget.calendar.attach_to, widget)
  lain.widget.calendar.attach(widget)
end

---------------------------------------------------------------------
-- Scissors (copy from primary selection to clipboard selection)
---------------------------------------------------------------------

widgets.scissors = {}

widgets.scissors.attach = function(widget)
  widgets.scissors.widget = widget
  widget:buttons(awful.util.table.join(awful.button({}, 1, function() awful.spawn.with_shell("xsel | xsel -i -b") end)))
end

---------------------------------------------------------------------
-- Taskwarrior
---------------------------------------------------------------------

widgets.task = { widget = wibox.widget.textbox() }
widgets.task.init = function()
  awful.widget.watch("task count", 1, function(widget, output)
    local count  = output and string.match(output, "[%d]+") or 0
    widget:set_text(count)
  end, widgets.task.widget)

  return widgets.task
end

widgets.task.attach = function(widget)
  lain.widget.contrib.task.attach(widget, {
    followtag = true,
    notification_preset = {
      -- TODO cleanup
      fg = "#FFFFFF",
      bg = beautiful.bg_normal,
      position = "bottom_right",
      font = "Misc Tamsyn 12"
    }
  })
end

---------------------------------------------------------------------
-- Battery
---------------------------------------------------------------------

widgets.battery = finit(lain.widget.bat, {
    settings = function()
      local text = bat_now.perc
      if bat_now.ac_status == 1 then
        text = text .. " Plugged"
      end
      widget:set_markup(text)
    end
  }
)

---------------------------------------------------------------------
-- CPU
---------------------------------------------------------------------

widgets.cpu = finit(lain.widget.cpu, {
    settings = function()
      widget:set_markup(cpu_now.usage .. "%")
    end
  }
)

---------------------------------------------------------------------
-- Temp
---------------------------------------------------------------------

widgets.temp = finit(lain.widget.temp, {
    settings = function()
      coretemp_now = tonumber(coretemp_now)
      local text = coretemp_now and math.floor(coretemp_now) or "N/A"
      widget:set_markup(text .. "°C")
    end,
    tempfile = '/sys/class/hwmon/hwmon1/temp1_input',
    timeout = 1
  }
)

---------------------------------------------------------------------
-- Memory
---------------------------------------------------------------------

widgets.memory = finit(lain.widget.mem, {
    settings = function()
      widget:set_markup(mem_now.perc .. "%")
    end
  }
)

---------------------------------------------------------------------
-- System Load
---------------------------------------------------------------------

-- System Load
-- TODO Does this show after restart?
widgets.system_load = finit(lain.widget.sysload, {
    settings = function()
      widget:set_markup(load_15)
    end
  }
)

---------------------------------------------------------------------
-- Uptime
---------------------------------------------------------------------

widgets.uptime = { widget = wibox.widget.textbox() }
widgets.uptime.init = function()
  awful.widget.watch("cat /proc/uptime", 1, function(widget, output)

    -- Get system uptime
    local uptime  = output and string.match(output, "[%d]+") or 0
    local up      = math.floor(uptime)
    local days    = math.floor(up   / (3600 * 24))
    local hours   = math.floor((up  % (3600 * 24)) / 3600)
    local minutes = math.floor(((up % (3600 * 24)) % 3600) / 60)

    widget:set_markup(days .. "d " .. hours .. "h " .. minutes .. "m")
  end, widgets.uptime.widget)

  return widgets.uptime
end

---------------------------------------------------------------------
-- Network Upload/Download
---------------------------------------------------------------------

widgets.network = finit(lain.widget.net, {
    settings = function()
      timeout = 1,
      widget:set_markup(
      -- TODO cleanup variables
        markup(beautiful.widget_netdown, net_now.received)
        .. " "
        .. markup(beautiful.widget_netup, net_now.sent)
      )
    end
  }
)

---------------------------------------------------------------------
-- HDD Storage Usage
---------------------------------------------------------------------

widgets.storage = finit(lain.widget.fs, {
    followtag = true,
    showpopup = 'off',
    settings  = function()
      widget:set_markup(fs_now.used .. "%")
    end,
    notification_preset = {
      position = "bottom_right",
      -- TODO cleanup variables
      fg = beautiful.widget_fg
    }
  }, function(fs)
    -- Attach mouse enter and leave signals
    fs.attach = function (widget)
      widget:connect_signal('mouse::enter', function () fs.show(0, '--exclude-type=tmpfs') end)
      widget:connect_signal('mouse::leave', function () fs.hide() end)
    end
  end
)

---------------------------------------------------------------------
-- PulsAudio Volume Bar
---------------------------------------------------------------------
local step = "5%"
local mixer = 'pavucontrol'

widgets.volume = finit(lain.widget.pulsebar, {
    devicetype = "sink",
    ticks  = true,
    ticks_size = 3,
    width  = 80,
    followtag = true,
    colors = {
      -- TODO cleanup vars
      background = beautiful.widget_vol_bg,
      unmute     = beautiful.widget_vol_fg,
      mute       = beautiful.widget_vol_mute
    },
    notification_preset = {
      font      = "Misc Tamsyn",
      font_size = "12",
      bar_size  = 32
    }
  },
  function(widget)

    -- Mouse controls
    widget.bar:buttons(awful.util.table.join(
       awful.button({}, 1, function()
         widget.update()
         widget.notify()
         awful.util.spawn(mixer)
       end),
       awful.button({}, 2, function()
         awful.util.spawn(string.format("pactl set-" .. widget.devicetype .. "-volume %d 100%%", widget.device))
         widget.update()
         widget.notify()
       end),
       awful.button({}, 3, function()
         awful.util.spawn(string.format("pactl set-" .. widget.devicetype .. "-mute %d toggle", widget.device))
         widget.update()
         widget.notify()
       end),
       awful.button({}, 4, function()
         awful.util.spawn(string.format("pactl set-" .. widget.devicetype .. "-volume %d +%s", widget.device, step))
         widget.update()
         widget.notify()
       end),
       awful.button({}, 5, function()
         awful.util.spawn(string.format("pactl set-" .. widget.devicetype .. "-volume %d -%s", widget.device, step))
         widget.update()
         widget.notify()
       end)
    ))

    widget.widget = wibox.container.margin(widget.bar, 0, 0, 10, 10)
  end)

-- Add settings to the volume widget, needed by keys
widgets.volume.step = step

---------------------------------------------------------------------
-- PulsAudio Volume Bar (input volume)
---------------------------------------------------------------------
local step = "5%"
local mixer = 'pavucontrol'

widgets.volume_input = finit(lain.widget.pulsebar, {
    devicetype = "source",
    ticks  = true,
    ticks_size = 3,
    width  = 80,
    followtag = true,
    colors = {
      -- TODO cleanup vars
      background = beautiful.widget_vol_bg,
      unmute     = beautiful.widget_vol_fg,
      mute       = beautiful.widget_vol_mute
    },
    notifications = {
      font      = "Misc Tamsyn",
      font_size = "12",
      bar_size  = 32
    }
  },
  function(widget)

    -- Mouse controls
    widget.bar:buttons(awful.util.table.join(
       awful.button({}, 1, function()
         widget.update()
         widget.notify()
         awful.util.spawn(mixer)
       end),
       awful.button({}, 2, function()
         awful.util.spawn(string.format("pactl set-" .. widget.devicetype .. "-volume %d 100%%", widget.device))
         widget.update()
         widget.notify()
       end),
       awful.button({}, 3, function()
         awful.util.spawn(string.format("pactl set-" .. widget.devicetype .. "-mute %d toggle", widget.device))
         widget.update()
         widget.notify()
       end),
       awful.button({}, 4, function()
         awful.util.spawn(string.format("pactl set-" .. widget.devicetype .. "-volume %d +%s", widget.device, step))
         widget.update()
         widget.notify()
       end),
       awful.button({}, 5, function()
         awful.util.spawn(string.format("pactl set-" .. widget.devicetype .. "-volume %d -%s", widget.device, step))
         widget.update()
         widget.notify()
       end)
    ))

    widget.widget = wibox.container.margin(widget.bar, 0, 0, 10, 10)
  end)

-- Add settings to the volume widget, needed by keys
widgets.volume_input.step = step

return widgets

