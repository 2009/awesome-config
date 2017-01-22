--[[
                                
     Based off Holo config
     github.com/copycat-killer  
                                
--]]

-- {{{ Required libraries
local gears         = require("gears")
local awful         = require("awful")
								    	require("awful.autofocus")
local wibox         = require("wibox")

-- TODO CHECK
local escape_f      = require("awful.util").escape
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
local markup        = require("lain.util").markup
local shape 		    = require("gears.shape")
local async         = require("awful.spawn").easy_async
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart applications
local function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
	awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))
end

-- TODO autostart
--run_once("urxvtd")
--run_once("unclutter -root")
-- }}}

-- {{{ Variable definitions

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/default/theme.lua")

-- common
local modkey     = "Mod4"
local altkey     = "Mod1"
local terminal   = "termite" or "xterm"
local editor     = os.getenv("EDITOR") or "nano" or "vi"

-- user defined
local browser    = "firefox"
local gui_editor = "gvim"
local graphics   = "gimp"
local musicplr   = terminal .. " -e ncmpcpp "

-- Tags
local tagnames = { " WEB ", " DEV ", " TERMINAL ", " FILES ", " OTHER " }

-- Enabled layouts
awful.layout.layouts = {
  awful.layout.suit.corner.nw,
  --awful.layout.suit.corner.sw,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.top
}

-- quake terminal
-- TODO Can be used for anything, seems that termite is broken with this!!!
local quakeconsole = {}
for s in screen do
  quakeconsole[s] = lain.util.quake({ app = terminal })
end
-- }}}

-- {{{ Theme
local space  = "  "

-- Format all widget labels the same
local widget_label = function(label_text, color)
    return markup(color or beautiful.widget_label, label_text) .. space
end
-- }}}

-- {{{ Wibox

-- Clock
mytextclock = awful.widget.textclock(widget_label("TIME") .. "%H:%M" .. space)
clockwidget = wibox.widget.background()
clockwidget:set_widget(mytextclock)
clockwidget:set_bgimage(beautiful.widget_bg)

-- Calendar
mytextcalendar = awful.widget.textclock(space .. widget_label("DATE") .. "%d %b")
calendarwidget = wibox.widget.background()
calendarwidget:set_widget(mytextcalendar)
calendarwidget:set_bgimage(beautiful.widget_bg)
lain.widgets.calendar.attach(calendarwidget, {
    fg = beautiful.widget_fg, position = "top_right", followmouse = true
})

--[[ Mail IMAP check
-- commented because it needs to be set before use
mailwidget = lain.widgets.imap({
    timeout  = 180,
    server   = "server",
    mail     = "mail",
    password = "keyring get mail",
    settings = function()
        mail_notification_preset.fg = beautiful.widget_fg
        mail  = ""
        count = ""

        if mailcount > 0 then
            mail = "Mail "
            count = mailcount .. " "
        end

        widget:set_markup(markup(beautiful.widget_imap, mail) .. count)
    end
})
]]

-- Spotify
-- Requires playerctl installed
prev_icon = wibox.widget.imagebox()
prev_icon:set_image(beautiful.prev)
next_icon = wibox.widget.imagebox()
next_icon:set_image(beautiful.nex)
stop_icon = wibox.widget.imagebox()
stop_icon:set_image(beautiful.stop)
pause_icon = wibox.widget.imagebox()
pause_icon:set_image(beautiful.pause)
play_pause_icon = wibox.widget.imagebox()
play_pause_icon:set_image(beautiful.play)

mpriswidget = lain.widgets.abase({
    cmd = "playerctl status && playerctl metadata",
    timeout = 1,
    settings = function()
         mpris_now = {
             state        = "N/A",
             artist       = "N/A",
             title        = "N/A",
             art_url      = "N/A",
             album        = "N/A",
             album_artist = "N/A"
         }

         mpris_now.state = string.match(output, "Playing") or
                           string.match(output, "Paused")  or
                           "not_found"

         for k, v in string.gmatch(output, "'[^:]+:([^']+)':[%s]<%[?'([^']+)'%]?>") do
             if     k == "artUrl"      then mpris_now.art_url      = v
             elseif k == "artist"      then mpris_now.artist       = escape_f(v)
             elseif k == "title"       then mpris_now.title        = escape_f(v)
             elseif k == "album"       then mpris_now.album        = escape_f(v)
             elseif k == "albumArtist" then mpris_now.album_artist = escape_f(v)
             end
         end

        mpris_now.artist = mpris_now.artist:upper():gsub("&.-;", string.lower)
        mpris_now.title = mpris_now.title:upper():gsub("&.-;", string.lower)

        if mpris_now.state == "Playing" then
            widget:set_markup(
                space ..
                markup.font("Misc Tamsyn 8",
                    widget_label("[NOW PLAYING]")
                    .. markup(beautiful.widget_mpris_artist, mpris_now.artist)
                    .. " - " ..  mpris_now.title
                )
            )
            play_pause_icon:set_image(beautiful.pause)
        elseif mpris_now.state == "Paused" then
            widget:set_markup(
                space ..
                markup.font("Misc Tamsyn 8",
                    widget_label("[PAUSED]", beautiful.widget_mpris_status)
                    .. markup(beautiful.widget_mpris_artist, mpris_now.artist)
                    .. " - " ..  mpris_now.title
                 )
            )
            play_pause_icon:set_image(beautiful.play)
        else
            widget:set_markup("")
            play_pause_icon:set_image(beautiful.play)
        end
    end
})
musicwidget = wibox.widget.background()
musicwidget:set_widget(mpriswidget)
musicwidget:set_bgimage(beautiful.widget_bg)
-- TODO Fix this to open spotify
musicwidget:buttons(awful.util.table.join(awful.button({ }, 1,
function () awful.util.spawn_with_shell(musicplr) end)))
prev_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    async.request("playerctl previous", mpriswidget.update);
end)))
next_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    async.request("playerctl next", mpriswidget.update);
end)))
stop_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    play_pause_icon:set_image(beautiful.play)
    async.request("playerctl stop", mpriswidget.update);
