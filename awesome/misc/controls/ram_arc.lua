local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local awful = require("awful")

local active_color = beautiful.arc_color

local ram_arc = wibox.widget {
    max_value = 100,
    thickness = 11,
    start_angle = 4.3,
    rounded_edge = true,
    bg = beautiful.bg_normal,
    paddings = dpi(10),
    colors = active_color,
    widget = wibox.container.arcchart
}

local total, used

local function getPerc(v)
	return math.floor(v / total * 100 + 0.5)
end

awful.widget.watch('bash -c "LANGUAGE=en_US.UTF-8 free | grep -z Mem.*"', timeout,
	function(widget, stdout)
		total, used = stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)')
		ram_arc.value = getPerc(used)
	end,
	ram_arc
)

awesome.connect_signal("signals::ram", function(used, total)
    local used_ram_percentage = (used / total) * 100
    ram_arc.value = used_ram_percentage
end)

return ram_arc
