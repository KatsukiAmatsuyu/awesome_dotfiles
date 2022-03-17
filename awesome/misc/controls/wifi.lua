local awful = require "awful"
local beautiful = require "beautiful"
local gears = require "gears"
local wibox = require "wibox"
local helpers = require "helpers"

local wifi = wibox.widget {
  {
    {
      widget = wibox.widget.imagebox,
      image = gears.filesystem.get_configuration_dir() .. "icons/wifi.svg",
      stylesheet = " * { stroke: " .. beautiful.fg_normal .. " }",
      forced_width = 30,
      valign = "center",
      halign = "center",
    },
    widget = wibox.container.margin,
    margins = 10,
  },
  widget = wibox.container.background,
  bg = beautiful.bg_focus,
  shape = helpers.rrect(beautiful.tooltip_box_border_radius),
}

helpers.add_hover_cursor(wifi, "hand1")

local on = beautiful.xcolor4
local off = beautiful.bg_normal
local s = false -- off
wifi:buttons {
  awful.button({}, 1, function()
	local fd = io.popen("nmcli n")
	if tostring(fd:read("*all")) == "enabled" then s = true else s = false end
	s = not s
    if s then
      wifi.bg = off
      awful.spawn "nmcli radio wifi off"
    else
      wifi.bg = on
      awful.spawn "nmcli radio wifi on"
    end
  end),
}

return wifi
