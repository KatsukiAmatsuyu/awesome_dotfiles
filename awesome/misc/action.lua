local awful = require "awful"
local beautiful = require "beautiful"
local gears = require "gears"
local naughty = require "naughty"
local rubato = require "lib.rubato"
local wibox = require "wibox"
local helpers = require "helpers"

F.action = {}

local function format_progress_bar(bar, image)
        local image = wibox.widget {
            image = image,
            widget = wibox.widget.imagebox,
            resize = true
        }
        image.forced_height = 10
        image.forced_width = 10

        local w = wibox.widget {
            {
                image,
                margins = dpi(32),
                widget = wibox.container.margin
            }, 
            bar, 
            layout = wibox.layout.stack,
        }
       return w
   end 

local function create_boxed_widget(widget_to_be_boxed, width, height, radius, bg_color)
        local box_container = wibox.container.background()
        box_container.bg = bg_color
        box_container.forced_height = height
        box_container.forced_width = width
        box_container.shape = helpers.rrect(radius)
        -- box_container.border_width = beautiful.widget_border_width
        -- box_container.border_width = 0
        -- box_container.border_color = beautiful.bg_normal

        local boxed_widget = wibox.widget {
            {
                {
                    nil,
                    {
                        nil,
                        widget_to_be_boxed,
                        layout = wibox.layout.align.vertical,
                        expand = "none"
                    },
                    layout = wibox.layout.align.horizontal
                },
                widget = box_container
            },
            margins = box_gap,
            color = "#FF000000",
            widget = wibox.container.margin
        }
        return boxed_widget
    end

local notifs_text = wibox.widget {
  font = beautiful.font_name .. " Bold 13",
  markup = "Notifications",
  halign = "center",
  widget = wibox.widget.textbox,
}

local notifs_clear = wibox.widget {
  markup = "<span foreground='" .. beautiful.xforeground .. "'>x</span>",
  font = beautiful.font_name .. " Bold 13",
  align = "center",
  valign = "center",
  widget = wibox.widget.textbox,
}

notifs_clear:buttons(gears.table.join(awful.button({}, 1, function()
  _G.notif_center_reset_notifs_container()
end)))

local notifs_empty = wibox.widget {
  {
    nil,
    {
      nil,
      {
        markup = "<span foreground='" .. beautiful.xforeground .. "'>No Notifications</span>",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
      },
      layout = wibox.layout.align.vertical,
    },
    layout = wibox.layout.align.horizontal,
  },
  forced_height = 160,
  widget = wibox.container.background,
}

local notifs_container = wibox.widget {
  spacing = 10,
  spacing_widget = {
    {
      shape = gears.shape.rounded_rect,
      widget = wibox.container.background,
    },
    top = 2,
    bottom = 2,
    left = 6,
    right = 6,
    widget = wibox.container.margin,
  },
  forced_width = beautiful.notifs_width or 240,
  forced_height = 730,
  layout = wibox.layout.fixed.vertical,
}

local remove_notifs_empty = true

notif_center_reset_notifs_container = function()
  notifs_container:reset(notifs_container)
  notifs_container:insert(1, notifs_empty)
  remove_notifs_empty = true
end

notif_center_remove_notif = function(box)
  notifs_container:remove_widgets(box)

  if #notifs_container.children == 0 then
    notifs_container:insert(1, notifs_empty)
    remove_notifs_empty = true
  end
end

