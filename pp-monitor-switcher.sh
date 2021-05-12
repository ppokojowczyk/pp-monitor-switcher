#!/bin/bash

cd "$(dirname "$0")"

notify () {
  if [ -x "$(command -v notify-send)" ]; then
    notify-send -i display "$1"
  fi
}

switchMonitor () {
  for index in ${!MONITORS[@]}; do
    MONITOR_ID=${MONITORS[$index]}
    if [ $index -eq $2 ]; then
      xrandr --output $MONITOR_ID --auto
      echo -e "Switched \e[31m$MONITOR_ID\e[0m ON"
      notify "Switched $MONITOR_ID ON"
    else
      xrandr --output $MONITOR_ID --off
      echo -e "Switched \e[31m$MONITOR_ID\e[0m OFF"
      notify "Switched $MONITOR_ID OFF"
    fi
  done
}

# MONITORS=($(xrandr --listmonitors | tail +2 | awk -F" " '{ print $4 }'))
MONITORS=($(xrandr | grep " connected" | awk -F" " '{ print $1 }'))

MONITOR_INDEX_FILE="./current_monitor_index";

if [ -f "$MONITOR_INDEX_FILE" ]; then
  MONITOR_INDEX=$(cat $MONITOR_INDEX_FILE)
  MONITOR_INDEX=$(($MONITOR_INDEX+1))
  if [ $MONITOR_INDEX -gt $(("${#MONITORS[@]}"-1)) ]; then
    MONITOR_INDEX=0
  fi
else
  touch $MONITOR_INDEX_FILE
  MONITOR_INDEX=0
fi

echo $MONITOR_INDEX > $MONITOR_INDEX_FILE

MONITOR_ID=${MONITORS[$MONITOR_INDEX]}

switchMonitor $MONITORS $MONITOR_INDEX
