#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

run xrandr --output HDMI1 --right-of eDP1 
run picom --config $HOME/.config/openbox/picom.conf
# run xsetroot -cursor_name GoogleDot-black 
run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 
run flameshot 
# wal -i $HOME/wallpapers/cherry1.jpeg
# run nitrogen --restore  
run picom --config $HOME/.config/picom.conf 
# sh $HOME/.config/polybar/launch.sh tiled & 
# sh $HOME/.config/eww/launch_eww &
# sh $HOME/.config/yabar/launch.sh 
# setxkbmap -layout us,ru -option "grp:alt_shift_toggle" 
run setxkbmap -layout us,ru -option "grp:caps_toggle" 
run xinput set-prop 17 325 0.7 
run xrdb -merge $HOME/.Xresources
# run dunst 
# xfce4-power-manager
run mpd
run mpDris2
