local awful = require "awful"
local beautiful = require "beautiful"
local gears = require "gears"
local wibox = require "wibox"
local helpers = require "helpers"
local bling = require "lib.bling"
local playerctl = bling.signal.playerctl.lib()

local music_art = wibox.widget {
	image = gears.filesystem.get_configuration_dir() .. "theme/assets/icons/no_music.png",
	resize = true,
	opacity = 1,
	valign = "center",
	align = "center",
	forced_height = 110,
	forced_width = 110,
	clip_shape = helpers.rrect(beautiful.tooltip_box_border_radius),
	widget = wibox.widget.imagebox
}

local music_text = wibox.widget {
	markup = helpers.colorize_text("Nothing Playing", beautiful.xforeground),
	font = beautiful.font_name .. "12",
	valign = "center",
	widget = wibox.widget.textbox
}

local music_title = wibox.widget {
	markup = helpers.colorize_text("No Title", beautiful.xforeground),
	font = beautiful.font_name .. "bold 16",
	valign = "center",
	widget = wibox.widget.textbox
}

local music_artist = wibox.widget {
	markup = helpers.colorize_text("No Artist", beautiful.xforeground),
	font = beautiful.font_name .. "bold 10",
	valign = "center",
	widget = wibox.widget.textbox
}

local prv = wibox.widget {
	markup = helpers.colorize_text("", beautiful.xforeground),
	font = beautiful.font_name .. "24",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox
}

local prev = wibox.widget {
	prv,
	forced_width = 40,
	forced_heigth = 40,
	widget = wibox.container.background
}

prev:buttons(gears.table.join(
	awful.button({}, 1, function()
		playerctl:previous()
	end)
))

local nxt = wibox.widget {
	markup = helpers.colorize_text("", beautiful.xforeground),
	font = beautiful.font_name .. "24",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox
}

local next = wibox.widget {
	nxt,
	forced_width = 60,
	forced_heigth = 40,
	widget = wibox.container.background
}

next:buttons(gears.table.join(
	awful.button({}, 1, function()
		playerctl:next()
	end)
))

local plp = wibox.widget {
	markup = helpers.colorize_text("", beautiful.xforeground),
	font = beautiful.font_name .. "24",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox
}

local play_pause = wibox.widget {
	plp,
	forced_width = 60,
	forced_heigth = 30,
	widget = wibox.container.background
}

play_pause:buttons(gears.table.join(
	awful.button({}, 1, function()
		playerctl:play_pause()
	end)
))

local control = wibox.widget {
	prev,
	play_pause,
	next,
	layout = wibox.layout.fixed.horizontal
}

local player = wibox.widget {
	{
		{
			music_art,
			top = 20,
			bottom = 20,
			left = 35,
			right = 15,
			widget = wibox.container.margin,
		},
		{
			{
				{
					music_text,
					{
						layout = wibox.container.scroll.horizontal,
						step_function = wibox.container.scroll.step_functions
						    .waiting_nonlinear_back_and_forth,
						speed = 50,
						{
							widget = music_title,
						},
					},
					{
						layout = wibox.container.scroll.horizontal,
						step_function = wibox.container.scroll.step_functions
						    .waiting_nonlinear_back_and_forth,
						speed = 50,
						{
							widget = music_artist,
						},
					},
					layout = wibox.layout.fixed.vertical,
				},
				nil,
				{
					nil,
					control,
					nil,
					expand = "none",
					layout = wibox.layout.align.horizontal,
				},
				layout = wibox.layout.align.vertical,
			},
			top = 25,
			bottom = 25,
			right = 35,
			left = 5,
			widget = wibox.container.margin,
		},
		layout = wibox.layout.fixed.horizontal,
	},
	shape = helpers.rrect(beautiful.tooltip_box_border_radius),
	bg = beautiful.bg_secondary,
	forced_height = 160,
	widget = wibox.container.background,
}

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
		plp:set_markup_silently(helpers.colorize_text("", beautiful.xforeground))
		-- play_pause.forced_width = 60
    else
        music_text:set_markup_silently(helpers.colorize_text("Music", beautiful.xforeground))
		plp:set_markup_silently(helpers.colorize_text("", beautiful.xforeground))
		-- play_pause.forced_width = 50
    end
end)

return player
