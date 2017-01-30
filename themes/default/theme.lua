--[[
                                
        Default Theme
                                
--]]

local theme                               = {}

theme.icon_dir                      = os.getenv("HOME") .. "/.config/awesome/themes/default/icons"
theme.wallpaper                     = os.getenv("HOME") .. "/.config/awesome/themes/default/MTG-Hydra-1920x1080.jpg"
theme.topbar_path                   = "png:" .. theme.icon_dir .. "/topbar/"

-- colorscheme
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

theme.widget_bg_color = theme.grey_darker

-- beautiful
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

theme.taglist_bg_empty              = "png:" .. theme.icon_dir .. "/taglist_bg_empty.png"
theme.taglist_bg_occupied           = "png:" .. theme.icon_dir .. "/taglist_bg_empty.png"
theme.taglist_fg_focus              = theme.white
theme.taglist_bg_focus              = "png:" .. theme.icon_dir .. "/taglist_bg_focus.png"

theme.tasklist_bg_normal            = theme.grey_darker
theme.tasklist_fg_focus             = theme.blue_very_light
theme.tasklist_bg_focus             = theme.grey_dark
--theme.tasklist_bg_focus             = "png:" .. theme.icon_dir .. "/bg_focus_noline.png"

theme.textbox_widget_margin_top     = 1
theme.awful_widget_height           = 14
theme.awful_widget_margin_top       = 2

-- widget colors
theme.widget_label                  = theme.grey_light
theme.widget_fg                     = theme.white
theme.widget_netdown                = theme.red
theme.widget_netup                  = theme.green
theme.widget_vol_bg                 = theme.grey
theme.widget_vol_fg                 = theme.blue_light
theme.widget_vol_mute               = theme.red_pale
theme.widget_battery                = theme.blue_light

theme.mpris = {}
theme.mpris.font = "Misc Tamsyn 8"
theme.mpris.artist = theme.blue
theme.mpris.status = theme.blue_light
theme.mpris.prev   = theme.icon_dir .. "/prev.png"
theme.mpris.next   = theme.icon_dir .. "/next.png"
theme.mpris.stop   = theme.icon_dir .. "/stop.png"
theme.mpris.pause  = theme.icon_dir .. "/pause.png"
theme.mpris.play   = theme.icon_dir .. "/play.png"

-- other colors
theme.border_focus                  = theme.blue

-- images
theme.widget_bg                     = theme.icon_dir .. "/bg_focus_noline.png"
theme.awesome_icon                  = theme.icon_dir .. "/awesome_icon.png"
theme.submenu_icon                  = theme.icon_dir .. "/submenu.png"
theme.taglist_squares_sel           = theme.icon_dir .. "/square_sel.png"
theme.taglist_squares_unsel         = theme.icon_dir .. "/square_unsel.png"
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

-- lain related
theme.useless_gap_width             = 10
theme.layout_centerfair             = theme.icon_dir .. "/centerfair.png"
theme.layout_uselesstile            = theme.icon_dir .. "/uselesstile.png"
theme.layout_uselesstileleft        = theme.icon_dir .. "/uselesstileleft.png"
theme.layout_uselesstiletop         = theme.icon_dir .. "/uselesstiletop.png"

return theme