end)))
play_pause_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    async.request("playerctl play-pause", mpriswidget.update);
end)))

-- Battery
batterywidget = lain.widgets.bat({
    settings = function()
        bat_header = space .. widget_label("BAT")
        bat_p      = bat_now.perc .. space
        if bat_now.ac_status == 1 then
            bat_p = bat_p .. "Plugged" .. space
        end
        widget:set_markup(markup(beautiful.widget_battery, bat_header) .. bat_p)
    end
})
batwidget = wibox.widget.background()
batwidget:set_widget(batterywidget)
batwidget:set_bgimage(beautiful.widget_bg)

-- PulseAudio volume bar
pulsebar = lain.widgets.pulsebar({
    sink   = 0,
    ticks  = true,
    step   = "5%",
    width  = 80,
    height = 10,
    colors = {
        background = beautiful.widget_vol_bg,
        unmute     = beautiful.widget_vol_fg,
        mute       = beautiful.widget_vol_mute
    },
    notifications = {
        font      = "Misc Tamsyn",
        font_size = "12",
        bar_size  = 32
    }
})
volmargin = wibox.layout.margin(pulsebar.bar, 0, 5, 80)
wibox.layout.margin.set_top(volmargin, 12)
wibox.layout.margin.set_bottom(volmargin, 12)
volumewidget = wibox.widget.background()
volumewidget:set_widget(volmargin)
volumewidget:set_bgimage(beautiful.widget_bg)

-- CPU
cpu_widget = lain.widgets.cpu({
    settings = function()
        widget:set_markup(
            space ..
            widget_label("CPU") .. cpu_now.usage .. "%"
        )
    end
})
cpuwidget = wibox.widget.background()
cpuwidget:set_widget(cpu_widget)
cpuwidget:set_bgimage(beautiful.widget_bg)

-- Coretemp
temp_widget = lain.widgets.temp({
    settings = function()
        widget:set_markup(math.floor(coretemp_now) .. "°C" .. space)
    end,
    tempfile = '/sys/class/hwmon/hwmon0/temp1_input',
    timeout = 1
})
tempwidget = wibox.widget.background()
tempwidget:set_widget(temp_widget)
tempwidget:set_bgimage(beautiful.widget_bg)

-- Memory
mem_widget = lain.widgets.mem({
    settings = function()
        widget:set_markup(
            space ..
            widget_label("MEM") .. mem_now.perc .. "%"
            .. space
        )
    end
})
memwidget = wibox.widget.background()
memwidget:set_widget(mem_widget)
memwidget:set_bgimage(beautiful.widget_bg)

-- System Load
sysload_widget = lain.widgets.sysload({
    settings = function()
        widget:set_markup(load_15)
    end
})
sysloadwidget = wibox.widget.background()
sysloadwidget:set_widget(sysload_widget)
sysloadwidget:set_bgimage(beautiful.widget_bg)

