#!/bin/sh

if [ `uname -s` != Linux ]; then
    ## We're using GNU's getopt not BSD's {sigh}
    echo Error: Not a Linux system
    exit 1
fi

if [ -z "$WALLAROO_BIN" -o ! -x "$WALLAROO_BIN" ]; then
    echo "Error: WALLAROO_BIN env var not set or executable '$WALLAROO_BIN' does not exist"
    exit 1
fi

NUM_WORKERS=1
VERBOSE=""

# Ref: /usr/share/doc/util-linux/examples/getopt-parse.bash
TEMP=`getopt -o n:v --long n-long:v-long \
     -n $0 -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -n|--n-long) NUM_WORKERS=$2; shift 2 ;;
        -v|--v-long) VERBOSE=true; shift 1 ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done
WORKER=$1

if [ ! -z "$VERBOSE" ]; then
    echo NUM_WORKERS=$NUM_WORKERS
    echo VERBOSE=$VERBOSE
fi

cmd="$WALLAROO_BIN $WALLAROO_BASE_ARGS --data $WALLAROO_ARG_DATA \
     --cluster-initializer --worker-count $NUM_WORKERS \
     $WALLAROO_ARG_PONY"
if [ ! -z "$VERBOSE" ]; then
    echo "cmd: $cmd /tmp/wallaroo.1 2>&1 &"
fi

eval "strace -o /tmp/strace.out -f $cmd" > /tmp/wallaroo.1 2>&1 &

exit 0
