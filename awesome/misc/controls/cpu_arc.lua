local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local awful = require("awful")

local active_color = beautiful.arc_color

local cpu_arc = wibox.widget {
    max_value = 100,
    thickness = 11,
    start_angle = 4.3,
    rounded_edge = true,
    bg = beautiful.bg_normal,
    paddings = dpi(10),
    colors = active_color,
    widget = wibox.container.arcchart
}

local update_interval = 5
local cpu_idle_script = [[
  sh -c "
  vmstat 1 2 | tail -1 | awk '{printf \"%d\", $15}'
  "]]

awful.widget.watch(cpu_idle_script, update_interval, function(widget, stdout)
    -- local cpu_idle = stdout:match('+(.*)%.%d...(.*)%(')
    local cpu_idle = stdout
    cpu_idle = string.gsub(cpu_idle, '^%s*(.-)%s*$', '%1')
	cpu_arc.value = math.floor(100 - cpu_idle)
end)

cpu_arc:connect_signal("signals::cpu", function(value) 
    cpu_arc.value = value
    value.markup = value
 end)

return cpu_arc
