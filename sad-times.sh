#!/bin/sh

set -m

PROGNAME=$(basename $0)
cd $(dirname $0)

ctl=./get-you-some-redis-cluster
cli=redis-2.6.12/src/redis-cli

log() {
	echo
	echo ">>> $*"
	echo
}

increment() {
	local port=$1
	log "Incrementing admin:test:counter"
	$cli -p $port incr admin:test:counter
	sleep 1
	counters 2>/dev/null
}

counters() {
	for port in 6380 6381 6382; do
		echo -n $($ctl status $port) "admin:test:counter is "
		echo $($cli -p $port get admin:test:counter)
	done
}

$ctl wipe
sleep 1
$ctl start

node sad-times.js &
cleanup() {
	kill %1
}
trap cleanup 2 15

log "Waiting for a master..."
while sleep 1; do $ctl status 2>/dev/null && break; done

increment 6380

log "Stopping 6380"
$ctl stop 6380
while sleep 1; do $ctl status 2>/dev/null || break; done

log "Waiting for a master to be elected"
while sleep 1; do $ctl status 2>/dev/null | grep master && break; done

increment 6381

log "Starting 6380"
$ctl start 6380
while sleep 1; do $ctl status 2>/dev/null && break; done

increment 6381

log "Sleeping 2 seconds to give 6380 time to reorientate"
sleep 2

counters 2>/dev/null

log "See? No such luck. And now for the data loss..."

log "Stopping 6381"
$ctl stop 6381
while sleep 1; do $ctl status 2>/dev/null || break; done

counters 2>/dev/null

log "Waiting for 6382 to be enslaved to 6380"
while sleep 1; do
	$cli -p 6382 get admin:test:counter | grep -q 3 || break
done

counters 2>/dev/null

log "That's all, folks"

kill %1
$ctl stop

