-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")

-- Widget library
local wibox = require("wibox")

-- Helpers
local helpers = require("helpers")

-- Keys
local keys = require("main.keys")

vol = wibox.widget{
	markup = "",
	font = beautiful.icon_font_name .. "Round 16",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox
}

-- Bar widget

vol:buttons(gears.table.join(
awful.button({}, 1, function ()
	helpers.volume_control(0)
end),
awful.button({}, 4, function ()
	helpers.volume_control(2)
end),
awful.button({}, 5, function ()
	helpers.volume_control(-2)
end)
))

local function update(widget)
	local fd = io.popen("pactl get-sink-volume @DEFAULT_SINK@ | grep -Eo -e '[0-9]%' -e '[0-9][0-9]%' -e '[0-9][0-9][0-9]%' | head -1 | grep -Eo -e '[0-9]' -e '[0-9][0-9]' -e '[0-9][0-9][0-9]'")
	local fill_color = beautiful.xcolor4
	local vol_value = tonumber(string.match(fd:read("*all"), "(%d?%d?%d)")) or 0
	fd:close()
	local v = ""
	local mt = io.popen("pactl get-sink-mute @DEFAULT_SINK@ | grep  -Eo -e yes -e no")
	local mtst = mt:read("*all")
	local muted = false

	if mtst == "yes" then
		muted = true
	else
		muted = false
	end

	if muted then
		fill_color = beautiful.xcolor8
		v = ""
	else
		if vol_value >= 60 then
			v = ""
		elseif vol_value >= 20 and vol_value < 60 then
			v = ""
		else
			v = ""
		end
		end

		widget.markup = v
end

update(vol)
-- awful.hooks.timer.register(1, function () update(vol) end)
gears.timer {
	timeout = 1,
	call_now = true,
	autostart = true,
	callback = function()
		update(vol)
	end
}

-- Tooltip widget

music_text = wibox.widget{
    markup = helpers.colorize_text("Nothing Playing", beautiful.xforeground),
    font = beautiful.font_name .. "10",
    valign = "center",
    widget = wibox.widget.textbox
}

music_art = wibox.widget {
    image = gears.filesystem.get_configuration_dir() .. "theme/assets/icons/no_music.png",
    resize = true,
    opacity = 0.5,
    halign = "center",
    valign = "center",
    widget = wibox.widget.imagebox
}

music_title = wibox.widget{
    markup = "No Title",
    font = beautiful.font_name .. "bold 12",
    valign = "center",
    widget = wibox.widget.textbox
}

music_artist = wibox.widget{
    markup = helpers.colorize_text("No Artist", beautiful.xforeground),
    font = beautiful.font_name .. "11",
    valign = "center",
    widget = wibox.widget.textbox
}

music_status = wibox.widget{
    markup = "",
    font = beautiful.icon_font_name .. "Round 18",
    align = "right",
    valign = "bottom",
    widget = wibox.widget.textbox
}

music_volume_icon = wibox.widget{
    markup = "",
    font = beautiful.icon_font_name .. "Round 14",
    valign = "bottom",
    widget = wibox.widget.textbox
}

music_volume_perc = wibox.widget{
    markup = "N/A",
    font = beautiful.font_name .. "bold 12",
    valign = "bottom",
    widget = wibox.widget.textbox
}

music_volume = wibox.widget{
    music_volume_icon,
    music_volume_perc,
    spacing = dpi(2),
    layout = wibox.layout.fixed.horizontal
}

music = wibox.widget{
    music_art,
    {
        {
            {
                music_text,
                {
                    step_function = wibox.container.scroll
                        .step_functions
                        .waiting_nonlinear_back_and_forth,
                    speed = 50,
                    {
                        widget = music_title,
                    },
                    -- forced_width = dpi(110),
                    widget = wibox.container.scroll.horizontal
                },
                {
                    step_function = wibox.container.scroll
                        .step_functions
                        .waiting_nonlinear_back_and_forth,
                    speed = 50,
                    {
                        widget = music_artist,
                    },
                    -- forced_width = dpi(110),
                    widget = wibox.container.scroll.horizontal
                },
                layout = wibox.layout.fixed.vertical
            },
            nil,
            {
                music_volume,
                nil,
                music_status,
                layout = wibox.layout.align.horizontal
            },
            layout = wibox.layout.align.vertical
        },
        margins = beautiful.tooltip_box_margin,
        widget = wibox.container.margin
    },
    layout = wibox.layout.stack
}

playerctl = require("lib.bling").signal.playerctl.lib()
playerctl:connect_signal("metadata", function(_, title, artist, album_path, __, ___, ____)
    if title == "" then title = "No Title" end
    if artist == "" then artist = "No Artist" end
    if album_path == "" then album_path = gears.filesystem.get_configuration_dir() .. "theme/assets/icons/no_music.png" end

    music_art:set_image(gears.surface.load_uncached(album_path))
    music_title:set_markup_silently(title)
    music_artist:set_markup_silently(helpers.colorize_text(artist, beautiful.xforeground))
end)

playerctl:connect_signal("playback_status", function(_, playing, __)
    if playing then
        music_text:set_markup_silently(helpers.colorize_text("Now Playing", beautiful.xforeground))
        music_status:set_markup_silently("")
    else
        music_text:set_markup_silently(helpers.colorize_text("Music", beautiful.xforeground))
        music_status:set_markup_silently("")
    end
end)



local function update_box(widget)
	local fd = io.popen("pactl get-sink-volume @DEFAULT_SINK@ | grep -Eo -e '[0-9]%' -e '[0-9][0-9]%' -e '[0-9][0-9][0-9]%' | head -1")
	local fill_color = beautiful.xcolor4
	local vol_value = fd:read("*all") or "0%"
	fd:close()
	local v = vol_value
	local mt = io.popen("pactl get-sink-mute @DEFAULT_SINK@ | grep  -Eo -e yes -e no")
	local mtst = tostring(mt:read("*all"))
	local muted = false

	if mtst == "yes" then
		muted = true
	else
		muted = false
	end

	if muted then
		v = "Muted"
	else
		v = vol_value
	end

	widget.markup = v
end

update_box(music_volume_perc)
gears.timer {
	timeout = 1,
	call_now = true,
	autostart = true,
	callback = function()
		update_box(music_volume_perc)
	end
}