-- Uptime
uptime_widget = lain.widgets.abase({
    cmd = "cat /proc/uptime",
    timeout = 1,
    settings = function()

      -- Get system uptime
      local up = math.floor(string.match(output, "[%d]+"))
      local days    = math.floor(up   / (3600 * 24))
      local hours   = math.floor((up  % (3600 * 24)) / 3600)
      local minutes = math.floor(((up % (3600 * 24)) % 3600) / 60)

      widget:set_markup(
          space ..
          widget_label("UPTIME") .. days .. "d " .. hours .. "h " .. minutes .. "m"
          .. space
      )
    end
})
uptimewidget = wibox.widget.background()
uptimewidget:set_widget(uptime_widget)
uptimewidget:set_bgimage(beautiful.widget_bg)

-- Net
netwidget = lain.widgets.net({
    settings = function()
        widget:set_markup(
            space ..
            widget_label("NET")
            .. markup(beautiful.widget_netdown, net_now.received)
            .. " "
            .. markup(beautiful.widget_netup, net_now.sent)
            .. space
        )
    end
})
-- TODO change to this syntax
--local netbg = wibox.container.background(netwidget, beautiful.bg_focus, shape.rectangle)
--local networkwidget = wibox.container.margin(netbg, 0, 0, 5, 5)
networkwidget = wibox.widget.background()
networkwidget:set_widget(netwidget)
networkwidget:set_bgimage(beautiful.widget_bg)

-- / fs
fs = lain.widgets.fs({
    exclude_fstype = "tmpfs",
    followmouse = true,
    showpopup = 'off',
    settings  = function()
        widget:set_markup(
            space ..
            widget_label("HDD") .. fs_now.used .. "%"
            .. space
        )
    end,
    notification_preset = {
      position = "bottom_right",
      fg = beautiful.widget_fg
    }
})
fswidget = wibox.widget.background()
fswidget:set_widget(fs)
fswidget:set_bgimage(beautiful.widget_bg)

fswidget:connect_signal('mouse::enter', function () fs.show(0, '--exclude-type=tmpfs') end)
fswidget:connect_signal('mouse::leave', function () fs.hide() end)

-- Separators
spr = wibox.widget.imagebox()
spr:set_image(beautiful.spr)
wspace = wibox.widget.textbox("  ")
widgetspace = wibox.widget.background()
widgetspace:set_widget(wspace)
widgetspace:set_bgimage(beautiful.widget_bg)
bar = wibox.widget.imagebox()
bar:set_image(beautiful.bar)

