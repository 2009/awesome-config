---------------------------------------------------------------------
-- Widgets
---------------------------------------------------------------------
-- All the simple widgets + initialization is here
---------------------------------------------------------------------

local lain      = require( "lain"      )
local markup    = require( "lain.util" ).markup
local wibox     = require( "wibox"     )
local awful     = require( "awful"     )
local naughty    = require( "naughty"     )
local beautiful = require( "beautiful" )

local module = {}

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/default/theme.lua")

---------------------------------------------------------------------
-- Time
---------------------------------------------------------------------

module.time = wibox.widget.textclock("%H:%M")

---------------------------------------------------------------------
-- Date
---------------------------------------------------------------------

module.date = wibox.widget.textclock("%d %b")

---------------------------------------------------------------------
-- Calendar
---------------------------------------------------------------------

local calendar = lain.widgets.calendar

-- Init the calendar, attaching it to nothing as we want to bind the
-- signals ourselves
lain.widgets.calendar.attach(nil, {
  followtag = true,
  notification_preset = {
    fg = "#FFFFFF",
    -- TODO cleanup variables
    -- TODO attach show and hide to DATE label, write function
    bg = beautiful.bg_normal,
    position = "top_right",
    font = "Misc Tamsyn 12"
  }
})

module.attach_calendar = function (widget)
  widget:connect_signal("mouse::enter", function () calendar.show(0) end)
  widget:connect_signal("mouse::leave", function () calendar.hide() end)
  widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () calendar.show(0, -1, calendar.scr_pos) end),
    awful.button({ }, 3, function () calendar.show(0,  1, calendar.scr_pos) end),
    awful.button({ }, 4, function () calendar.show(0, -1, calendar.scr_pos) end),
    awful.button({ }, 5, function () calendar.show(0,  1, calendar.scr_pos) end))
  )
end

---------------------------------------------------------------------
-- Battery
---------------------------------------------------------------------
-- TODO test on laptop

module.battery = lain.widgets.bat {
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

module.cpu = lain.widgets.cpu {
  settings = function()
    widget:set_markup(cpu_now.usage .. "%")
  end
}

---------------------------------------------------------------------
-- Temp
---------------------------------------------------------------------

module.temp = lain.widgets.temp {
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

module.memory = lain.widgets.mem {
  settings = function()
    widget:set_markup(mem_now.perc .. "%")
  end
}

---------------------------------------------------------------------
-- System Load
---------------------------------------------------------------------

-- System Load
-- TODO Does this show after restart?
module.system_load = lain.widgets.sysload {
  settings = function()
    widget:set_markup(load_15)
  end
}

---------------------------------------------------------------------
-- Uptime
---------------------------------------------------------------------

module.uptime = lain.widgets.abase {
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

module.network = lain.widgets.net {
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

module.storage = lain.widgets.fs {
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
module.attach_storage = function (widget)
  widget:connect_signal('mouse::enter', function () module.storage.show(0, '--exclude-type=tmpfs') end)
  widget:connect_signal('mouse::leave', function () module.storage.hide() end)
end


---------------------------------------------------------------------
-- PulsAudio Volume Bar
---------------------------------------------------------------------
-- TODO Update the sink when pluggin in headphones or changing the default
-- TODO Do I want to display the notification?

local step = "5%"
local mixer = 'pavucontrol'

module.volume = lain.widgets.pulsebar {
  sink   = 1,
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
module.volume.bar:buttons(awful.util.table.join(
	 awful.button({}, 1, function()
		 awful.util.spawn(mixer)
	 end),
	 awful.button({}, 2, function()
		 awful.util.spawn(string.format("pactl set-sink-volume %d 100%%", module.volume.sink))
		 module.volume.update()
		 module.volume.notify()
	 end),
	 awful.button({}, 3, function()
		 awful.util.spawn(string.format("pactl set-sink-mute %d toggle", module.volume.sink))
		 module.volume.update()
		 module.volume.notify()
	 end),
	 awful.button({}, 4, function()
		 awful.util.spawn(string.format("pactl set-sink-volume %d +%s", module.volume.sink, step))
		 module.volume.update()
		 module.volume.notify()
	 end),
	 awful.button({}, 5, function()
		 awful.util.spawn(string.format("pactl set-sink-volume %d -%s", module.volume.sink, step))
		 module.volume.update()
		 module.volume.notify()
	 end)
))

module.volume.widget = wibox.container.margin(module.volume.bar, 0, 0, 10, 10)

return module

