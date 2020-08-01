#!/usr/bin/env sh

## Add this to your wm startup file.

NC='\033[0m'
RED='\033[31m'
BLUE='\033[34m'

launch_bar() {
  MONITOR=$1 IFACE_ETH=${eth} IFACE_WLAN=${wlan} COUNTRY=${country} polybar "$2" &
}

# Terminate already running bar instances

if command -v killall >/dev/null; then
	killall -q polybar
else
	pkill -x polybar
fi

# Wait until the processes have been shut down
while pgrep -u "$(id -u)" -x polybar >/dev/null; do sleep 1; done

eth=$(ip link | grep -m 1 -E '\b(en).*\b(state UP)' | awk '{print substr($2, 1, length($2)-1)}')
# ! eth && eth=$(ip link | grep -m 1 -E '\b(et).*\b(state UP)' | awk '{print substr($2, 1, length($2)-1)}')
wlan=$(ip link | grep -m 1 -E '\b(wl)' | awk '{print substr($2, 1, length($2)-1)}')
printf "Found network interfaces: ${BLUE}%s${NC} (eth), ${BLUE}%s${NC} (wlan)\\n" "${eth}" "${wlan}"
# for covid data
country="$(curl -s https://ipvigilante.com/$(curl -s https://ipinfo.io/ip) | jq '.data.country_name')"
printf "Found country: ${BLUE}%s${NC}\\n" "${country}"

# Use newline as field separator for looping over lines
IFS=$'\n'

# Ensure that xrandr is available and abort the script otherwise. Discard
# command's output by redirecting stdout to /dev/null and stderr to stdout.
if ! command -v xrandr >/dev/null 2>&1; then
  printf "[ ${RED}Error${NC} ] Polybar launcher requires ${BLUE}xrandr${NC} for detecting monitors.\\n" >&2
  exit
fi

for i in $(polybar -m | awk -F: '{print $1}'); do
  launch_bar "${i}" example &
done

#for screen in $(xrandr --query | grep -w connected); do
  # Substring removal, delete everything after first space
#  output=${screen%% *}
#  printf "Found output: ${BLUE}%s${NC}\\n" "${output}"
#
#  case ${screen} in
#   *primary*)
#      printf "Launching primary bar(s) on ${BLUE}%s${NC}\\n" "${output}"
#     launch_bar "${output}" example
#      ;;
#    *)
#      ;;
#  esac
#done
