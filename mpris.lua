---------------------------------------------------------------------
-- MPRIS Widgets
---------------------------------------------------------------------
-- Controls MPRIS players like Spotify and VLC
-- Requires playerctl installed
---------------------------------------------------------------------
-- TODO Implement [OPEN SPOTIFY] button for state widget
-- TODO Display/Go to tab when clicking the now playing widget

local lain      = require( "lain"      )
local markup    = require( "lain.util" ).markup
local beautiful = require( "beautiful" )
local wibox     = require( "wibox"     )
local naughty   = require( "naughty"   )
local awful     = require( "awful"     )

local module = {}

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/default/theme.lua")

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------

local function font(text)
  return markup.font(beautiful.mpris.font, text)
end

---------------------------------------------------------------------
-- Media Controls Widget
---------------------------------------------------------------------

local controls = {}
controls.prev_button = wibox.widget.imagebox(beautiful.mpris.prev)
controls.next_button = wibox.widget.imagebox(beautiful.mpris.next)
controls.stop_button = wibox.widget.imagebox(beautiful.mpris.stop)
controls.play_button = wibox.widget.imagebox(beautiful.mpris.play)

-- Media Functions
controls.prev       = function () awful.spawn.easy_async("playerctl previous",  module.now_playing.update) end
controls.next       = function () awful.spawn.easy_async("playerctl next",      module.now_playing.update) end
controls.play_pause = function () awful.spawn.easy_async("playerctl play-pause", module.state.update) end
controls.stop       = function () awful.spawn.easy_async("playerctl stop",       module.state.update) end

-- Bind functions to buttons
controls.prev_button:buttons(awful.util.table.join(awful.button({}, 1, controls.prev       )))
controls.next_button:buttons(awful.util.table.join(awful.button({}, 1, controls.next       )))
controls.play_button:buttons(awful.util.table.join(awful.button({}, 1, controls.play_pause )))
controls.stop_button:buttons(awful.util.table.join(awful.button({}, 1, controls.stop       )))

-- Package into a widget!
controls.widget = wibox.layout.fixed.horizontal(
  controls.prev_button,
  controls.next_button,
  controls.stop_button,
  controls.play_button
)

-- Add controls to the module
module.controls = controls

---------------------------------------------------------------------
-- State Widget
---------------------------------------------------------------------

module.state = lain.widgets.abase {
  cmd = "playerctl status",
  timeout = 1,
  settings = function()
    local state = string.match(output, "Playing") or
                      string.match(output, "Paused")  or
                      "not_found"

    if state == "Playing" then
        widget:set_markup( font("[NOW PLAYING]") )
        controls.play_button:set_image(beautiful.mpris.pause)
    elseif state == "Paused" then
        widget:set_markup( font("[PAUSED]") )
        controls.play_button:set_image(beautiful.mpris.play)
    else
        widget:set_markup( font("[OPEN SPOTIFY]") )
        controls.play_button:set_image(beautiful.mpris.play)
    end
  end
}

---------------------------------------------------------------------
-- Now Playing Widget
---------------------------------------------------------------------

module.now_playing = lain.widgets.abase {
  cmd = "playerctl metadata",
  timeout = 1,
  settings = function()
    local mpris_now = {
      state        = "N/A",
      artist       = "N/A",
      title        = "N/A",
      art_url      = "N/A",
      album        = "N/A",
      album_artist = "N/A"
    }

    for k, v in string.gmatch(output, "'[^:]+:([^']+)':[%s]<%[?'([^']+)'%]?>") do
      if     k == "artUrl"      then mpris_now.art_url      = v
      elseif k == "artist"      then mpris_now.artist       = v
      elseif k == "title"       then mpris_now.title        = v
      elseif k == "album"       then mpris_now.album        = v
      elseif k == "albumArtist" then mpris_now.album_artist = v
      end
    end

    mpris_now.artist = mpris_now.artist:upper():gsub("&.-;", string.lower)
    mpris_now.title  = mpris_now.title:upper():gsub("&.-;", string.lower)

    -- Update widget text
    local artist = markup.fg.color(beautiful.mpris.artist, mpris_now.artist)
    widget:set_markup( font(artist .. " - " .. mpris_now.title) )
  end
}

return module