-- Taglist and Tasklist mouse controls
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
	-- awful.button({ }, 3, client_menu_toggle_fn()),
	awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
	awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

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

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)

    -- Wallpaper
    set_wallpaper(s)

    -- Tags
    awful.tag(tagnames, s, awful.layout.layouts[1])

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
				spr,
				s.mytaglist,
				spr,
				s.mylayoutbox,
				spr,
				s.mypromptbox,
			},
			nil, -- Middle widgets
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				spr,
        wibox.widget.systray(),
				spr,
				musicwidget,
        widgetspace,
        bar,
        widgetspace,
        prev_icon,
        next_icon,
        stop_icon,
        play_pause_icon,
        widgetspace,
        bar,
        widgetspace,
        volumewidget,
        widgetspace,
        spr,
        batwidget,
        spr,
        calendarwidget,
        widgetspace,
        bar,
        widgetspace,
        clockwidget,
        spr,
      }
    }

    -- Create the bottom wibox
    s.mybottomwibox = awful.wibar({ position = "bottom", screen = s, border_width = 0, height = 32 })
    s.borderwibox = awful.wibar({ position = "bottom", screen = s, height = 1, bg = beautiful.fg_focus, x = 0, y = 33})

    s.mybottomwibox:setup {
      layout = wibox.layout.align.horizontal,
      { -- Left widgets
        layout = wibox.layout.fixed.horizontal,
        spr,
      },
      s.mytasklist, -- Middle widgets
      { -- Right widgets
        layout = wibox.layout.fixed.horizontal,
        spr,
        uptimewidget,
        spr,
        networkwidget,
        spr,
        cpuwidget,
        widgetspace,
        bar,
        widgetspace,
        sysloadwidget,
        widgetspace,
        bar,
        widgetspace,
        tempwidget,
        spr,
        memwidget,
        spr,
        fswidget,
        spr,
      }
    }

    -- TODO
    -- Create a borderbox above the bottomwibox
    --lain.widgets.borderbox(mybottomwibox[s], s, { position = "top", color = beautiful.border_focus } )
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Take a screenshot
    -- https://github.com/copycat-killer/dots/blob/master/bin/screenshot
    awful.key({ altkey }, "p", function() os.execute("screenshot") end),

    -- Tag browsing
    awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey }, "Escape", awful.tag.history.restore),

    -- Non-empty tag browsing
    awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end),
    awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end),

    -- Default client focus
    awful.key({ altkey }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ altkey }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    -- Show Menu
    awful.key({ modkey }, "w",
        function ()
            mymainmenu:show({ keygrabber = true })
        end),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
        mybottomwibox[mouse.screen].visible = not mybottomwibox[mouse.screen].visible
    end),

    -- On the fly useless gaps change
    -- TODO + does not seem to work
    awful.key({ altkey, "Control" }, "+", function () lain.util.useless_gaps_resize(1) end),
    awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey,           }, "]", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey,           }, "[", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ altkey, "Shift"   }, "l",      function () awful.tag.incmwfact( 0.05)     end),
    awful.key({ altkey, "Shift"   }, "h",      function () awful.tag.incmwfact(-0.05)     end),
    awful.key({ modkey, "Shift"   }, "l",      function () awful.tag.incnmaster(-1)       end),
    awful.key({ modkey, "Shift"   }, "h",      function () awful.tag.incnmaster( 1)       end),
    awful.key({ modkey, "Control" }, "l",      function () awful.tag.incncol(-1)          end),
    awful.key({ modkey, "Control" }, "h",      function () awful.tag.incncol( 1)          end),
    awful.key({ modkey,           }, "space",  function () awful.layout.inc(1)  end),
    awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(1)  end),
    awful.key({ modkey, "Control" }, "n",      awful.client.restore),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r",      awesome.restart),
    awful.key({ modkey, "Control"   }, "q",    awesome.quit),

    -- Dropdown terminal
    awful.key({ modkey,           }, "z",      function () quakeconsole[mouse.screen]:toggle() end),

    -- Widgets popups
    awful.key({ altkey,           }, "c",      function () lain.widgets.calendar.show(7) end),

    -- Copy to clipboard
    awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

    -- User programs
    awful.key({ modkey }, "q", function () awful.util.spawn(browser) end),
    awful.key({ modkey }, "s", function () awful.util.spawn(gui_editor) end),
    awful.key({ modkey }, "g", function () awful.util.spawn(graphics) end),

    -- Prompt
    awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    --{{ Laptop Specific

    -- Brightness keys
    awful.key({}, "XF86MonBrightnessUp", function () os.execute("xbacklight -inc 10") end),
    awful.key({}, "XF86MonBrightnessDown", function () os.execute("xbacklight -dec 10") end),

    -- Volume Keys
    awful.key({}, "XF86AudioRaiseVolume", function()
      os.execute(string.format("pactl set-sink-volume %d +%s", pulsebar.sink, pulsebar.step))
      pulsebar.update()
    end),
    awful.key({}, "XF86AudioLowerVolume", function()
      os.execute(string.format("pactl set-sink-volume %d -%s", pulsebar.sink, pulsebar.step))
      pulsebar.update()
    end)
    --}}
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.view_only(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border= beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     size_hints_honor = false } },
    { rule = { class = "URxvt" },
          properties = { opacity = 0.99 } },

    { rule = { class = "MPlayer" },
          properties = { floating = true } },

          --[[ TODO
    { rule = { class = "Dwb" },
          properties = { tag = tags[1][1] } },

    { rule = { class = "Iron" },
          properties = { tag = tags[1][1] } },

    { rule = { instance = "plugin-container" },
          properties = { tag = tags[1][1] } },

    { rule = { class = "Gimp" },
          properties = { tag = tags[1][5] } },
          --]]

    { rule = { class = "Gimp", role = "gimp-image-window" },
          properties = { maximized_horizontal = true,
                         maximized_vertical = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
local sloppyfocus_last = {c=nil}
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    client.connect_signal("mouse::enter", function(c)
         if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
             -- Skip focusing the client if the mouse wasn't moved.
             if c ~= sloppyfocus_last.c then
                 client.focus = c
                 sloppyfocus_last.c = c
             end
         end
     end)

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
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
                end)
                )

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c,{size=16}):set_widget(layout)
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_color = beautiful.border_normal
        else
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
        local clients = awful.client.visible(s)
        local layout  = awful.layout.getname(awful.layout.get(s))

        if #clients > 0 then -- Fine grained borders and floaters control
            for _, c in pairs(clients) do -- Floaters always have borders
                if awful.client.floating.get(c) or layout == "floating" then
                    c.border_width = beautiful.border_width

                -- No borders with only one visible client
                elseif #clients == 1 or layout == "max" then
                    c.border_width = 0
                else
                    c.border_width = beautiful.border_width
                end
            end
        end
      end)
end
-- }}}
