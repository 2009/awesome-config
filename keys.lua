---------------------------------------------------------------------
-- Keys
---------------------------------------------------------------------

local awful    = require( "awful" )
local lain     = require( "lain" )
local config   = require( "config" )
local widgets  = require( "widgets" )
local hotkeys  = require( "awful.hotkeys_popup.widget" )
local tags     = require( "util.dynamic_tagging" )

local global = { root = root }
local os     = { execute = os.execute }

-- Bind config locally
local modkey     = config.modkey
local altkey     = config.altkey
local terminal   = config.terminal
local editor     = config.editor
local gui_editor = config.gui_editor
local browser    = config.browser
local graphics   = config.graphics
local xres       = config.xephyr_resolution

local keys  = {}
keys.global = {}
keys.client = {}

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------

local function bind_key(group, desc, mod, key, press)
  return awful.key.new(mod, key, press, nil, {description=desc, group=group})
end

local function gkey(...)
  keys.global = awful.util.table.join(keys.global, bind_key(...))
end

local function ckey(...)
  keys.client = awful.util.table.join(keys.client, bind_key(...))
end

---------------------------------------------------------------------
-- Globals Keys
---------------------------------------------------------------------

-- Take a screenshot
-- https://github.com/copycat-killer/dots/blob/master/bin/screenshot
--gkey("apps", "Screenshot",         { altkey }, "p", function() os.execute("screenshot") end)
gkey("apps", "Screenshot",         { altkey }, "p", function() awful.spawn.with_shell("sleep 0.1s && scrot -s -e 'mv $f ~/screenshots/'") end)

gkey("apps", "Taskwarrior Prompt", { altkey }, "t", lain.widget.contrib.task.prompt)

gkey("apps", "Show help", { modkey }, "/", hotkeys.show_help)

-- Tag browsing
gkey("tag", "Tag prev",       { modkey }, "Left",   awful.tag.viewprev)
gkey("tag", "Tag next",       { modkey }, "Right",  awful.tag.viewnext)
gkey("tag", "Tag prev (alt)", { modkey, altkey }, "j", awful.tag.viewprev)
gkey("tag", "Tag next (alt)", { modkey, altkey }, "k", awful.tag.viewnext)
gkey("tag", "Tag alternate",  { modkey }, "Escape", awful.tag.history.restore)

