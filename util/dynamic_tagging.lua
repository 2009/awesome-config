---------------------------------------------------------------------
-- Dynamic Tagging
---------------------------------------------------------------------
-- http://github.com/copycat-killer/lain
---------------------------------------------------------------------
local awful    = require("awful")
local tonumber = tonumber

local module = {};

-- Add a new tag (UPPERCASED)
function module.add_tag(layout)
    awful.prompt.run {
        prompt       = "New tag name: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = function(name)
            if not name or #name == 0 then return end
            awful.tag.add(string.upper(name), { screen = awful.screen.focused(), layout = layout or awful.layout.layouts[1] }):view_only()
        end
    }
end

-- Rename current tag (UPPERCASED)
function module.rename_tag()
    awful.prompt.run {
        prompt       = "Rename tag: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = function(new_name)
            if not new_name or #new_name == 0 then return end
            local t = awful.screen.focused().selected_tag
            if t then
                t.name = string.upper(new_name)
            end
        end
    }
end

-- Move current tag
-- pos in {-1, 1} <-> {previous, next} tag position
function module.move_tag(pos)
    local tag = awful.screen.focused().selected_tag
    if tonumber(pos) <= -1 then
        awful.tag.move(tag.index - 1, tag)
    else
        awful.tag.move(tag.index + 1, tag)
    end
end

-- Delete current tag
-- Any rule set on the tag shall be broken
function module.delete_tag()
    local t = awful.screen.focused().selected_tag
    if not t then return end
    t:delete()
end

return module;
