#!/bin/sh

## CONFIGURATION PARAMETERS

# The ssh user name on remote server
REMOTE_USER="user"
# The hostname of remote server
REMOTE_HOST="example.com"
# The port number of the remote server
REMOTE_PORT="11122"
# The remote host with afp service
AFP_HOST="127.0.0.1"
# Port for tunneled afp service
LOCAL_AFP_PORT="19548"
# The label for the service, that's registered with dns-sd
LABEL="$AFP_HOST over $REMOTE_HOST"
# The path to the used ssh key file (if exists)
KEYFILE=""
# Quiet mode
QUIET=false

## NO NEED TO EDIT BELOW THIS LINE


VERSION="2014-11-23"

createTunnel() {
    if [[ -n "$KEYFILE" && -e "$KEYFILE" ]]; then
        REMOTE_LOGIN="-i $KEYFILE -p $REMOTE_PORT \
            $REMOTE_USER@$REMOTE_HOST"
    else
        REMOTE_LOGIN="-p $REMOTE_PORT \
            $REMOTE_USER@$REMOTE_HOST"
    fi

    if [ "$QUIET" = "false" ]; then echo "Connecting to server: $REMOTE_HOST" >&2; fi

    # Create tunnel to port 548 on remote host and make it avaliable at port $LOCAL_AFP_PORT at localhost
    # Also tunnel ssh for connection testing purposes
    ssh -o TCPKeepAlive=yes -o ServerAliveCountMax=9999 -o ServerAliveInterval=15 -gNf -L "$LOCAL_AFP_PORT:$AFP_HOST:548" -C $REMOTE_LOGIN

    if [[ $? -eq 0 ]]; then
        # Register AFP as service via dns-sd
        dns-sd -R "$LABEL" _afpovertcp._tcp . "$LOCAL_AFP_PORT" > /dev/null &

        if [ "$QUIET" = "false" ]; then echo "Tunnel to $REMOTE_HOST created successfully"; fi
        exit 0
    else
        if [ "$QUIET" = "false" ]; then echo "An error occurred creating a tunnel to $REMOTE_HOST RC was $?"; fi
        exit 1
    fi
}

killTunnel() {
    MYPID=`getPid`
    for i in $MYPID; do kill $i; done
    if [ "$QUIET" = "false" ]; then echo "All processes killed"; fi
    exit 0
}

status() {
    MYPID=`getPid`
    if [[ -z "$MYPID" ]]; then
        if [ "$QUIET" = "false" ]; then echo "Tunnel to $REMOTE_HOST is NOT ACTIVE"; fi
        exit 0
    fi
    if [ "$QUIET" = "false" ]; then echo "Tunnel to $REMOTE_HOST is ACTIVE"; fi
    exit 1
}

getPid() {
    MYPID=`ps aux | egrep -w \
      "ssh -gNf -L $LOCAL_AFP_PORT:.*$REMOTE_HOST|dns-sd -R $LABEL" \
      | grep -v egrep | awk '{print $2}'`
    echo $MYPID
}

help() {
    SCRIPT_NAME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
    echo "$SCRIPT_NAME version $VERSION

$SCRIPT_NAME is a small shell script that tunnels the AFP port of your disk station
(and propably every other NAS with AFP and SSH services running) over ssh to your client computer.

Put your settings in the config section in the script itself!

Options
 -q, --quiet                 quiet mode
 -k, --kill                  kill all $SCRIPT_NAME processes
 -h, --help                  show this screen
"
exit 0
}

# Yippieeh, commandline parameters

while [ $# -gt 0 ]; do    # Until you run out of parameters . . .
    case "$1" in
        -s|--status)
            status
        ;;
        -k|--kill)
            killTunnel
        ;;
        -q|--quiet)
            QUIET=true
        ;;
        -h|--help)
            help
        ;;
        *)
 
        ;;
    esac
    shift       # Check next set of parameters.
done

MYPID=`getPid`
if [[ -z "$MYPID" ]]; then
    createTunnel
else
    if [ "$QUIET" = "false" ]; then echo "Tunnel to $REMOTE_HOST is already active"; fi
fi
