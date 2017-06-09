---------------------------------------------------------------------
-- Surface
---------------------------------------------------------------------
-- ___DEPRECATED___________________________________________________
-- This was initially to allow me to create the tag backgrounds for
-- when they are selected.
-- After moving to using a custom update_fuction passed to the
-- taglist.new(), I can now just set the theme variables to function
-- that gets the cairo context to draw on, hence these functions are
-- no longer needed. I will however leave these here for a time.
-- __________________________________________________________________
-- This file contains a bunch of functions that create cairo surfaces
-- used for customization.
---------------------------------------------------------------------
local cairo = require("lgi").cairo
local gears = require("gears")

local module = {}

-- An underline
module.underline = function(color, width, height)
  local surface = cairo.ImageSurface.create(cairo.Format.ARGB32, width, height)
  local cr  = cairo.Context(surface)

  local bar_margin = 0
  local bar_height = 2
  local bar_width  = width
  local bar_pos_x  = 0
  local bar_pos_y  = height - bar_height - bar_margin

  cr:set_source(gears.color(color))
  cr:rectangle(bar_pos_x, bar_pos_y, bar_width, bar_height)
  cr:fill()

  return surface
end

-- A box drawn on a cairo surface
module.box = function(color, posx, posy, size)

  -- Make sure we make the surface big enough to hold our corner drawing
  local area_x = posx + size
  local area_y = posy + size

  -- Create the transparent image surface
  local surface = cairo.ImageSurface.create(cairo.Format.ARGB32, area_x, area_y)

  -- Create a context and set the source color
  local cr  = cairo.Context(surface)
  cr:set_source(gears.color(color))

  -- Create the square and fill it
  -- x, y, width, height
  cr:rectangle(posx, posy, size, size)
  cr:fill()

  return surface
end

-- Cairo surface with a 1px width colored corner drawn
module.corner_1px = function(color, posx, posy, size)

  -- Make sure we make the surface big enough to hold our corner drawing
  local area_x = posx + size + 2
  local area_y = posy + size + 2

  -- Create the transparent image surface
  local surface = cairo.ImageSurface.create(cairo.Format.ARGB32, area_x, area_y)

  -- Create a context and set the source color
  local cr = cairo.Context(surface)
  cr:set_source(gears.color(color))
  cr:set_line_width(1)

  -- We add 0.5 to the pos values below to get a perfect single pixel line,
  -- this is because coordinates map to the intersection of pixels in cairo.
  --
  -- For example, coordinates (1,1) would point to the spot in between the
  -- first four pixels.
  -- see: https://www.cairographics.org/FAQ/#sharp_lines

  -- Draw the horizontal line
  cr:move_to(posx, posy + 0.5)
  cr:rel_line_to(size, 0)
  cr:stroke()

  -- Draw the vertical line
  cr:move_to(posx + 0.5, posy)
  cr:rel_line_to(0, size)
  cr:stroke()

  return surface
end

-- Convert a surface to a Cairo pattern
module.to_pattern = function(surface)
  return cairo.Pattern.create_for_surface(surface)
end

return module
