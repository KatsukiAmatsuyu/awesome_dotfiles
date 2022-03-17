local awful = require "awful"
local beautiful = require "beautiful"
local gears = require "gears"
local wibox = require "wibox"
local helpers = require "helpers"

local night_light = wibox.widget {
  {
    {
      widget = wibox.widget.imagebox,
      image = gears.filesystem.get_configuration_dir() .. "icons/sun.svg",
      stylesheet = " * { stroke: " .. beautiful.fg_normal .. " }",
      forced_width = 25,
      valign = "center",
      halign = "center",
    },
    widget = wibox.container.margin,
    margins = 12.5,
  },
  widget = wibox.container.background,
  bg = beautiful.bg_normal,
  shape = helpers.rrect(beautiful.tooltip_box_border_radius),
}

helpers.add_hover_cursor(night_light, "hand1")

local on = beautiful.bg_focus
local off = beautiful.bg_normal
local s = true

local fd = io.popen("cat /home/katsuki/.config/awesome/rc.lua | grep 'theme =' | grep -Eo '[0-9]' | head -1")

night_light:buttons {
  awful.button({}, 1, function()
	  if tonumber(fd:read("*all")) == 1 then s = false else s = true end
	  fd:close()
    if s then
      night_light.bg = off
      awful.spawn "/home/katsuki/.config/awesome/scripts/light"
	  s = false
	  awesome.restart()
    else
      night_light.bg = on
      awful.spawn "/home/katsuki/.config/awesome/scripts/dark"
	  s = true
	  awesome.restart()
    end
  end),
}

return night_light
