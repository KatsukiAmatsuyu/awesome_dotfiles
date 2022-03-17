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

local volume = require("misc.volume")

require "misc.power"

-- Bar
--------

local function boxed_widget(widget)
    local boxed = wibox.widget{
        {
            widget,
            left = dpi(12),
            right = dpi(12),
            widget = wibox.container.margin
        },
        bg = beautiful.xcolor0,
        shape = helpers.rrect(dpi(5)),
        widget = wibox.container.background
    }

    return boxed
end


awful.screen.connect_for_each_screen(function(s)

	if s.index == 1 then

    -- Tasklist
    s.mytasklist = awful.widget.tasklist {
        screen   = s,
        filter   = awful.widget.tasklist.filter.currenttags,
        buttons  = keys.tasklistbuttons,
        layout   = {
            spacing = dpi(3),
            spacing_widget = {
                widget = wibox.container.background
            },
            layout = wibox.layout.fixed.vertical
        },
        widget_template = {
            {
                {
                    {
                        id     = 'clienticon',
                        widget = awful.widget.clienticon
                    },
                    margins = dpi(8),
                    widget  = wibox.container.margin
                },
                id            = 'background_role',
                widget        = wibox.container.background
            },
            create_callback = function(self, c, index, objects) --luacheck: no unused args
                self:get_children_by_id('clienticon')[1].client = c

                -- BLING: Toggle the popup on hover and disable it off hover
                self:connect_signal('mouse::enter', function()
                        awesome.emit_signal("bling::task_preview::visibility", s,
                                            true, c)
                    end)
                    self:connect_signal('mouse::leave', function()
                        awesome.emit_signal("bling::task_preview::visibility", s,
                                            false, c)
                    end)
            end,
            shape = helpers.rrect(dpi(5)),
            widget = wibox.container.background
        }
    }

    local tasklist = wibox.widget {
        s.mytasklist,
        -- bg = beautiful.xcolor0,
        -- shape = helpers.rrect(dpi(5)),
        widget = wibox.container.background
    }

    -- Layoutbox
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(keys.layoutboxbuttons)

    local layoutbox = wibox.widget{
        s.mylayoutbox,
        margins = dpi(12),
        widget = wibox.container.margin
    }

	s.mytaglist = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		-- style = { shape = gears.shape.sircle },
		style = { shape = helpers.rrect(beautiful.tooltip_box_border_radius) },
		layout = {
			spacing = 5,
			-- spacing_widget = {
				-- widget = wibox.container.background
			-- },
			layout = wibox.layout.fixed.vertical
		},
		widget_template = {
			{
				{
					id = "text_role",
					widget = wibox.widget.textbox,
					align = "center",
					valign = "center",
				},
				margins = 2,
				widget = wibox.container.margin,
			},
			id = "background_role",
			widget = wibox.container.background,
		},
		buttons = keys.taglistbuttons
	}

	local taglist = wibox.widget{
		s.mytaglist,
		widget = wibox.container.background
	}

    -- Start
    local start = wibox.widget{
        markup = "",
        font = beautiful.icon_font_name .. "Round 14",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    start:buttons(gears.table.join(
        awful.button({}, 1, function ()
            awful.spawn(launcher)
        end)
    ))

    -- Wifi
    local wifi = wibox.widget{
        markup = "",
        font = beautiful.icon_font_name .. "Round 16",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

	wifi:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.spawn("sh /home/katsuki/.config/rofi/wifi/wifi")
		end)
	))

    awesome.connect_signal("signal::network", function(status, _)
        local w = ""

        if status then
            w = ""
        end

        wifi.markup = w
    end)

	-- Keyboard layout
	local kblayout = wibox.widget{
		markup = helpers.colorize_text("", beautiful.xcolor1),
        align = "center",
        valign = "center",
		forced_width = dpi(50),
        widget = awful.widget.keyboardlayout
	}

	local kbl = wibox.widget{
		kblayout,
		left = dpi(5),
		right = dpi(5),
		top = 0,
		bottom = 0,
		widget = wibox.container.margin
	}

	-- Volume 
	
	-- Power button
	local pbtn = wibox.widget{
		markup = "",
		align = "center",
		valign = "center",
		font = "Font Awesome 6 Free Solid 10",
		widget = wibox.widget.textbox
	}

	-- pbtn:buttons(gears.table.join(
		-- awful.button({}, 1, function()
			-- awful.spawn("sh /home/katsuki/scripts/rofi/launch.sh powermenu")
		-- end)
	-- ))

	pbtn:buttons(gears.table.join(
		awful.button({}, 1, function()
			toggle_menu()
		end)
	))

	local powerbutton = wibox.widget{
		pbtn,
		margins = dpi(8),
		widget = wibox.container.margin
	}

	local dashb = wibox.widget {
		markup = "",
		align = "center",
		valign = "center",
		font = "Font Awesome 6 Free Solid 11",
		widget = wibox.widget.textbox
	}

	dashb:buttons(gears.table.join(
		awful.button({}, 1, function()
			toggle_action()
		end)
	))

	local dshb = wibox.widget {
		dashb,
		margins = 8,
		widget = wibox.container.margin
	}
	
    -- Battery
    local batt = wibox.widget{
        markup = helpers.colorize_text("", beautiful.xcolor1),
        font = beautiful.icon_font_name .. "Round 16",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
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
        local b = ""
        local fill_color = beautiful.xforeground

        if batt_val >= 88 and batt_val <= 100 then
            b = ""
        elseif batt_val >= 76 and batt_val < 88 then
            b = ""
        elseif batt_val >= 64 and batt_val < 76 then
            b = ""
        elseif batt_val >= 52 and batt_val < 64 then
            b = ""
        elseif batt_val >= 40 and batt_val < 52 then
            b = ""
        elseif batt_val >= 28 and batt_val < 40 then
            b = ""
        elseif batt_val >= 16 and batt_val < 28 then
            b = ""
        else
            b = ""
        end

        if batt_charger then
            fill_color = beautiful.xcolor2 .. "d5"
        else
            if batt_val <= 15 then
                fill_color = beautiful.xcolor1
            end
        end

        batt.markup = helpers.colorize_text(b, fill_color)
    end)

    local stats = wibox.widget {
        {
            {
				kbl,
                wifi,
                vol,
                batt,
                spacing = dpi(18),
                layout = wibox.layout.fixed.vertical
            },
            top = dpi(8),
            bottom = dpi(8),
            widget = wibox.container.margin
        },
        shape = helpers.rrect(dpi(5)),
        widget = wibox.container.background
    }

    stats:connect_signal("mouse::enter", function()
        stats.bg = beautiful.bg_secondary
        stats_tooltip.visible = true
    end)

    stats:connect_signal("mouse::leave", function()
        stats.bg = beautiful.transparent
        stats_tooltip.visible = false
    end)

    -- Time
    local time_hour = wibox.widget{
        font = beautiful.font_name .. "bold 14",
        format = "%H",
        align = "center",
        valign = "center",
        widget = wibox.widget.textclock
    }

    local time_min = wibox.widget{
        font = beautiful.font_name .. "bold 14",
        format = "%M",
        align = "center",
        valign = "center",
        widget = wibox.widget.textclock
    }

    local time = wibox.widget{
        time_hour,
        time_min,
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical
    }

    time:connect_signal("mouse::enter", function()
        time.bg = beautiful.bg_secondary
        cal_tooltip_show()
    end)

    time:connect_signal("mouse::leave", function()
        time.bg = beautiful.transparent
        cal_tooltip_hide()
    end)

    -- Separator
    local separator = wibox.widget {
        color = beautiful.separator_color,
        forced_height = dpi(2),
        shape = gears.shape.rounded_bar,
        widget = wibox.widget.separator
    }

    -- Wibar
    s.mywibar = awful.wibar({
        type = "dock",
        screen = s,
        position = beautiful.wibar_pos,
        visible = true
    })

    -- Add widgets to wibar
    s.mywibar:setup{
        {
            {
                start,
				taglist,
                tasklist,
                spacing = dpi(10),
                layout = wibox.layout.fixed.vertical
            },
			nil,
            {
                stats,
                separator,
                time,
                separator,
                layoutbox,
				separator,
				dshb,
				separator,
				powerbutton,
                spacing = dpi(10),
                layout = wibox.layout.fixed.vertical
            },
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        left = dpi(4),
        right = dpi(4),
        top = dpi(10),
        bottom = dpi(10),
        widget = wibox.container.margin
    }
	end
end)

