---------------------------------------------------------------------
-- Custom Taglist Widget
---------------------------------------------------------------------
-- Creates a taglist but with a few customizations:
--
--    * Default mouse controls set
--    * Add an additional margin around individual tags
---------------------------------------------------------------------

local awful     = require("awful")
local wibox     = require("wibox")
local common    = require("awful.widget.common")
local beautiful = require("beautiful")
local dpi       = require("beautiful").xresources.apply_dpi

local taglist = { mt = {} };

---------------------------------------------------------------------
-- Taglist Mouse Controls
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

---------------------------------------------------------------------
-- Wrapped Create
---------------------------------------------------------------------

taglist.new = function(screen, filter, style)
  return awful.widget.taglist(screen, filter, taglist_buttons, style, list_update)
end

---------------------------------------------------------------------
-- Custom Taglist Update
---------------------------------------------------------------------

-- Customized version of the common update method to add a margin around
-- taglist tag widgets.
-- See: awful.widget.common.list_update
--
-- @param w The widget.
-- @tab buttons
-- @func label Function to generate label parameters from an object.
--   The function gets passed an object from `objects`, and
--   has to return `text`, `bg`, `bg_image`, `icon`.
-- @tab data Current data/cache, indexed by objects.
-- @tab objects Objects to be displayed / updated.
function list_update(w, buttons, label, data, objects)

  local theme = beautiful.get()

  -- Allow adding a margin around individual tags
  local margin  = theme.taglist_tag_margin
  local padding = theme.taglist_tag_padding

  -- Allow adding a background image for focused tags
  local bg_image_focus = theme.taglist_bg_image_focus

  -- update the widgets, creating them if needed
  w:reset()
  for i, tag in ipairs(objects) do
    local cache = data[tag]
    local ib, tb, bgb, add_bgb, tbm, ibm, l, add_margin
    if cache then
      ib = cache.ib
      tb = cache.tb
      bgb = cache.bgb
      tbm = cache.tbm
      ibm = cache.ibm
      add_bgb = cache.add_bgb
      add_padding = cache.add_padding
      add_margin = cache.add_margin
    else
      ib = wibox.widget.imagebox()
      tb = wibox.widget.textbox()
      bgb = wibox.container.background()
      tbm = wibox.container.margin(tb, dpi(4), dpi(4))
      ibm = wibox.container.margin(ib, dpi(4))
      l = wibox.layout.fixed.horizontal()

      add_bgb = wibox.container.background()
      add_padding = wibox.container.margin(l)
      add_margin  = wibox.container.margin(add_bgb)--, 0, 0, 0, 0, "#FF0000")

      -- All of this is added in a fixed widget
      l:fill_space(true)
      l:add(ibm)
      l:add(tbm)

      -- And all of this gets a background
      bgb:set_widget(add_padding)
      add_bgb:set_widget(bgb)

      add_margin:buttons(common.create_buttons(buttons, tag))

      data[tag] = {
        ib  = ib,
        tb  = tb,
        bgb = bgb,
        tbm = tbm,
        ibm = ibm,
        add_bgb = add_bgb,
        add_padding = add_padding,
        add_margin = add_margin,
      }
    end

    local text, bg, bg_image, icon, args = label(tag, tb)
    args = args or {}

    -- The text might be invalid, so use pcall.
    if text == nil or text == "" then
      tbm:set_margins(0)
    else
      if not tb:set_markup_silently(text) then
        tb:set_markup("<i>&lt;Invalid text&gt;</i>")
      end
    end
    add_bgb:set_bg(bg)
    bgb:set_bgimage(bg_image)

    if icon then
      ib:set_image(icon)
    else
      ibm:set_margins(0)
    end

    if tag.selected and bg_image_focus then
      add_bgb:set_bgimage(bg_image_focus)
    else
      add_bgb:set_bgimage(nil)
    end

    if padding then
      add_padding:set_left(padding.left or 0)
      add_padding:set_right(padding.right or 0)
      add_padding:set_top(padding.top or 0)
      add_padding:set_bottom(padding.bottom or 0)
    end

    if margin then
      add_margin:set_left(margin.left or 0)
      add_margin:set_right(margin.right or 0)
      add_margin:set_top(margin.top or 0)
      add_margin:set_bottom(margin.bottom or 0)
    end

    add_bgb.shape              = args.shape
    add_bgb.shape_border_width = args.shape_border_width
    add_bgb.shape_border_color = args.shape_border_color

    w:add(add_margin)
  end
end

---------------------------------------------------------------------
-- Custom Taglist Label Function
---------------------------------------------------------------------
-- Extend the label function to add additional theme variables

--function taglist_label(label, tag, args)
--  --if not args then args = {} end
--  --local theme = beautiful.get()
--
--  --local lbl = label(tag, args)
--
--  ---- Add additional background image
--  --local bg_image_focus = args.bg_image_focus or theme.bg_image_focus
--  --if tag.focus and bg_image_focus then
--  --  
--  --end
--
--
--
--
--end

function taglist.mt:__call(...)
    return taglist.new(...)
end

return setmetatable(taglist, taglist.mt)