local create_notif = function(icon, n, width)
  local time = os.date "%H:%M"
  local box = {}

  box = wibox.widget {
    {
      {
        {
          {
            image = icon,
            resize = true,
            clip_shape = function(cr, width, height)
              gears.shape.rounded_rect(cr, width, height, 7)
            end,
            halign = "center",
            valign = "center",
            widget = wibox.widget.imagebox,
          },
          strategy = "exact",
          height = 50,
          width = 50,
          widget = wibox.container.constraint,
        },
        {
          {
            nil,
            {
              {
                {
                  step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
                  speed = 50,
                  {
                    markup = n.title,
                    font = beautiful.font_name .. " Bold 12",
                    align = "left",
                    widget = wibox.widget.textbox,
                  },
                  forced_width = 140,
                  widget = wibox.container.scroll.horizontal,
                },
                nil,
                {
                  markup = "<span foreground='" .. beautiful.xforeground .. "'>" .. time .. "</span>",
                  align = "right",
                  valign = "bottom",
                  font = beautiful.font,
                  widget = wibox.widget.textbox,
                },
                expand = "none",
                layout = wibox.layout.align.horizontal,
              },
              {
                markup = n.message,
                align = "left",
                forced_width = 165,
                widget = wibox.widget.textbox,
              },
              spacing = 3,
              layout = wibox.layout.fixed.vertical,
            },
            expand = "none",
            layout = wibox.layout.align.vertical,
          },
          left = 10,
          widget = wibox.container.margin,
        },
        layout = wibox.layout.align.horizontal,
      },
      margins = 15,
      widget = wibox.container.margin,
    },
    forced_height = 85,
    widget = wibox.container.background,
    bg = beautiful.bg_secondary,
  }

  box:buttons(gears.table.join(awful.button({}, 1, function()
    _G.notif_center_remove_notif(box)
  end)))

  return box
end

