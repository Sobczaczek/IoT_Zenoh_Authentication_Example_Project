#!/bin/ash
echo " * Starting: /zenohd --config /etc/zenoh/config.json5 $*"
exec /zenohd --config /etc/zenoh/config.json5 $*