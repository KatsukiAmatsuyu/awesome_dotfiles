-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")

-- Widget library
local wibox = require("wibox")

-- rubato
local rubato = require("lib.rubato")

-- Helpers
local helpers = require("helpers")

-- Get screen geometry
local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height

local volume = require("misc.volume")


-- Tooltip
------------

-- Helpers
local function create_boxed_widget(widget_to_be_boxed, width, height, inner_pad)
    local box_container = wibox.container.background()
    box_container.bg = beautiful.tooltip_box_bg
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


---- Stats

-- Wifi
local wifi_text = wibox.widget{
    markup = helpers.colorize_text("WiFi", beautiful.xcolor8),
    font = beautiful.font_name .. "14",
    widget = wibox.widget.textbox
}

local wifi_ssid = wibox.widget{
    markup = "Offline",
    font = beautiful.font_name .. "bold 20",
    valign = "bottom",
    widget = wibox.widget.textbox
}

local wifi = wibox.widget{
    wifi_text,
    nil,
    wifi_ssid,
    layout = wibox.layout.align.vertical
}

awesome.connect_signal("signal::network", function(status, ssid)
    wifi_ssid.markup = ssid
end)

-- Volume 
-- local vol_text = wibox.widget{
	-- markup = helpers.colorize_text("Volume", beautifu.xcolor8),
	-- font = beautiful.font_name .. "10",
	-- valign = "center",
	-- widget = wibox.widget.textbox
-- }

-- local vol_perc = wibox.widget{
	-- markup = "N/A"
	-- font = beautiful.font_name .. "bold 12",
	-- valign = "center",
	-- widget = wibox.widget.textbox
-- }

-- local vol = wibox.widget{
	-- vol_text,
	-- nil,
	-- vol_perc,
	-- layout = wibox.layout.align.vertical
-- }

-- awesome.connect_signal("signal::volume", function(value, muted)
	-- local vol_value = value or 0
	-- local v = tostring(vol_value) + "%"

	-- if muted then
		-- v = "Muted"
	-- end

	-- vol_perc.markup = v
-- end)

-- Battery
local batt_text = wibox.widget{
    markup = helpers.colorize_text("Battery", beautiful.xcolor8),
    font = beautiful.font_name .. "14",
    valign = "center",
    widget = wibox.widget.textbox
}

local batt_perc = wibox.widget{
    markup = "N/A",
    font = beautiful.font_name .. "bold 18",
    valign = "center",
    widget = wibox.widget.textbox
}

local batt_bar = wibox.widget {
    max_value = 100,
    value = 20,
    background_color = beautiful.transparent,
    color = beautiful.xcolor0,
    widget = wibox.widget.progressbar
}

local batt = wibox.widget{
    batt_bar,
    {
        {
            batt_text,
            nil,
            batt_perc,
            -- spacing = dpi(5),
            layout = wibox.layout.align.vertical
        },
        margins = beautiful.tooltip_box_margin,
        widget = wibox.container.margin
    },
    layout = wibox.layout.stack
}

local batt_val = 0
local batt_charger

awesome.connect_signal("signal::battery", function(value)
    batt_val = value
    awesome.emit_signal("widget::battery")
end)

awesome.connect_signal("signal::charger", function(state)
    batt_charger = state
    awesome.emit_signal("widget::battery")
end)

awesome.connect_signal("widget::battery", function()
    local b = batt_val
    local fill_color = beautiful.bg_accent

    if batt_charger then
        fill_color = beautiful.xcolor2 .. "33"
    else
        if batt_val <= 15 then
            fill_color = beautiful.xcolor1 .. "33"
        end
    end

    batt_perc.markup = b .. "%"
    batt_bar.value = b
    batt_bar.color = fill_color
end)

-- Music
local wifi_boxed = create_boxed_widget(wifi, dpi(180), dpi(85), true)
local batt_boxed = create_boxed_widget(batt, dpi(80), dpi(65))
local music_boxed = create_boxed_widget(music, dpi(160), dpi(160))
-- local vol_boxed = create_boxed_widget(vol, dpi(80), dpi(160))

-- Stats
stats_tooltip = wibox({
    type = "dock",
    screen = screen.primary,
    height = dpi(200),
    width = dpi(390),
    shape = helpers.rrect(beautiful.tooltip_border_radius - 1),
    bg = beautiful.transparent,
    ontop = true,
    visible = false
})

