
local awful = require( "awful" )

local global = { root = root }
local os     = { execute = os.execute }

local keybindings = {}

keybindings.init = function (context)

  local globalkeys = awful.util.table.join(

    -- Take a screenshot
    -- https://github.com/copycat-killer/dots/blob/master/bin/screenshot
    awful.key({ altkey }, "p", function() os.execute("screenshot") end),

    -- Taskwarrior Prompt
    awful.key({ altkey }, "t", lain.widgets.contrib.task.prompt),

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

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        -- TODO hide blue bottom bar
        awful.screen.focused().mywibox.visible = not awful.screen.focused().mywibox.visible
        awful.screen.focused().mybottomwibox.visible = not awful.screen.focused().mybottomwibox.visible
    end),

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
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "t",      function () awful.spawn("startx -- /usr/bin/Xephyr :1 -screen 1024x768") end),
    awful.key({ modkey, "Control" }, "r",      awesome.restart),
    awful.key({ modkey, "Control" }, "q",      awesome.quit),

    -- Dropdown terminal
    awful.key({ modkey,           }, "z", function () awful.screen.focused().quakeconsole:toggle() end),

    -- Widgets popups
    awful.key({ altkey,           }, "c", function () lain.widgets.calendar.show(7) end),

    -- Copy to clipboard
    awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

    -- User programs
    awful.key({ modkey }, "q", function () awful.spawn(browser) end),
    awful.key({ modkey }, "s", function () awful.spawn(gui_editor) end),
    awful.key({ modkey }, "g", function () awful.spawn(graphics) end),

    -- Prompt
    awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    --{{ Laptop Specific

    -- Brightness keys
    awful.key({}, "XF86MonBrightnessUp", function () os.execute("xbacklight -inc 10") end),
    awful.key({}, "XF86MonBrightnessDown", function () os.execute("xbacklight -dec 10") end),

    -- Volume Keys
    awful.key({}, "XF86AudioRaiseVolume", function()
      os.execute(string.format("pactl set-sink-volume %d +%s", widgets.volume.sink, widgets.volume.step))
      widgets.volume.update()
    end),
    awful.key({}, "XF86AudioLowerVolume", function()
      os.execute(string.format("pactl set-sink-volume %d -%s", widgets.volume.sink, widgets.volume.step))
      widgets.volume.update()
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
          local screen = awful.screen.focused()
          local tag = screen.tags[i]
          if tag then
            tag:view_only()
          end
        end),
      -- Toggle tag.
      awful.key({ modkey, "Control" }, "#" .. i + 9,
        function ()
          local screen = awful.screen.focused()
          local tag = screen.tags[i]
          if tag then
            awful.tag.viewtoggle(tag)
          end
        end),
      -- Move client to tag.
      awful.key({ modkey, "Shift" }, "#" .. i + 9,
        function ()
          if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then
              client.focus:move_to_tag(tag)
            end
          end
        end),
      -- Toggle tag on focused client.
      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
        function ()
          if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then
              client.focus:toggle_tag(tag)
            end
          end
        end))
  end

  keybindings.globalkeys = globalkeys

end

return keybindings
