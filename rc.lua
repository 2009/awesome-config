--[[
                                
      My Awesome Config
                                
--]]

---------------------------------------------------------------------
-- TODO Hotkeys popup
-- TODO Cleanup styling widget labels and widgets
-- TODO Remove dependency on images for tag background
-- TODO Add missing corner layout image
-- TODO Update media icons to not have AA and have transparent backgrounds
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Required Libraries
---------------------------------------------------------------------

local gears         = require( "gears"           )
local awful         = require( "awful"           )
								    	require( "awful.autofocus" )
local wibox         = require( "wibox"           )
local beautiful     = require( "beautiful"           )
local naughty       = require( "naughty"             )
local lain          = require( "lain"                )
local markup        = require( "lain.util"           ).markup
local shape 		    = require( "gears.shape"         )
local async         = require( "awful.spawn"         ).easy_async
local hotkeys_popup = require( "awful.hotkeys_popup" ).widget

local mpris       = require( "mpris" )
local widgets     = require( "widgets" )
local widgets     = require( "widgets" )
local config      = require( "config" )
local keys        = require( "keys" )
local run_once    = require( "helpers" ).run_once

---------------------------------------------------------------------
-- Error Handling
---------------------------------------------------------------------

if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors
  })
end

do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    if in_error then return end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = tostring(err)
    })
    in_error = false
  end)
end

---------------------------------------------------------------------
-- Autostart Applications
---------------------------------------------------------------------
-- TODO autostart

--run_once("urxvtd")
--run_once("unclutter -root")

---------------------------------------------------------------------
-- Variable Definitions
---------------------------------------------------------------------

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/default/theme.lua")

-- bind config locally
local modkey           = config.modkey
local altkey           = config.altkey
local terminal         = config.terminal
local terminal_argname = config.terminal_argname

-- Tags
local tagnames = { " WEB ", " DEV ", " TERMINAL ", " FILES ", " OTHER " }

-- Enabled layouts
awful.layout.layouts = {
  awful.layout.suit.corner.nw,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.top
}

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------

-- Format all widget labels and spacing the same
-- Can pass in a text string which will get converted to a label widget
local function widget_container(label, ...)
	local args = { ... }
	local fg = beautiful.widget_label
  local margin_right = 10
	local widgets = {}

  -- Remove right padding if there is no label
  if not label then
    margin_right = 0
  end

	-- Convert label to a textbox
	if type(label) == "string" then
		label = wibox.widget.textbox(label)
	end

  local label_bg = wibox.container.background(label, nil, shape.rectangle)
  local label_margin = wibox.container.margin(label_bg, margin_right, 10, 0, 0, bg)
  label_bg.fg = fg

	-- Add the label to widgets
	table.insert(widgets, label_margin)

	for i, v in ipairs(args) do
		local widget = v
		local widget_margin = wibox.container.margin(widget, 0, 10, 0, 0, bg)
		
		-- Append to array
		table.insert(widgets, widget_margin)
	end

	-- Put the together in a layout
	return wibox.layout.fixed.horizontal(unpack(widgets))
end

---------------------------------------------------------------------
-- Separators
---------------------------------------------------------------------

local spr = wibox.widget.base.make_widget()
spr.draw = function(self, context, cr, width, height)
  -- Cairo Drawing!!!

  -- BG
  --cr:set_source(gears.color(beautiful.grey_darker))
  --cr:rectangle(0, 0, width, height)
  --cr:fill()

  -- Bar
  rwidth = 2
  rpos = (width - rwidth) / 2
  cr:set_source(gears.color(beautiful.grey))
  cr:rectangle(rpos, 0, rwidth, height)
  cr:fill()

  -- Circle
  cwidth = 3
  cr:set_source(gears.color(beautiful.blue))
  cr:arc(width/2, height/2, cwidth, 0, 2*math.pi)
  cr:close_path()
  cr:fill()
end
spr.fit = function(self, context, width, height)
  return 10, 10
end

---------------------------------------------------------------------
-- Taglist & Tasklist Mouse Controls
---------------------------------------------------------------------