awful.placement.bottom_left(stats_tooltip, {honor_workarea = true, margins = {left = dpi(14), bottom = dpi(109)}})

stats_tooltip_show = function()
    stats_tooltip.visible = true
end

stats_tooltip_hide = function()
    stats_tooltip.visible = false
end

stats_tooltip:setup {
    {
        {
            {
                batt_boxed,
				wifi_boxed,
                layout = wibox.layout.fixed.vertical
            },
            music_boxed,
            layout = wibox.layout.fixed.horizontal
        },
        margins = beautiful.tooltip_margin,
        widget = wibox.container.margin
    },
    shape = helpers.rrect(beautiful.tooltip_border_radius),
    bg = beautiful.xbackground,
    widget = wibox.container.background
}


---- Calendar

-- Date
local date_day = wibox.widget{
    font = beautiful.font_name .. "14",
    format = helpers.colorize_text("%A", beautiful.xcolor8),
    widget = wibox.widget.textclock
}

local date_month = wibox.widget{
    font = beautiful.font_name .. "bold 20",
    format = "%d %B",
    widget = wibox.widget.textclock
}

local date = wibox.widget{
    date_day,
    nil,
    date_month,
    layout = wibox.layout.align.vertical
}

-- Time
local time_hour = wibox.widget{
    font = beautiful.font_name .. "bold 24",
    format = "%I",
    align = "center",
    widget = wibox.widget.textclock
}

local time_min = wibox.widget{
    font = beautiful.font_name .. "bold 24",
    format = "%M",
    align = "center",
    widget = wibox.widget.textclock
}

local time_eq = wibox.widget{
    font = beautiful.font_name .. "bold 16",
    format = "%p",
    align = "center",
    widget = wibox.widget.textclock
}

-- Weather
local weather_icon = wibox.widget{
    markup = "",
    font = "icomoon 22",
    align = "center",
    widget = wibox.widget.textbox
}

local weather_temp = wibox.widget{
    markup = "25°C",
    font = beautiful.font_name .. "bold 16",
    align = "center",
    valign = "bottom",
    widget = wibox.widget.textbox
}

local weather = wibox.widget{
    weather_icon,
    nil,
    weather_temp,
    layout = wibox.layout.align.vertical
}

awesome.connect_signal("signal::weather", function(temperature, _, icon_widget)
    local weather_temp_symbol
    if weather_units == "metric" then
        weather_temp_symbol = "°C"
    elseif weather_units == "imperial" then
        weather_temp_symbol = "°F"
    end

    weather_icon.markup = icon_widget
    weather_temp.markup = temperature .. weather_temp_symbol
end)

-- Widget
local date_boxed = create_boxed_widget(date, dpi(110), dpi(90), true)
local hour_boxed = create_boxed_widget(time_hour, dpi(80), dpi(60), true)
local min_boxed = create_boxed_widget(time_min, dpi(80), dpi(60), true)
local eq_boxed = create_boxed_widget(time_eq, dpi(90), dpi(40), true)
local weather_boxed = create_boxed_widget(weather, dpi(90), dpi(110), true)

-- Stats
cal_tooltip = wibox({
    type = "dock",
    screen = screen.primary,
    height = dpi(200),
    width = dpi(300),
    shape = helpers.rrect(beautiful.tooltip_border_radius - 1),
    bg = beautiful.transparent,
    ontop = true,
    visible = false
})

awful.placement.bottom_left(cal_tooltip, {honor_workarea = true, margins = {left = dpi(14), bottom = dpi(12)}})

cal_tooltip_show = function()
    cal_tooltip.visible = true
end

cal_tooltip_hide = function()
    cal_tooltip.visible = false
end

cal_tooltip:setup {
    {
        {
            {
                date_boxed,
                {
                    hour_boxed,
                    min_boxed,
                    layout = wibox.layout.fixed.horizontal
                },
                layout = wibox.layout.fixed.vertical
            },
            {
                weather_boxed,
                eq_boxed,
                layout = wibox.layout.fixed.vertical
            },
            layout = wibox.layout.fixed.horizontal
        },
        margins = beautiful.tooltip_margin,
        widget = wibox.container.margin
    },
    shape = helpers.rrect(beautiful.tooltip_border_radius),
    bg = beautiful.xbackground,
    widget = wibox.container.background
}