notifs_container:buttons(gears.table.join(
  awful.button({}, 4, nil, function()
    if #notifs_container.children == 1 then
      return
    end
    notifs_container:insert(1, notifs_container.children[#notifs_container.children])
    notifs_container:remove(#notifs_container.children)
  end),

  awful.button({}, 5, nil, function()
    if #notifs_container.children == 1 then
      return
    end
    notifs_container:insert(#notifs_container.children + 1, notifs_container.children[1])
    notifs_container:remove(1)
  end)
))

notifs_container:insert(1, notifs_empty)

naughty.connect_signal("request::display", function(n)
  if #notifs_container.children == 1 and remove_notifs_empty then
    notifs_container:reset(notifs_container)
    remove_notifs_empty = false
  end

  local appicon = n.icon or n.app_icon
  if not appicon then
    appicon = beautiful.notification_icon
  end

  notifs_container:insert(1, create_notif(appicon, n, width))
end)

local notifs = wibox.widget {
  {
    {
      nil,
      notifs_text,
      notifs_clear,
      expand = "none",
      layout = wibox.layout.align.horizontal,
    },
    left = 5,
    right = 5,
    layout = wibox.container.margin,
  },
  notifs_container,
  spacing = 20,
  layout = wibox.layout.fixed.vertical,
}

local actions = wibox.widget {
  {
    {
      {
        {
          widget = require "misc.widget.vol_slider",
        },
        {
          widget = require "misc.widget.bri_slider",
        },
        layout = wibox.layout.flex.vertical,
        spacing = 10,
      },
      {
        { widget = require "misc.controls.wifi" },
        { widget = require "misc.controls.bluetooth" },
        { widget = require "misc.controls.dnd" },
        { widget = require "misc.controls.night_light" },
        layout = wibox.layout.flex.horizontal,
        spacing = 15,
      },
      layout = wibox.layout.flex.vertical,
      spacing = 20,
    },
    widget = wibox.container.margin,
    top = 20,
    bottom = 20,
    left = 35,
    right = 35,
  },
  widget = wibox.container.background,
  bg = beautiful.bg_secondary,
  forced_height = 220,
  shape = helpers.rrect(beautiful.tooltip_box_border_radius),
}

local player = require("misc.controls.playerctl")

-- local playerctl_box = wibox.widget {
	-- {
		-- playerctl,
		-- top = 20,
		-- bottom = 20,
		-- left = 35,
		-- right = 35,
		-- widget = wibox.container.margin,
	-- },
	-- shape = helpers.rrect(beautiful.tooltip_box_border_radius),
	-- bg = beautiful.bg_secondary,
	-- forced_height = 150,
	-- widget = wibox.container.background,
-- }

local ram_bar = require("misc.controls.ram_arc")
local ram = format_progress_bar(ram_bar, colorize_icon(beautiful.ram, beautiful.fg_normal))

    local ram_details = wibox.widget {
        -- {
            -- {
                -- markup = helpers.colorize_text("Ram", beautiful.fg_normal),
				-- font = beautiful.font_name .. "15",
                -- widget = wibox.widget.textbox
            -- },
            -- left = dpi(20),
            -- top = dpi(20),
            -- widget = wibox.container.margin
        -- },
        {
            ram,
			margins = 15,
            -- left = dpi(50),
            -- bottom = dpi(15),
            -- right = dpi(20),
            -- top = dpi(10),
            widget = wibox.container.margin
        },
        layout = wibox.layout.fixed.vertical
    }

local ram_box = create_boxed_widget(ram_details, 120, 120, dpi(7), beautiful.bg_secondary)

local cpu_bar = require("misc.controls.cpu_arc")
local cpu = format_progress_bar(cpu_bar, colorize_icon(beautiful.cpu, beautiful.fg_normal))

    local cpu_details = wibox.widget {
        -- {
            -- {
                -- markup = helpers.colorize_text("Ram", beautiful.fg_normal),
				-- font = beautiful.font_name .. "15",
                -- widget = wibox.widget.textbox
            -- },
            -- left = dpi(20),
            -- top = dpi(20),
            -- widget = wibox.container.margin
        -- },
        {
            cpu,
			margins = 15,
            -- left = dpi(50),
            -- bottom = dpi(15),
            -- right = dpi(20),
            -- top = dpi(10),
            widget = wibox.container.margin
        },
        layout = wibox.layout.fixed.vertical
    }

local cpu_box = create_boxed_widget(cpu_details, 120, 120, dpi(7), beautiful.bg_secondary)

local temp_bar = require("misc.controls.temp_arc")
local temp = format_progress_bar(temp_bar, colorize_icon(beautiful.temp, beautiful.xforeground))

    local temp_details = wibox.widget {
        -- {
            -- {
                -- markup = helpers.colorize_text("Ram", beautiful.fg_normal),
				-- font = beautiful.font_name .. "15",
                -- widget = wibox.widget.textbox
            -- },
            -- left = dpi(20),
            -- top = dpi(20),
            -- widget = wibox.container.margin
        -- },
        {
            temp,
			margins = 15,
            -- left = dpi(50),
            -- bottom = dpi(15),
            -- right = dpi(20),
            -- top = dpi(10),
            widget = wibox.container.margin
        },
        layout = wibox.layout.fixed.vertical
    }

local temp_box = create_boxed_widget(temp_details, 120, 120, dpi(7), beautiful.bg_secondary)

local action = awful.popup {
  widget = {
    widget = wibox.container.margin,
    margins = 30,
    forced_width = 450,
	forced_height = 560,
    {
      layout = wibox.layout.fixed.vertical,
      -- notifs,
	  {
		ram_box,
		cpu_box,
		temp_box,
		spacing = 15,
		layout = wibox.layout.fixed.horizontal,
	},
	  player,
      actions,
	  spacing = 10,
    },
  },
  placement = function(c)
	awful.placement.no_offscreen(c)
  end,
  ontop = true,
  visible = false,
  bg = beautiful.bg_normal,
  border_color = beautiful.bg_normal,
  border_width = 0,
  y = 500,
  x = 68,
}

local slide = rubato.timed {
  pos = -450,
  rate = 60,
  intro = 0.1,
  duration = 0.2,
  easing = rubato.quadratic,
  awestore_compat = true,
  subscribed = function(pos)
    action.x = pos
	action.y = 500
  end,
}

local action_status = false

slide.ended:subscribe(function()
  if action_status then
    action.visible = false
  end
end)

local function action_show()
  action.visible = true
  -- update_pos()
  slide:set(68)
  -- action.x = 68
  action_status = false
end

local function action_hide()
  -- action.visible = false
  -- update_pos()
  slide:set(-450)
  action_status = true
end

function update_pos()
	action.x = 68
	action.y = 630
end

function toggle_action()
  if action.visible then
    action_hide()
  else
    action_show()
  end
end
