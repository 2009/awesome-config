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
local naughty    = require( "naughty"     )
local beautiful = require( "beautiful" )
local countdown = require( "widgets.countdown" )

local widgets = {}

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/default/theme.lua")

---------------------------------------------------------------------
-- Time
---------------------------------------------------------------------

widgets.time = wibox.widget.textclock("%H:%M")

---------------------------------------------------------------------
-- Date
---------------------------------------------------------------------

widgets.date = wibox.widget.textclock("%d %b")

---------------------------------------------------------------------
-- Countdown
---------------------------------------------------------------------

widgets.countdown = countdown {
  date = { year = 2017, month = 2, day = 17, hour = 17, minute = 0 }
}

---------------------------------------------------------------------
-- Calendar
---------------------------------------------------------------------

widgets.calendar = lain.widgets.calendar

-- Init the calendar, attaching it to nothing as we want to bind the
-- signals ourselves
lain.widgets.calendar {
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

---------------------------------------------------------------------
-- Taskwarrior
---------------------------------------------------------------------

widgets.task = lain.widgets.abase {
  cmd = "task count",
  timeout = 1,
  settings = function()
    local count  = output and string.match(output, "[%d]+") or 0
    widget:set_text(count)
  end
}

widgets.task.attach = function(widget)
  lain.widgets.contrib.task.attach(widget, {
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
-- TODO test on laptop

widgets.battery = lain.widgets.bat {
  settings = function()
    local text = bat_now.perc
    if bat_now.ac_status == 1 then
      text = text .. " Plugged"
    end
    widget:set_markup(text)
  end
}

---------------------------------------------------------------------
-- CPU
---------------------------------------------------------------------

widgets.cpu = lain.widgets.cpu {
  settings = function()
    widget:set_markup(cpu_now.usage .. "%")
  end
}

---------------------------------------------------------------------
-- Temp
---------------------------------------------------------------------

widgets.temp = lain.widgets.temp {
  settings = function()
    coretemp_now = tonumber(coretemp_now)
    local text = coretemp_now and math.floor(coretemp_now) or "N/A"
    widget:set_markup(text .. "°C")
  end,
  tempfile = '/sys/class/hwmon/hwmon1/temp1_input',
  timeout = 1
}

---------------------------------------------------------------------
-- Memory
---------------------------------------------------------------------

widgets.memory = lain.widgets.mem {
  settings = function()
    widget:set_markup(mem_now.perc .. "%")
  end
}

---------------------------------------------------------------------
-- System Load
---------------------------------------------------------------------

-- System Load
-- TODO Does this show after restart?
widgets.system_load = lain.widgets.sysload {
  settings = function()
    widget:set_markup(load_15)
  end
}

---------------------------------------------------------------------
-- Uptime
---------------------------------------------------------------------

widgets.uptime = lain.widgets.abase {
  cmd = "cat /proc/uptime",
  timeout = 1,
  settings = function()

    -- Get system uptime
    local uptime  = output and string.match(output, "[%d]+") or 0
    local up      = math.floor(uptime)
    local days    = math.floor(up   / (3600 * 24))
    local hours   = math.floor((up  % (3600 * 24)) / 3600)
    local minutes = math.floor(((up % (3600 * 24)) % 3600) / 60)

    widget:set_markup(days .. "d " .. hours .. "h " .. minutes .. "m")
  end
}

---------------------------------------------------------------------
-- Network Upload/Download
---------------------------------------------------------------------

widgets.network = lain.widgets.net {
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

---------------------------------------------------------------------
-- HDD Storage Usage
---------------------------------------------------------------------

widgets.storage = lain.widgets.fs {
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
}

-- Attach mouse enter and leave signals
widgets.storage.attach = function (widget)
  widget:connect_signal('mouse::enter', function () widgets.storage.show(0, '--exclude-type=tmpfs') end)
  widget:connect_signal('mouse::leave', function () widgets.storage.hide() end)
end


---------------------------------------------------------------------
-- PulsAudio Volume Bar
---------------------------------------------------------------------
-- TODO Update the sink when pluggin in headphones or changing the default
-- TODO Do I want to display the notification?

local step = "5%"
local mixer = 'pavucontrol'

widgets.volume = lain.widgets.pulsebar {
  sink   = 0,
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
}

-- Mouse controls
widgets.volume.bar:buttons(awful.util.table.join(
	 awful.button({}, 1, function()
		 awful.util.spawn(mixer)
	 end),
	 awful.button({}, 2, function()
		 awful.util.spawn(string.format("pactl set-sink-volume %d 100%%", widgets.volume.sink))
		 widgets.volume.update()
		 widgets.volume.notify()
	 end),
	 awful.button({}, 3, function()
		 awful.util.spawn(string.format("pactl set-sink-mute %d toggle", widgets.volume.sink))
		 widgets.volume.update()
		 widgets.volume.notify()
	 end),
	 awful.button({}, 4, function()
		 awful.util.spawn(string.format("pactl set-sink-volume %d +%s", widgets.volume.sink, step))
		 widgets.volume.update()
		 widgets.volume.notify()
	 end),
	 awful.button({}, 5, function()
		 awful.util.spawn(string.format("pactl set-sink-volume %d -%s", widgets.volume.sink, step))
		 widgets.volume.update()
		 widgets.volume.notify()
	 end)
))

widgets.volume.widget = wibox.container.margin(widgets.volume.bar, 0, 0, 10, 10)

return widgets