local taglist_buttons = awful.util.table.join(
  awful.button({ }, 1, function(t) t:view_only() end),
  awful.button({ modkey }, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end),
  awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = awful.util.table.join(
	awful.button({ }, 1, function (c)
    if c == client.focus then
      c.minimized = true
    else
      -- Without this, the following
      -- :isvisible() makes no sense
      c.minimized = false
      if not c:isvisible() and c.first_tag then
        c.first_tag:view_only()
      end
      -- This will also un-minimize
      -- the client, if needed
      client.focus = c
      c:raise()
    end
  end),
	awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
	awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

---------------------------------------------------------------------
-- Wallpaper
---------------------------------------------------------------------

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

---------------------------------------------------------------------
-- Local Widget Variables & Setup
---------------------------------------------------------------------

-- Local Widget Variablse
local time_widget      = widget_container( "TIME",   widgets.time )
local date_widget      = widget_container( "DATE",   widgets.date )
local storage_widget   = widget_container( "HDD",    widgets.storage.widget )
local uptime_widget    = widget_container( "UPTIME", widgets.uptime.widget )
local network_widget   = widget_container( "NET",    widgets.network.widget )
local cpu_widget       = widget_container( "CPU",    widgets.cpu.widget,
                                                     widgets.system_load.widget,
                                                     widgets.temp.widget )
local memory_widget    = widget_container( "MEM",    widgets.memory.widget )
local battery_widget   = widget_container( "BAT",    widgets.battery.widget )
local task_widget      = widget_container( "TW",     widgets.task.widget )
local countdown_widget = widget_container( "♥",      widgets.countdown.widget )
local mpris_widget     = widget_container( nil,      mpris.state.widget,
                                                     mpris.now_playing.widget,
                                                     mpris.controls.widget,
                                                     widgets.volume.widget)

-- Attach notification widgets
widgets.calendar.attach(date_widget)
widgets.storage.attach(storage_widget)
widgets.task.attach(task_widget)

---------------------------------------------------------------------
-- Setup Wibox & Screens
---------------------------------------------------------------------

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)

    -- Wallpaper
    set_wallpaper(s)

    -- Tags
    awful.tag(tagnames, s, awful.layout.layouts[1])

    -- Quake console
    s.quakeconsole = lain.util.quake({ app = terminal, argname = terminal_argname })

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc(1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 32 })

		s.mywibox:setup {
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				s.mytaglist,
				s.mylayoutbox,
				s.mypromptbox,
			},
			nil, -- Middle widgets
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
        wibox.widget.systray(),
				spr,
        mpris_widget,
				spr,
        countdown_widget,
        --spr,
        --battery_widget,
        spr,
        date_widget,
        spr,
        time_widget
      }
    }

    -- Create the bottom wibox
    s.mybottomwibox = awful.wibar({ position = "bottom", screen = s, border_width = 0, height = 32 })
    s.borderwibox = awful.wibar({ position = "bottom", screen = s, height = 1, bg = beautiful.fg_focus, x = 0, y = 33})

    s.mybottomwibox:setup {
      layout = wibox.layout.align.horizontal,
      { -- Left widgets
        layout = wibox.layout.fixed.horizontal,
      },
      s.mytasklist, -- Middle widgets
      { -- Right widgets
        layout = wibox.layout.fixed.horizontal,
        spr,
        task_widget,
        spr,
				uptime_widget,
        spr,
				network_widget,
        spr,
				cpu_widget,
        spr,
				memory_widget,
        spr,
        storage_widget
      }
    }

end)

---------------------------------------------------------------------
-- Mouse Controls
---------------------------------------------------------------------

root.buttons(awful.util.table.join(
  awful.button({ }, 4, awful.tag.viewnext),
  awful.button({ }, 5, awful.tag.viewprev)
))

clientbuttons = awful.util.table.join(
  awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize))

---------------------------------------------------------------------
-- Keybindings
---------------------------------------------------------------------

-- Set global keys
root.keys(keys.global)

---------------------------------------------------------------------
-- Rules
---------------------------------------------------------------------

awful.rules.rules = {

  -- All clients will match this rule.
  { rule = { },
    properties = {
      border_width = beautiful.border_width,
      border= beautiful.border_normal,
      focus = awful.client.focus.filter,
      keys = keys.clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap+awful.placement.no_offscreen,
      size_hints_honor = false
    }
  },

  --[[ TODO Update rules
  { rule = { class = "URxvt" },
        properties = { opacity = 0.99 } },

  { rule = { class = "MPlayer" },
        properties = { floating = true } },

  { rule = { class = "Dwb" },
        properties = { tag = tags[1][1] } },

  { rule = { class = "Iron" },
        properties = { tag = tags[1][1] } },

  { rule = { instance = "plugin-container" },
        properties = { tag = tags[1][1] } },

  { rule = { class = "Gimp" },
        properties = { tag = tags[1][5] } },
  { rule = { class = "Gimp", role = "gimp-image-window" },
        properties = { maximized_horizontal = true,
                       maximized_vertical = true } },
  --]]

}

---------------------------------------------------------------------
-- Signals
---------------------------------------------------------------------

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  -- if not awesome.startup then awful.client.setslave(c) end

  if awesome.startup and
    not c.size_hints.user_position
    and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
  -- buttons for the titlebar
  local buttons = awful.util.table.join(
    awful.button({ }, 1, function()
      client.focus = c
      c:raise()
      awful.mouse.client.move(c)
    end),
    awful.button({ }, 3, function()
      client.focus = c
      c:raise()
      awful.mouse.client.resize(c)
    end))

  awful.titlebar(c) : setup {
    { -- Left
      awful.titlebar.widget.iconwidget(c),
      buttons = buttons,
      layout  = wibox.layout.fixed.horizontal
    },
    { -- Middle
      { -- Title
        align  = "center",
        widget = awful.titlebar.widget.titlewidget(c)
      },
      buttons = buttons,
      layout  = wibox.layout.flex.horizontal
    },
    { -- Right
      awful.titlebar.widget.floatingbutton (c),
      awful.titlebar.widget.maximizedbutton(c),
      awful.titlebar.widget.stickybutton   (c),
      awful.titlebar.widget.ontopbutton    (c),
      awful.titlebar.widget.closebutton    (c),
      layout = wibox.layout.fixed.horizontal()
    },
    layout = wibox.layout.align.horizontal
  }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
  if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    and awful.client.focus.filter(c) then
    client.focus = c
  end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
