--[[
 _____ __ _ __ _____ _____ _____ _______ _____
|     |  | |  |  ___|  ___|     |       |  ___|
|  -  |  | |  |  ___|___  |  |  |  | |  |  ___|
|__|__|_______|_____|_____|_____|__|_|__|_____|

--]]
pcall(require, "luarocks.loader")

-- Standard awesome library
local gfs = require("gears.filesystem")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")
dpi = beautiful.xresources.apply_dpi
beautiful.init(gfs.get_configuration_dir() .. "theme/theme.lua")

-- Theme
----------

themes = {
  "light",
  "dark",
}

theme = themes[2]

beautiful.init(gfs.get_configuration_dir() .. "theme/" .. theme .."/theme.lua")

-- User vars
--------------

terminal = "urxvt"
editor = terminal .. " -e " .. os.getenv("EDITOR")
browser = "firefox"
launcher = "sh /home/katsuki/scripts/rofi/launch.sh appmenu"
file_manager = terminal .. " --class file -e ranger"
-- music_client = terminal .. " --class music -e ncmpcpp"
music_client = terminal .. " -geometry 100x21 -e ncmpcpp-ueberzug"

openweathermap_key = ""
openweathermap_city_id = ""
weather_units = "metric" -- metric or imperial


-- Load configuration
-----------------------

-- Sub (signals for battery, volume, brightness, etc)
require("sub")

-- Misc (bar, titlebar, notification, etc)
require("misc")

-- Main (layouts, keybinds, rules, etc)
require("main")

require("misc.action")

require("signals")


-- Autostart
--------------

awful.spawn.with_shell("~/.config/awesome/main/autorun.sh")

-- Global var
-------------

F = {}

-- Garbage Collector
----------------------

collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
