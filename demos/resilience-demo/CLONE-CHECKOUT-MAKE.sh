#!/bin/sh

. ./COMMON.sh

ssh -n $USER@$SERVER1_EXT "git clone $REPO_URL"
ssh -n $USER@$SERVER1_EXT "cd wallaroo ; git checkout $REPO_BRANCH ; git diff"

if [ "$SKIP_CLEAN" = "" ]; then
    ssh -n $USER@$SERVER1_EXT "cd wallaroo ; make clean"
fi

if [ "$SKIP_MAKE" = "" ]; then
    echo "Extra flags: \$MAKEFLAGS2 = $MAKEFLAGS2, \$PONYCFLAGS2 = $PONYCFLAGS2"
    ssh -n $USER@$SERVER1_EXT "cd wallaroo ; make $MAKEFLAGS2 PONYCFLAGS='$PONYCFLAGS2 --verbose=1 -d' $RESILIENCE_FLAG build-testing-performance-apps-market-spread build-utils-cluster_shutdown build-giles-sender build-utils-data_receiver build-testing-correctness-apps-multi_partition_detector build-testing-correctness-apps-multi_partition_detector-validator"
fi

for i in $SERVER2 $SERVER3 $SERVER4; do
    echo rsync to $i
    ssh -A -n $USER@$SERVER1_EXT "rsync -raH --delete -e 'ssh -o \"StrictHostKeyChecking no\"' ~/wallaroo ${i}:"
done
