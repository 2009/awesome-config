---------------------------------------------------------------------
-- Default Layout
---------------------------------------------------------------------
-- This file specifies a layout of widgets and bars for the screen,
-- its only requirement is a `setup` method. See below.
---------------------------------------------------------------------

local wibox     = require( "wibox"     )
local beautiful = require( "beautiful" )
local gears     = require( "gears"     )
local shape 		= require( "gears.shape" )

local mpris     = require( "mpris"   )
local widgets   = require( "widgets" )
local cairo     = require( "lgi" ).cairo

local layout = {}

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

-- TODO can a change this to a cairo surface or gears.shape????
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
-- Local Widget Variables & Setup
---------------------------------------------------------------------

local time        = widgets.time.init()
local date        = widgets.date.init()
local storage     = widgets.storage.init()
local uptime      = widgets.uptime.init()
local network     = widgets.network.init()
local cpu         = widgets.cpu.init()
local system_load = widgets.system_load.init()
local temp        = widgets.temp.init()
local memory      = widgets.memory.init()
local battery     = widgets.battery.init()
local task        = widgets.task.init()
local countdown   = widgets.countdown.init()
local volume      = widgets.volume.init()

-- TODO mpris widgets with same init style
--local state       = mpris.stat.init()
--local now_playing = mpris.now_playing.init()
--local controls    = mpris.controls.init()

-- Local Widget Variablse
local time_widget      = widget_container( "TIME",   time )
local date_widget      = widget_container( "DATE",   date )
local storage_widget   = widget_container( "HDD",    storage.widget )
local uptime_widget    = widget_container( "UPTIME", uptime.widget )
local network_widget   = widget_container( "NET",    network.widget )
local cpu_widget       = widget_container( "CPU",    cpu.widget,
                                                     system_load.widget,
                                                     temp.widget )
local memory_widget    = widget_container( "MEM",    memory.widget )
local battery_widget   = widget_container( "BAT",    battery.widget )
local task_widget      = widget_container( "TW",     task.widget )
local countdown_widget = widget_container( "♥",      countdown.widget )
local scissors_widget  = widget_container( "✂",      nil)
local mpris_widget     = widget_container( nil,      mpris.state.widget,
                                                     mpris.now_playing.widget,
                                                     mpris.controls.widget,
                                                     volume.widget)


-- Attach notification widgets
storage.attach(storage_widget)

-- TODO Should use the same api for all widgets
widgets.task.attach(task_widget)
widgets.calendar.attach(date_widget)
widgets.scissors.attach(scissors_widget)

---------------------------------------------------------------------
-- Setup Widget Locations on Wibars per screen
---------------------------------------------------------------------
-- This method returns a table defining each wibar with args and a
-- declarative widget layout that gets passed to setup.
--
-- The current screen gets passed to this method to allow the use of
-- common widgets that are created per screen, these include:
--   * mytasklist
--   * mypromptbox
--   * mytaglist
--   * mylayoutbox
--
-- NOTE: For a more difinative list see rc.lua
layout.setup = function(screen)

  local wibars = {
    top = {
      args = { position = "top", height = beautiful.wibar_height },
      setup = {
        layout = wibox.layout.align.horizontal,
        -- Left widgets
        {
          layout = wibox.layout.fixed.horizontal,
          screen.mytaglist,
          screen.mylayoutbox,
          screen.mypromptbox,
        },
        -- Middle widgets
        nil,
        -- Right Widgets
        {
          layout = wibox.layout.fixed.horizontal,
          wibox.widget.systray(),
          scissors_widget,
          spr,
          mpris_widget,
          spr,
          countdown_widget,
          spr,
          battery_widget,
          spr,
          date_widget,
          spr,
          time_widget
        }
      }
    },
    bottom = {
      args = { position = "bottom", height = beautiful.wibar_height },
      setup = {
        layout = wibox.layout.align.horizontal,
        -- Left widgets
        {
          layout = wibox.layout.fixed.horizontal,
        },
        -- Middle widgets
        screen.mytasklist,
        -- Right Widgets
        {
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
    },

    --[[
    left = {
      args = { position = "left", width = beautiful.wibar_width },
      setup = {
       layout = wibox.layout.align.horizontal,
      }
    },

    right = {
      args = { position = "right", width = beautiful.wibar_width },
      setup = {
       layout = wibox.layout.align.horizontal,
      }
    },
    --]]

    bottom_border = {
      args = { position = "bottom", height = 1, bg = beautiful.fg_focus, x = 0, y = 33}
    }
  }

  return wibars
end

return layout
