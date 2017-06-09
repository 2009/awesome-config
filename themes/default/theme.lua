---------------------------------------------------------------------
-- Default Theme
---------------------------------------------------------------------

local gears = require("gears")
local naughty = require("naughty")
local inspect = require("util.inspect")

local theme                         = {}

theme.icon_dir                      = os.getenv("HOME") .. "/.config/awesome/themes/default/icons"
theme.wallpaper                     = os.getenv("HOME") .. "/.config/awesome/themes/default/wall.jpg"

---------------------------------------------------------------------
-- Color Scheme
---------------------------------------------------------------------

theme.blue                          = "#0099CC"
theme.blue_light                    = "#80CCE6"
theme.blue_very_light               = "#4CB7DB"
theme.grey_light                    = "#757575"
theme.grey                          = "#383838"
theme.grey_darker                   = "#292929"
theme.grey_dark                     = "#242424"
theme.grey_very_dark                = "#2A1F1E"
theme.green                         = "#EE6D5A"
theme.red                           = "#92C739"
theme.red_pale                      = "#FF9F9F"
theme.pink                          = "#CC9393"
theme.white                         = "#FFFFFF"

---------------------------------------------------------------------
-- Beutiful Variables
---------------------------------------------------------------------

-- NOTE wibar_height and wibar_width are currently broken in awesome
theme.wibar_height = 32
theme.wibar_width  = 32

theme.font                          = "Misc Tamsyn 10.5"
theme.taglist_font                  = "Misc Tamsyn 8"

theme.fg_normal                     = theme.white
theme.fg_focus                      = theme.blue
theme.bg_normal                     = theme.grey_darker
theme.fg_urgent                     = theme.pink
theme.bg_urgent                     = theme.grey_very_dark
theme.border_width                  = "1"
theme.border_normal                 = theme.grey_dark
theme.border_focus                  = theme.blue

--theme.taglist_bg_empty              = "png:" .. theme.icon_dir .. "/taglist_bg_empty.png"
--theme.taglist_bg_occupied           = "png:" .. theme.icon_dir .. "/taglist_bg_empty.png"
theme.taglist_fg_focus              = theme.white
theme.taglist_bg_focus              = theme.grey
--theme.taglist_spacing             = 10

theme.tasklist_bg_normal            = theme.grey_darker
theme.tasklist_fg_focus             = theme.blue_very_light
theme.tasklist_bg_focus             = theme.grey_dark
--theme.tasklist_bg_focus             = "png:" .. theme.icon_dir .. "/bg_focus_noline.png"

theme.textbox_widget_margin_top     = 1
theme.awful_widget_height           = 14
theme.awful_widget_margin_top       = 2

-- images
theme.widget_bg                     = theme.icon_dir .. "/bg_focus_noline.png"
theme.awesome_icon                  = theme.icon_dir .. "/awesome_icon.png"
theme.submenu_icon                  = theme.icon_dir .. "/submenu.png"
theme.spr                           = theme.icon_dir .. "/spr.png"
theme.bar                           = theme.icon_dir .. "/bar.png"
theme.bottom_bar                    = theme.icon_dir .. "/bottom_bar.png"

theme.layout_tile                   = theme.icon_dir .. "/tile.png"
theme.layout_tilegaps               = theme.icon_dir .. "/tilegaps.png"
theme.layout_tileleft               = theme.icon_dir .. "/tileleft.png"
theme.layout_tilebottom             = theme.icon_dir .. "/tilebottom.png"
theme.layout_tiletop                = theme.icon_dir .. "/tiletop.png"
theme.layout_fairv                  = theme.icon_dir .. "/fairv.png"
theme.layout_fairh                  = theme.icon_dir .. "/fairh.png"
theme.layout_spiral                 = theme.icon_dir .. "/spiral.png"
theme.layout_dwindle                = theme.icon_dir .. "/dwindle.png"
theme.layout_max                    = theme.icon_dir .. "/max.png"
theme.layout_fullscreen             = theme.icon_dir .. "/fullscreen.png"
theme.layout_magnifier              = theme.icon_dir .. "/magnifier.png"
theme.layout_floating               = theme.icon_dir .. "/floating.png"

