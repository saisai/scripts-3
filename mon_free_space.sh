#!/usr/bin/env bash

# Useful to kill/stop process if there is no space left on device

maxPercents=97
interval=10
disk=/
cmd=:

function printUsage()
{
    echo "$0 [ -m max_percents ] [ -i interval_secs ] [ -d mount_point ] [ cmd ]" >&2
    exit 1
}

function parseOptions()
{
    local OPTIND o
    while getopts "m:i:d:" o; do
        case "$o" in
            m) maxPercents=$OPTARG;;
            i) interval=$OPTARG;;
            d) disk=$OPTARG;;
            *) printUsage;;
        esac
    done
    shift $((OPTIND-1))
    [ -n "$*" ] && cmd="$@"
}

function diskUsedPercents()
{
    local disk=$1
    df -m $disk | awk '{ print substr($5, 1, length($5) - 1) }'
}

function main()
{
    while :; do
        sleep $interval
        if [ $(diskUsedPercents $disk) -lt $maxPercents ]; then
            continue
        fi
        printf "Not enough space left on %s, executing user specified command\n" $disk
        $cmd
        break
    done
}

parseOptions "$@"
main
