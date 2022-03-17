local awful = require "awful"
local beautiful = require "beautiful"
local rubato = require "lib.rubato"
local wibox = require "wibox"
local helpers = require "helpers"
local gears = require "gears"

local function create_boxed_widget(widget_to_be_boxed, width, height, inner_pad)
    local box_container = wibox.container.background()
    box_container.bg = beautiful.bg_normal
    box_container.forced_height = height
    box_container.forced_width = width
    box_container.shape = helpers.rrect(beautiful.tooltip_box_border_radius)

    local inner = dpi(0)

    if inner_pad then inner = beautiful.tooltip_box_margin end

    local boxed_widget = wibox.widget {
        -- Add margins
        {
            -- Add background color
            {
                -- The actual widget goes here
                widget_to_be_boxed,
                margins = inner,
                widget = wibox.container.margin
            },
            widget = box_container,
        },
        margins = beautiful.tooltip_gap / 2,
        color = "#FF000000",
        widget = wibox.container.margin
    }

    return boxed_widget
end


local shutdown = wibox.widget {
	markup = helpers.colorize_text("", beautiful.xforeground),
	font = beautiful.font_name .. "25",
	halign = "center",
	valign = "center",
	widget = wibox.widget.textbox
}

shutdown:buttons(gears.table.join(
	awful.button({}, 1, function()
		awful.spawn("systemctl poweroff")
	end)
))

local shutdown_boxed = wibox.widget {
	{
		shutdown,
		margins = 28,
		widget = wibox.container.margin
	},
	shape = helpers.rrect(beautiful.tooltip_box_border_radius),
	forced_width = 86,
	forced_height = 86,
	widget = wibox.container.background,
}

shutdown_boxed:connect_signal("mouse::enter", function()
	shutdown_boxed.bg = beautiful.bg_secondary
end)

shutdown_boxed:connect_signal("mouse::leave", function()
	shutdown_boxed.bg = beautiful.transparent
end)

local reboot = wibox.widget {
	markup = helpers.colorize_text("", beautiful.xforeground),
	font = beautiful.font_name .. "25",
	halign = "center",
	valign = "center",
	widget = wibox.widget.textbox
}

reboot:buttons(gears.table.join(
	awful.button({}, 1, function()
		awful.spawn("systemctl reboot")
	end)
))

local reboot_boxed = wibox.widget {
	{
		reboot,
		margins = 28,
		widget = wibox.container.margin
	},
	shape = helpers.rrect(beautiful.tooltip_box_border_radius),
	forced_width = 86,
	forced_height = 86,
	widget = wibox.container.background,
}

reboot_boxed:connect_signal("mouse::enter", function()
	reboot_boxed.bg = beautiful.bg_secondary
end)

reboot_boxed:connect_signal("mouse::leave", function()
	reboot_boxed.bg = beautiful.transparent
end)

local suspend = wibox.widget {
	markup = helpers.colorize_text("", beautiful.xforeground),
	font = beautiful.font_name .. "25",
	halign = "center",
	valign = "center",
	widget = wibox.widget.textbox
}

suspend:buttons(gears.table.join(
	awful.button({}, 1, function()
		awful.spawn("betterlockscreen -l")
		toggle_menu()
	end)
))

local suspend_boxed = wibox.widget {
	{
		suspend,
		margins = 28,
		widget = wibox.container.margin
	},
	shape = helpers.rrect(beautiful.tooltip_box_border_radius),
	forced_width = 86,
	forced_height = 86,
	widget = wibox.container.background,
}

suspend_boxed:connect_signal("mouse::enter", function()
	suspend_boxed.bg = beautiful.bg_secondary
end)

suspend_boxed:connect_signal("mouse::leave", function()
	suspend_boxed.bg = beautiful.transparent
end)

local logout = wibox.widget {
	markup = helpers.colorize_text("", beautiful.xforeground),
	font = beautiful.font_name .. "22",
	halign = "center",
	valign = "center",
	widget = wibox.widget.textbox
}

logout:buttons(gears.table.join(
	awful.button({}, 1, function()
		awful.spawn("kill -9 -1")
	end)
))

local logout_boxed = wibox.widget {
	{
		logout,
		margins = 28,
		widget = wibox.container.margin
	},
	shape = helpers.rrect(beautiful.tooltip_box_border_radius),
	forced_width = 86,
	forced_height = 86,
	widget = wibox.container.background,
}

logout_boxed:connect_signal("mouse::enter", function()
	logout_boxed.bg = beautiful.bg_secondary
end)

logout_boxed:connect_signal("mouse::leave", function()
	logout_boxed.bg = beautiful.transparent
end)

local powermenu = awful.popup {
	widget = {
		widget = wibox.container.margin,
		margins = 7,
		forced_width = 100,
		forced_height = 364,
		{
			layout = wibox.layout.fixed.vertical,
			spacing = 2,
			shutdown_boxed,
			reboot_boxed,
			suspend_boxed,
			logout_boxed,
		},
	},
	placement = awful.placement.no_offscreen,
	ontop = true,
	visible = false,
	bg = beautiful.bg_normal,
	border_color = beautiful.bg_normal,
	border_width = 0,
}

local slide = rubato.timed {
	pos = -50,
	rate = 60,
	intro = 0.1,
	duration = 0.2,
	easing = rubato.quadratic,
	awestore_compat = true,
	subscribed = function(pos)
		powermenu.x = pos
		powermenu.y = 696
	end,
}

local powermenu_status = false

slide.ended:subscribe(function()
	if powermenu_status then
		powermenu.visible = false
	end
end)

local function menu_show()
	powermenu.visible = true
	slide:set(dpi(68))
	powermenu_status = false
end

local function menu_hide()
	slide:set(-100)
	powermenu_status = true
end

function toggle_menu()
	if powermenu.visible then
		menu_hide()
	else
		menu_show()
	end
end