theme.tasklist_disable_icon         = true
theme.tasklist_floating             = ""
theme.tasklist_maximized_horizontal = ""
theme.tasklist_maximized_vertical   = ""

---------------------------------------------------------------------
-- Beautiful Background Image Functions
---------------------------------------------------------------------
-- NOTE: assigning functions to taglist image variables do not work
-- without passing a custom update_list function to taglist.new().
---------------------------------------------------------------------

-- Add colored square to the corner of the tag
theme.taglist_squares_sel = function(context, cr, width, height)
  local size = 5
  cr:set_source(gears.color(theme.blue))
  cr:rectangle(0, 0, size, size)
  cr:fill()
end

-- Add colored corner to the tag
theme.taglist_squares_unsel = function(context, cr, width, height)
  local size = 5

  cr:set_source(gears.color(theme.blue))
  cr:set_line_width(1)

  -- We add 0.5 to the pos values below to get a perfect single pixel line,
  -- this is because coordinates map to the intersection of pixels in cairo.
  --
  -- For example, coordinates (1,1) would point to the spot in between the
  -- first four pixels.
  -- see: https://www.cairographics.org/FAQ/#sharp_lines

  -- Draw the horizontal line
  cr:move_to(0, 0.5)
  cr:rel_line_to(size, 0)
  cr:stroke()

  -- Draw the vertical line
  cr:move_to(0.5, 0)
  cr:rel_line_to(0, size)
  cr:stroke()
end

---------------------------------------------------------------------
-- Custom Variables
---------------------------------------------------------------------

theme.widget_bg_color     = theme.grey_darker

-- taglist
theme.taglist_tag_margin  = { left = 3, right = 2, top = 4, bottom = 3 }
theme.taglist_tag_padding = { left = 15, right = 15, top = 5, bottom = 7 }

-- widget colors
theme.widget_label        = theme.grey_light
theme.widget_fg           = theme.white
theme.widget_netdown      = theme.red
theme.widget_netup        = theme.green
theme.widget_vol_bg       = theme.grey
theme.widget_vol_fg       = theme.blue_light
theme.widget_vol_mute     = theme.red_pale
theme.widget_battery      = theme.blue_light

theme.mpris               = {}
theme.mpris.font          = "Misc Tamsyn 8"
theme.mpris.artist        = theme.blue
theme.mpris.status        = theme.blue_light
theme.mpris.prev          = theme.icon_dir .. "/prev.png"
theme.mpris.next          = theme.icon_dir .. "/next.png"
theme.mpris.stop          = theme.icon_dir .. "/stop.png"
theme.mpris.pause         = theme.icon_dir .. "/pause.png"
theme.mpris.play          = theme.icon_dir .. "/play.png"

-- other colors
theme.border_focus        = theme.blue

---------------------------------------------------------------------
-- Custom Background Image Variables
---------------------------------------------------------------------

  -- Draw a blue bar under tags
theme.taglist_bg_image_focus = function(context, cr, width, height)
  local b_height = 3
  local b_width = width
  local x  = 0
  local y  = height - b_height

  cr:set_source(gears.color(theme.blue))
  cr:rectangle(x, y, b_width, b_height)
  cr:fill()
end

---------------------------------------------------------------------
-- Lain Variables
---------------------------------------------------------------------

theme.useless_gap_width      = 10
theme.layout_centerfair      = theme.icon_dir .. "/centerfair.png"
theme.layout_uselesstile     = theme.icon_dir .. "/uselesstile.png"
theme.layout_uselesstileleft = theme.icon_dir .. "/uselesstileleft.png"
theme.layout_uselesstiletop  = theme.icon_dir .. "/uselesstiletop.png"

return theme
