-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Theme handling library
local beautiful = require("beautiful")

-- Notifications library
local naughty = require("naughty")

-- Bling
local bling = require("lib.bling")
local playerctl = bling.signal.playerctl.lib()

-- Helpers
local helpers = require("helpers")

local keys = {}

require("misc.action")
require("misc.power")


-- Make key easier to call
----------------------------

mod = "Mod4"
alt = "Mod1"
ctrl = "Control"
shift = "Shift"


-- Global key bindings
------------------------

keys.globalkeys = gears.table.join(

---- App

    -- Terminal
    awful.key({mod}, "Return", function()
        awful.spawn(terminal)
    end,
    {description = "Spawn terminal", group = "App"}),

    -- Floating terminal
    awful.key({mod, shift}, "Return", function()
        awful.spawn(terminal, {floating = true})
    end,
    {description = "Spawn floating terminal", group = "App"}),

    -- Launcher
    -- awful.key({mod}, "a", function()
        -- awful.spawn(launcher)
    -- end,
    -- {description = "Spawn launcher", group = "App"}),

    -- Hotkeys menu
    awful.key({mod}, "\\",
        hotkeys_popup.show_help,
    {description = "Hotkeys menu", group = "App"}),


---- WM

    -- Toggle titlebar
    awful.key({mod}, "t", function()
        awful.titlebar.toggle(client.focus, beautiful.titlebar_pos)
    end,
    {description = "Toggle titlebar", group = "WM"}),

    -- Toggle titlebar (for all visible clients in selected tag)
    awful.key({mod, shift}, "t", function(c)
        local clients = awful.screen.focused().clients
        for _, c in pairs(clients) do
            awful.titlebar.toggle(c, beautiful.titlebar_pos)
        end
    end,
    {description = "Toggle all titlebar", group = "WM"}),

    -- Toggle bar
    awful.key({mod}, "b", function()
        wibar_toggle()
    end,
    {description = "Toggle bar", group = "WM"}),

    -- Restart awesome
    awful.key({mod, shift}, "r", 
        awesome.restart,
    {description = "Reload awesome", group = "WM"}),

    -- Quit awesome
    awful.key({mod, shift}, "q", 
        awesome.quit,
    {description = "Quit awesome", group = "WM"}),


---- Window

    -- Focus client by direction
    awful.key({mod}, "k", function()
        awful.client.focus.bydirection("up")
    end,
    {description = "Focus up", group = "Window"}),

    awful.key({mod}, "h", function()
        awful.client.focus.bydirection("left")
    end,
    {description = "Focus left", group = "Window"}),

    awful.key({mod}, "j", function()
        awful.client.focus.bydirection("down")
    end,
    {description = "Focus down", group = "Window"}),

    awful.key({mod}, "l", function()
        awful.client.focus.bydirection("right")
    end,
    {description = "Focus right", group = "Window"}),

    -- Resize focused client
    awful.key({mod, ctrl}, "k", function(c)
        helpers.resize_client(client.focus, "up")
    end,
    {description = "Resize to the up", group = "Window"}),

    awful.key({mod, ctrl}, "h", function(c)
        helpers.resize_client(client.focus, "left")
    end,
    {description = "Resize to the left", group = "Window"}),

    awful.key({mod, ctrl}, "j", function(c)
        helpers.resize_client(client.focus, "down")
    end,
    {description = "Resize to the down", group = "Window"}),

    awful.key({mod, ctrl}, "l", function(c)
        helpers.resize_client(client.focus, "right")
    end,
    {description = "Resize to the right", group = "Window"}),

    -- Switch to next layout
    awful.key({mod}, "space", function()
        awful.layout.inc(1)
    end,
    {description = "Switch to next layout", group = "Window"}),

    -- Switch to previous layout
    awful.key({mod, shift}, "space", function()
        awful.layout.inc(-1)
    end,
    {description = "Switch to prev layout", group = "Window"}),

    -- Un-minimize windows
    awful.key({mod, shift}, "n", function()
        local c = awful.client.restore()
        if c then
            c:activate{raise = true, context = "key.unminimize"}
        end
    end),


---- Bling

    -- Add client to tabbed layout
    awful.key({mod, shift}, "e", function()
        awesome.emit_signal("tabbed::add")
    end,
    {description = "Add client to tabbed layout", group = "Bling"}),

    -- Remove client from tabbed layout
    awful.key({mod, ctrl}, "e", function()
        awesome.emit_signal("tabbed::destroy")
    end,
    {description = "Remove client from tabbed layout", group = "Bling"}),

    -- Cycle through client in tabbed layout
    awful.key({mod}, "`", function()
        awesome.emit_signal("tabbed::cycle")
    end,
    {description = "Cycle through client in tabbed layout", group = "Bling"}),

    -- Discord scratchpad
    -- awful.key({mod}, "d", function()
        -- awesome.emit_signal("scratch::discord")
    -- end,
    -- {description = "Toggle music scratchpad", group = "Bling"}),

    -- Spotify scratchpad
    awful.key({mod}, "s", function()
        awesome.emit_signal("scratch::spotify")
    end,
    {description = "Toggle music scratchpad", group = "Bling"}),


---- Misc

    -- Screen brightness
    awful.key({}, "XF86MonBrightnessDown", function()
        awful.spawn.with_shell("light -U 2")
    end,
    {description = "Decrease screen brightness", group = "Misc"}),

    awful.key({}, "XF86MonBrightnessUp", function()
        awful.spawn.with_shell("light -A 2")
    end,
    {description = "Increase screen brightness", group = "Misc"}),

    -- Keyboard backlight (i'm using macbook)
    awful.key({}, "XF86KbdBrightnessDown", function()
        awful.spawn.with_shell("light -s sysfs/leds/smc::kbd_backlight -U 5")
    end,
    {description = "Decrease keyboard brightness", group = "Misc"}),

    awful.key({}, "XF86KbdBrightnessUp", function()
        awful.spawn.with_shell("light -s sysfs/leds/smc::kbd_backlight -A 5")
    end,
    {description = "Increase keyboard brightness", group = "Misc"}),

    -- Volume
    awful.key({}, "XF86AudioMute", function()
        helpers.volume_control(0)
    end,
    {description = "Toggle volume", group = "Misc"}),

    awful.key({}, "XF86AudioLowerVolume", function()
        helpers.volume_control(-2)
    end,
    {description = "Lower volume", group = "Misc"}),

    awful.key({}, "XF86AudioRaiseVolume", function()
        helpers.volume_control(2)
    end,
    {description = "Raise volume", group = "Misc"}),

    -- Music
    awful.key({alt}, "g", function()
        playerctl:play_pause()
    end,
    {description = "Toggle music", group = "Misc"}),

    awful.key({alt}, "f", function()
        playerctl:previous()
    end,
    {description = "Previous music", group = "Misc"}),

    awful.key({alt}, "b", function()
        playerctl:next()
    end,
    {description = "Next music", group = "Misc"}),

	-- Lockscreen
	awful.key({mod, alt}, "l", function()
		awful.spawn("betterlockscreen -l")
	end),

	-- Scripts
	awful.key({mod}, "d", function()
		awful.spawn("sh /home/katsuki/scripts/rofi/launch.sh appmenu")
	end),

	-- awful.key({mod, "Mod1"}, "c", function()
		-- awful.spawn("sh /home/katsuki/scripts/rofi/launch.sh powermenu")
	-- end),

	awful.key({mod, "Mod1"}, "c", function()
		toggle_menu()
	end),

	awful.key({mod, "Mod1"}, "x", function()
		awful.spawn("sh /home/katsuki/.config/rofi/wifi/wifi")
	end),

	awful.key({mod, "Mod1"}, "v", function()
		awful.spawn("sh /home/katsuki/.config/rofi/music/music")
	end),

	awful.key({"Mod1"}, "a", function()
		awful.spawn("sh /home/katsuki/scripts/misc/volume.sh down")
	end),
	
	awful.key({"Mod1"}, "s", function()
		awful.spawn("sh /home/katsuki/scripts/misc/volume.sh up")
	end),
	
	awful.key({"Mod1"}, "c", function()
		awful.spawn("sh /home/katsuki/scripts/misc/volume.sh mute")
	end),

	awful.key({"Mod1"}, "e", function()
		awful.spawn("telegram-desktop")
	end),

	awful.key({"Mod1"}, "w", function()
		awful.spawn("firefox")
	end),

	-- awful.key({ctrl, mod}, "p", function()
		-- awful.spawn("flameshot gui")
	-- end),

	-- awful.key({shift, mod}, "p", function()
		-- awful.spawn("flameshot full -p /home/katsuki/Pictures")
	-- end),
	
	awful.key({ctrl, mod}, "p", function()
		awful.spawn("import ~/Pictures/$(date '+%Y%m%d-%H%M%S').png")
	end),

	awful.key({shift, mod}, "p", function()
		awful.spawn("import -window root ~/Pictures/$(date '+%Y%m%d-%H%M%S').png")
	end),

	awful.key({alt}, "m", function()
		awful.spawn("sh /home/katsuki/scripts/misc/backlight.sh up")
	end),

	awful.key({alt}, "n", function()
		awful.spawn("sh /home/katsuki/scripts/misc/backlight.sh down")
	end),

	awful.key({ctrl, alt}, "c", function()
		awful.spawn("sh /home/katsuki/.config/eww/awesome/launch_eww")
	end),

	awful.key({mod}, "a", function()
		toggle_action()
	end, { description = "action center", group = "awesome" }),

    -- Screenshot
    awful.key({mod}, "/", function()
        awful.spawn.with_shell("screensht")
    end,
    {description = "Take screenshot", group = "Misc"})

)


-- Client key bindings
------------------------

keys.clientkeys = gears.table.join(

    -- Move or swap by direction
    awful.key({mod, shift}, "k", function(c)
        helpers.move_client(c, "up")
    end),

    awful.key({mod, shift}, "h", function(c)
        helpers.move_client(c, "left")
    end),

    awful.key({mod, shift}, "j", function(c)
        helpers.move_client(c, "down")
    end),

    awful.key({mod, shift}, "l", function(c)
        helpers.move_client(c, "right")
    end),

    -- Relative move client
    awful.key({mod, shift, ctrl}, "j", function (c)
        c:relative_move(0,  dpi(20), 0, 0)
    end),

    awful.key({mod, shift, ctrl}, "k", function (c)
        c:relative_move(0, dpi(-20), 0, 0)
    end),

    awful.key({mod, shift, ctrl}, "h", function (c)
        c:relative_move(dpi(-20), 0, 0, 0)
    end),

    awful.key({mod, shift, ctrl}, "l", function (c)
        c:relative_move(dpi( 20), 0, 0, 0)
    end),

    -- Toggle floating
    awful.key({mod, ctrl}, "space",
        awful.client.floating.toggle
    ),

    awful.key({}, "XF86LaunchA",
        awful.client.floating.toggle
    ),

    -- Toggle fullscreen
    awful.key({mod}, "f", function()
        client.focus.fullscreen = not client.focus.fullscreen 
        client.focus:raise()
    end),

    -- Toggle maximize
    awful.key({mod}, "m", function()
        client.focus.maximized = not client.focus.maximized
    end),

    -- Minimize windows
    awful.key({mod}, "n", function()
        client.focus.minimized = true
    end),

    -- Keep on top
    awful.key({mod}, "p", function (c)
        c.ontop = not c.ontop
    end),

    -- Sticky
    awful.key({mod, shift}, "p", function (c)
        c.sticky = not c.sticky
    end),

    -- Close window
    awful.key({mod}, "q", function()
        client.focus:kill()
    end),

    -- Center window
    awful.key({mod}, "c", function()
        awful.placement.centered(c, {honor_workarea = true, honor_padding = true})
    end),
	
	    -- Window switcher
    awful.key({mod}, "Tab", function()
        awesome.emit_signal("bling::window_switcher::turn_on")
    end)

)


-- Move through workspaces
----------------------------

for i = 1, 10 do
    keys.globalkeys = gears.table.join(keys.globalkeys,

        -- View workspaces
        awful.key({mod}, "#" .. i + 9, function()
            helpers.tag_back_and_forth(i)
            -- local s = mouse.screen
            -- local tag = s.tags[i]
            -- if tag then
            --     if tag == s.selected_tag then
            --         awful.tag.history.restore()
            --     else
            --         tag:view_only()
            --     end
            -- end
        end),

        -- Move focused client to workspaces
        awful.key({mod, "Shift"}, "#" .. i + 9, function() 
            if client.focus then 
                local tag = client.focus.screen.tags[i] 
                if tag then 
                    client.focus:move_to_tag(tag) 
                end 
            end 
        end)

    )
end


-- Mouse bindings on desktop
------------------------------

keys.desktopbuttons = gears.table.join(

    -- Left click
    awful.button({}, 1, function()
        naughty.destroy_all_notifications()
        if mymainmenu then
            mymainmenu:hide()
        end
    end),

    -- Right click
    awful.button({}, 3, function()
        mymainmenu:toggle()
    end),

    -- Scrolling
    awful.button({}, 4, awful.tag.viewprev),
    awful.button({}, 5, awful.tag.viewnext)

)


-- Mouse buttons on the client
--------------------------------

keys.clientbuttons = gears.table.join(

    -- Focus to client
    awful.button({}, 1, function(c)
        c:activate{context = "mouse_click"}
    end),

    -- Move client
    awful.button({mod}, 1, function(c)
        c:activate{context = "mouse_click", action = "mouse_move"}
    end),

    -- Resize client
    awful.button({mod}, 3, function(c)
        c:activate{contect = "mouse_click", action = "mouse_resize"}
    end)

)


-- Mouse buttons on the taglist
---------------------------------

keys.taglistbuttons = gears.table.join(

    -- Move to selected tag
    awful.button({'Any'}, 1, function(t) 
        t:view_only() 
    end),

    -- Move focused client to selected tag
    awful.button({mod}, 1, function(t)
        if client.focus then 
            client.focus:move_to_tag(t) 
        end
    end), 

    -- Cycle through workspaces
    awful.button({'Any'}, 4, function(t)
        awful.tag.viewprev(t.screen)
    end), 
    awful.button({'Any'}, 5, function(t)
        awful.tag.viewnext(t.screen)
    end)

)


-- Mouse buttons on the tasklist
----------------------------------

keys.tasklistbuttons = gears.table.join(

    -- Left click
    awful.button({'Any'}, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", {raise = true})
        end
    end),

    -- Middle click
    awful.button({'Any'}, 2, nil, function(c) 
        c:kill() 
    end),

    -- Right click
    awful.button({'Any'}, 3, function (c) 
        c.minimized = not c.minimized 
    end),

    -- Scrolling
    awful.button({'Any'}, 4, function ()
        awful.client.focus.byidx(-1)
    end),
    awful.button({'Any'}, 5, function ()
        awful.client.focus.byidx(1)
    end)

)

-- Mouse buttons on the layoutbox
-----------------------------------

keys.layoutboxbuttons = gears.table.join(

    -- Left click
    awful.button({'Any'}, 1, function (c)
        awful.layout.inc(1)
    end),

    -- Right click
    awful.button({'Any'}, 3, function (c) 
        awful.layout.inc(-1) 
    end),

    -- Scrolling
    awful.button({'Any'}, 4, function ()
        awful.layout.inc(-1)
    end),
    awful.button({'Any'}, 5, function ()
        awful.layout.inc(1)
    end)

)


-- Mouse buttons on the titlebar
----------------------------------

keys.titlebarbuttons = gears.table.join(

    -- Left click
    awful.button({}, 1, function (c)
        local c = mouse.object_under_pointer()
        client.focus = c
        awful.mouse.client.move(c)
    end),

    -- Middle click
    awful.button({}, 2, function (c) 
        local c = mouse.object_under_pointer()
        c:kill()
    end),

    -- Right click
    awful.button({}, 3, function ()
        local c = mouse.object_under_pointer()
        client.focus = c
        awful.mouse.client.resize(c)
    end)

)

-- Set root (desktop) keys
root.keys(keys.globalkeys)
root.buttons(keys.desktopbuttons)

return keys