-- Non-empty tag browsing
gkey("tag", "Tag prev (non-empty)", { altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end)
gkey("tag", "Tag next (non-empty)", { altkey }, "Right", function () lain.util.tag_view_nonempty(1) end)

-- Dynamic tagging
gkey("tag", "Add new tag",    { modkey, "Shift" }, "n", function () tags.add_tag() end)
gkey("tag", "Rename tag",     { modkey, "Shift" }, "r", function () tags.rename_tag() end)
gkey("tag", "Move tag left",  { modkey, "Shift" }, "Left", function () tags.move_tag(-1) end)  -- move to previous tag
gkey("tag", "Move tag right", { modkey, "Shift" }, "Right", function () tags.move_tag(1) end)  -- move to next tag
gkey("tag", "Delete tag",     { modkey, "Shift" }, "d", function () tags.delete_tag() end)

-- Default client focus
gkey("client", "Client focus next", { altkey }, "k", function ()
  awful.client.focus.byidx( 1)
  if client.focus then client.focus:raise() end
end)
gkey("client", "Client focus prev", { altkey }, "j", function ()
  awful.client.focus.byidx(-1)
  if client.focus then client.focus:raise() end
end)

-- By direction client focus
gkey("client", "Client focus down", { modkey }, "j", function()
  awful.client.focus.bydirection("down")
  if client.focus then client.focus:raise() end
end)
gkey("client", "Client focus up", { modkey }, "k", function()
  awful.client.focus.bydirection("up")
  if client.focus then client.focus:raise() end
end)
gkey("client", "Client focus left", { modkey }, "h", function()
  awful.client.focus.bydirection("left")
  if client.focus then client.focus:raise() end
end)
gkey("client", "Client focus right", { modkey }, "l", function()
  awful.client.focus.bydirection("right")
  if client.focus then client.focus:raise() end
end)

-- Show/Hide Wibox
gkey("other", "Hide top and bottom bars", { modkey }, "b", function ()
    -- TODO hide blue bottom bar
    -- TODO references a specific name
    awful.screen.focused().mywibox.visible = not awful.screen.focused().mywibox.visible
    awful.screen.focused().mybottomwibox.visible = not awful.screen.focused().mybottomwibox.visible
end)

-- Layout manipulation
gkey("client", "Client swap next",       { modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end)
gkey("client", "Client swap prev",       { modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end)
gkey("client", "Client focus urgent",    { modkey,           }, "u", awful.client.urgent.jumpto)
gkey("client", "Client focus alternate", { modkey,           }, "Tab", function ()
  awful.client.focus.history.previous()
  if client.focus then
    client.focus:raise()
  end
end)

-- TODO
gkey("not_done", "", { altkey, "Shift"   }, "l",      function () awful.tag.incmwfact( 0.05)     end)
gkey("not_done", "", { altkey, "Shift"   }, "h",      function () awful.tag.incmwfact(-0.05)     end)
gkey("not_done", "", { modkey, "Shift"   }, "l",      function () awful.tag.incnmaster(-1)       end)
gkey("not_done", "", { modkey, "Shift"   }, "h",      function () awful.tag.incnmaster( 1)       end)
gkey("not_done", "", { modkey, "Control" }, "l",      function () awful.tag.incncol(-1)          end)
gkey("not_done", "", { modkey, "Control" }, "h",      function () awful.tag.incncol( 1)          end)

gkey("layout", "Layout next", { modkey,           }, "space",  function () awful.layout.inc(1)  end)
gkey("layout", "Layout prev", { modkey, "Shift"   }, "space",  function () awful.layout.inc(-1)  end)

gkey("client", "Client maximise", { modkey, "Control" }, "n",      awful.client.restore)

gkey("screen", "Screen focus next", { modkey }, "]", function () awful.screen.focus_relative( 1) end)
gkey("screen", "Screen focus prev", { modkey }, "[", function () awful.screen.focus_relative(-1) end)

-- Standard program
gkey("apps", "", { modkey,           }, "Return", function () awful.spawn(terminal) end)

gkey("awesome", "Awesome Xephyr",   { modkey, "Control" }, "t", function () awful.spawn("startx -- /usr/bin/Xephyr :1 -screen "..xres) end)
gkey("awesome", "Aweseome restart", { modkey, "Control" }, "r", awesome.restart)
gkey("awesome", "Awesome quit",     { modkey, "Control" }, "q", awesome.quit)


-- Dropdown terminal
gkey("apps", "Quake terminal", { modkey }, "z", function () awful.screen.focused().quakeconsole:toggle() end)

-- Widgets popups
gkey("wigets", "Calendar show", { altkey }, "c", function () lain.widget.calendar.show(7) end)

-- Copy to clipboard
gkey("not_done", "Copy to clipboard", { modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end)

-- User programs
gkey("apps", "Launch browser",         { modkey }, "q", function () awful.spawn(browser) end)
gkey("apps", "Launch gui editor",      { modkey }, "s", function () awful.spawn(gui_editor) end)
gkey("apps", "Launch graphics editor", { modkey }, "g", function () awful.spawn(graphics) end)

-- Prompt
gkey("launcher", "Run prompt", { modkey }, "r", function () awful.screen.focused().mypromptbox:run() end)

--{{ Laptop Specific

-- Brightness keys
gkey("laptop", "Brightness up",   {}, "XF86MonBrightnessUp",   function () os.execute("xbacklight -inc 10") end)
gkey("laptop", "Brightness down", {}, "XF86MonBrightnessDown", function () os.execute("xbacklight -dec 10") end)

-- Volume Keys
gkey("not_done", "Volume up", {}, "XF86AudioRaiseVolume", function()
  os.execute(string.format("pactl set-sink-volume %d +%s", widgets.volume.instance.device, widgets.volume.step))
  widgets.volume.instance.update()
end)
gkey("not_done", "Volume down", {}, "XF86AudioLowerVolume", function()
  os.execute(string.format("pactl set-sink-volume %d -%s", widgets.volume.instance.device, widgets.volume.step))
  widgets.volume.instance.update()
end)

-- Lock Key
gkey("not_done", "Lock Screen", { modkey, altkey }, "l", function () os.execute("xscreensaver-command --lock") end)

-- Bind all key numbers to tags.
-- be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do

  -- View tag only.
  gkey("tag", "Switch to tag " .. i, { modkey }, "#" .. i + 9, function ()
    local screen = awful.screen.focused()
    local tag = screen.tags[i]
    if tag then
      tag:view_only()
    end
  end)
  -- Toggle tag.
  gkey("tag", "Toggle tag " .. i, { modkey, "Control" }, "#" .. i + 9, function ()
    local screen = awful.screen.focused()
    local tag = screen.tags[i]
    if tag then
      awful.tag.viewtoggle(tag)
    end
  end)
  -- Move client to tag.
  gkey("tag", "Move client to tag " .. i, { modkey, "Shift" }, "#" .. i + 9, function ()
    if client.focus then
      local tag = client.focus.screen.tags[i]
      if tag then
        client.focus:move_to_tag(tag)
      end
    end
  end)
  -- Toggle tag on focused client.
  gkey("tag", "Toggle tag " .. i .. " for focused client", { modkey, "Control", "Shift" }, "#" .. i + 9, function ()
    if client.focus then
      local tag = client.focus.screen.tags[i]
      if tag then
        client.focus:toggle_tag(tag)
      end
    end
  end)
end

---------------------------------------------------------------------
-- Client Keys
---------------------------------------------------------------------

ckey("client", "Fullscreen client", { modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end)
ckey("client", "Kill client",   { modkey, "Shift"   }, "c",      function (c) c:kill()                         end)
ckey("client", "Float client",  { modkey, "Control" }, "space",  awful.client.floating.toggle                     )
ckey("client", "not_done",      { modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end)
ckey("client", "not_done",      { modkey,           }, "o",      function (c) c:move_to_screen()               end)
ckey("client", "Client on top", { modkey,           }, "t",      function (c) c.ontop = not c.ontop            end)
-- TODO
ckey("client", "not_done",      { modkey,           }, "n", function (c)
  -- The client currently has the input focus, so it cannot be
  -- minimized, since minimized clients can't have the focus.
  c.minimized = true
end)
ckey("client", "not_done", { modkey,           }, "m", function (c)
  c.maximized_horizontal = not c.maximized_horizontal
  c.maximized_vertical   = not c.maximized_vertical
end)

return keys
